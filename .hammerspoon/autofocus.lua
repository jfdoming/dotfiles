local autofocus = {}

local hoverDelay = 0.1
local pollInterval = 0.05
local hoveredWindowID = nil
local hoverStartedAt = nil
local autofocusArmed = false
local lastMousePosition = hs.mouse.absolutePosition()
local initiallyFocusedWindow = hs.window.focusedWindow()
local lastFocusedWindowID =
    initiallyFocusedWindow and initiallyFocusedWindow:id() or nil

-- The filter maintains a cached list of normal, visible windows and excludes
-- transient helper windows that cannot usefully receive focus.
local windowFilter = hs.window.filter.defaultCurrentSpace
local ghosttyBundleID = "com.mitchellh.ghostty"

local function getGhosttyWindowIDUnderMouse(pos)
    -- Ghostty exposes tabs as overlapping Accessibility windows. The cached
    -- window filter can therefore prefer a recently created tab even after a
    -- different tab is selected. Window Server has one authoritative on-screen
    -- window, so use that ID for both regular and quick-terminal windows.
    local windowList = hs.window.list(false)
    local frontmostRegularWindowID = nil

    -- hs.window.list() is ordered front to back, so the first regular Ghostty
    -- window is the one whose selected tab must be left alone.
    for _, windowInfo in ipairs(windowList) do
        if windowInfo.kCGWindowOwnerName == "Ghostty" and
            windowInfo.kCGWindowIsOnscreen and
            (windowInfo.kCGWindowLayer or 0) == 0 then
            frontmostRegularWindowID = windowInfo.kCGWindowNumber
            break
        end
    end

    -- Walk every application's windows in real front-to-back order. A normal
    -- window above Ghostty must stop the search so we do not focus a covered
    -- Ghostty window merely because its frame also contains the pointer.
    for _, windowInfo in ipairs(windowList) do
        local bounds = windowInfo.kCGWindowBounds
        local isUnderMouse = windowInfo.kCGWindowIsOnscreen and bounds and
            (windowInfo.kCGWindowAlpha or 1) > 0 and
            pos.x >= bounds.X and pos.x <= bounds.X + bounds.Width and
            pos.y >= bounds.Y and pos.y <= bounds.Y + bounds.Height

        if isUnderMouse and windowInfo.kCGWindowOwnerName == "Ghostty" then
            local windowID = windowInfo.kCGWindowNumber
            local windowLayer = windowInfo.kCGWindowLayer or 0
            return windowID, windowLayer, frontmostRegularWindowID
        elseif isUnderMouse and (windowInfo.kCGWindowLayer or 0) == 0 then
            return nil, nil, frontmostRegularWindowID
        end
    end

    return nil, nil, frontmostRegularWindowID
end

local function getFocusableWindowUnderMouse()
    local pos = hs.mouse.absolutePosition()
    local ghosttyWindowID, ghosttyWindowLayer,
        frontmostGhosttyWindowID =
        getGhosttyWindowIDUnderMouse(pos)

    if ghosttyWindowID then
        -- Resolve the hs.window only when focus is needed. Keeping a cached
        -- object across tab creation/removal can leave us pointing at a stale
        -- Ghostty tab.
        return nil, ghosttyWindowID, true, ghosttyWindowLayer,
            frontmostGhosttyWindowID
    end

    -- The default ordering is most recently focused first, which also gives us
    -- the frontmost window when two window frames overlap.
    for _, win in ipairs(windowFilter:getWindows()) do
        local frame = win:frame()
        if pos.x >= frame.x and pos.x <= frame.x + frame.w and
            pos.y >= frame.y and pos.y <= frame.y + frame.h then
            return win, win:id(), false, nil, nil
        end
    end

    return nil, nil, false, nil, nil
end

local function resetHover()
    hoveredWindowID = nil
    hoverStartedAt = nil
end

autofocus.pollTimer = hs.timer.doEvery(pollInterval, function()
    local mousePosition = hs.mouse.absolutePosition()
    local mouseMoved = mousePosition.x ~= lastMousePosition.x or
        mousePosition.y ~= lastMousePosition.y
    lastMousePosition = mousePosition

    local focusedWindow = hs.window.focusedWindow()
    local focusedWindowID = focusedWindow and focusedWindow:id() or nil

    -- A keyboard-driven focus change, such as Command-Tab, should win over
    -- focus-follows-mouse. Wait for deliberate mouse movement before arming it
    -- again. Autofocus updates lastFocusedWindowID itself below, so its own
    -- focus change does not trigger this branch.
    if focusedWindowID ~= lastFocusedWindowID then
        autofocusArmed = false
        resetHover()
        lastFocusedWindowID = focusedWindowID
    end

    if mouseMoved then autofocusArmed = true end
    if not autofocusArmed then return end

    local targetWindow, targetWindowID, isGhosttyWindow,
        ghosttyWindowLayer, frontmostGhosttyWindowID =
        getFocusableWindowUnderMouse()

    -- Ghostty owns tab selection within its active regular window. Other
    -- Ghostty windows must remain eligible for focus-follows-mouse.
    if isGhosttyWindow and ghosttyWindowLayer == 0 and
        targetWindowID == frontmostGhosttyWindowID then
        local ghostty = hs.application.get(ghosttyBundleID)
        if ghostty and ghostty:isFrontmost() then
            resetHover()
            return
        end
    end

    if not targetWindowID or targetWindowID == focusedWindowID then
        resetHover()
        return
    end

    -- Start (or restart) the delay after the pointer becomes stationary, not
    -- merely after it first enters the window. This avoids focusing windows
    -- that the pointer is only crossing on its way to the intended target.
    if targetWindowID ~= hoveredWindowID or mouseMoved then
        hoveredWindowID = targetWindowID
        hoverStartedAt = hs.timer.secondsSinceEpoch()
        return
    end

    if hs.timer.secondsSinceEpoch() - hoverStartedAt >= hoverDelay then
        if isGhosttyWindow then
            targetWindow = hs.window.get(targetWindowID)
        end

        if not targetWindow then
            autofocusArmed = false
            resetHover()
            return
        end

        if isGhosttyWindow and ghosttyWindowLayer > 0 then
            -- Ghostty's quick terminal is a non-activating panel. The normal
            -- hs.window:focus() order marks the panel as main before activating
            -- Ghostty, and activation can override that choice. Activate first,
            -- then raise and select the exact panel.
            local ghostty = targetWindow:application()
            if ghostty then ghostty:activate(false) end
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
