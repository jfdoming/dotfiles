local autofocus = {}

local hoverDelay = 0.1
local pollInterval = 0.05
local movementTolerance = 8
local movementToleranceSquared = movementTolerance * movementTolerance
local hoveredWindowID = nil
local hoverStartedAt = nil
local autofocusArmed = false
local movementAnchor = hs.mouse.absolutePosition()
local lastSamplePosition = movementAnchor
local lastObservedWindowID = nil
local hasObservedWindow = false
local initiallyFocusedWindow = hs.window.focusedWindow()
local lastFocusedWindowID =
    initiallyFocusedWindow and initiallyFocusedWindow:id() or nil

local maxFocusableWindowLayer = 10

local function getWindowUnderMouse()
    local pos = hs.mouse.absolutePosition()
    local windowList = hs.window.list(false)
    local frontmostRegularWindowByPID = {}

    -- Window Server reports the actual on-screen windows, unlike Accessibility,
    -- which can expose inactive tabs as overlapping windows. Remember each
    -- application's frontmost regular window so we do not disturb its selected
    -- tab when it is already active.
    for _, windowInfo in ipairs(windowList) do
        local ownerPID = windowInfo.kCGWindowOwnerPID
        if ownerPID and windowInfo.kCGWindowIsOnscreen and
            (windowInfo.kCGWindowLayer or 0) == 0 and
            not frontmostRegularWindowByPID[ownerPID] then
            frontmostRegularWindowByPID[ownerPID] =
                windowInfo.kCGWindowNumber
        end
    end

    -- The list is ordered front to back, so the first eligible rectangle that
    -- contains the pointer is the visible target. Modest positive layers cover
    -- utility and quick-terminal panels; very high layers are typically large,
    -- partly transparent system overlays and are intentionally ignored.
    for _, windowInfo in ipairs(windowList) do
        local bounds = windowInfo.kCGWindowBounds
        local windowLayer = windowInfo.kCGWindowLayer or 0
        local isUnderMouse = windowInfo.kCGWindowIsOnscreen and bounds and
            (windowInfo.kCGWindowAlpha or 1) > 0 and
            pos.x >= bounds.X and pos.x <= bounds.X + bounds.Width and
            pos.y >= bounds.Y and pos.y <= bounds.Y + bounds.Height

        if isUnderMouse and windowLayer >= 0 and
            windowLayer <= maxFocusableWindowLayer then
            local ownerPID = windowInfo.kCGWindowOwnerPID
            return {
                id = windowInfo.kCGWindowNumber,
                layer = windowLayer,
                ownerPID = ownerPID,
                frontmostRegularID =
                    frontmostRegularWindowByPID[ownerPID],
            }
        end
    end

    return nil
end

local function resetHover()
    hoveredWindowID = nil
    hoverStartedAt = nil
end

local function movedBeyondTolerance(pos)
    local dx = pos.x - movementAnchor.x
    local dy = pos.y - movementAnchor.y
    return dx * dx + dy * dy > movementToleranceSquared
end

autofocus.pollTimer = hs.timer.doEvery(pollInterval, function()
    local mousePosition = hs.mouse.absolutePosition()
    local mouseMoved = mousePosition.x ~= lastSamplePosition.x or
        mousePosition.y ~= lastSamplePosition.y
    lastSamplePosition = mousePosition

    local focusedWindow = hs.window.focusedWindow()
    local focusedWindowID = focusedWindow and focusedWindow:id() or nil

    -- Resolve the visual target even while autofocus is disarmed. A tiny
    -- movement that crosses a real window boundary is intentional movement,
    -- regardless of the within-window jitter tolerance.
    local target = getWindowUnderMouse()
    local targetWindowID = target and target.id or nil

    -- A keyboard-driven focus change, such as Command-Tab, should win over
    -- focus-follows-mouse. Wait for deliberate mouse movement before arming it
    -- again. Autofocus updates lastFocusedWindowID itself below, so its own
    -- focus change does not trigger this branch.
    if focusedWindowID ~= lastFocusedWindowID then
        autofocusArmed = false
        resetHover()
        movementAnchor = mousePosition
        lastFocusedWindowID = focusedWindowID
        lastObservedWindowID = targetWindowID
        hasObservedWindow = true
        return
    end

    local crossedWindowBoundary = hasObservedWindow and mouseMoved and
        targetWindowID ~= lastObservedWindowID
    lastObservedWindowID = targetWindowID
    hasObservedWindow = true

    local significantMovement = movedBeyondTolerance(mousePosition)
    if not autofocusArmed then
        if not significantMovement and not crossedWindowBoundary then return end
        autofocusArmed = true
        movementAnchor = mousePosition
    end

    -- An active application's frontmost regular window already owns keyboard
    -- focus. Refocusing it can disturb applications that represent tabs as
    -- separate Accessibility windows.
    if target and target.layer == 0 and
        targetWindowID == target.frontmostRegularID then
        local frontmostApp = hs.application.frontmostApplication()
        if frontmostApp and frontmostApp:pid() == target.ownerPID then
            resetHover()
            return
        end
    end

    if not targetWindowID or targetWindowID == focusedWindowID then
        resetHover()
        return
    end

    -- Start (or restart) the delay after the pointer settles within a small
    -- radius. Measuring from an anchor allows Magic Mouse jitter while still
    -- treating deliberate or cumulative movement as motion.
    if targetWindowID ~= hoveredWindowID or significantMovement then
        hoveredWindowID = targetWindowID
        hoverStartedAt = hs.timer.secondsSinceEpoch()
        movementAnchor = mousePosition
        return
    end

    if hs.timer.secondsSinceEpoch() - hoverStartedAt >= hoverDelay then
        -- Resolve a fresh Accessibility object only at focus time. Holding one
        -- across tab creation or removal can leave it pointing at stale UI.
        local targetWindow = hs.window.get(targetWindowID)

        if not targetWindow then
            autofocusArmed = false
            resetHover()
            return
        end

        if target.layer > 0 then
            -- Non-activating panels need the reverse of hs.window:focus():
            -- activate their application first, then select the exact panel.
            local app = targetWindow:application()
            if app then app:activate(false) end
            targetWindow:raise()
            targetWindow:becomeMain()
        else
            targetWindow:focus()
        end
        lastFocusedWindowID = targetWindowID
        resetHover()
    end
end)

-- Returning the module keeps the timer alive in package.loaded after
-- require("autofocus") finishes.
return autofocus
