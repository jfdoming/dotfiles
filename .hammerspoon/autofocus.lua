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
local ghosttyWindowsByID = {}

local function getGhosttyQuickTerminalUnderMouse(pos)
    -- Ghostty's quick terminal is a layer-3 Window Server panel; its ordinary
    -- windows are layer 0. The normal Hammerspoon window filter omits the panel,
    -- so resolve its Window Server ID directly instead of falling through to a
    -- window underneath it.
    for _, windowInfo in ipairs(hs.window.list(false)) do
        local bounds = windowInfo.kCGWindowBounds
        if windowInfo.kCGWindowOwnerName == "Ghostty" and
            (windowInfo.kCGWindowLayer or 0) > 0 and
            windowInfo.kCGWindowIsOnscreen and bounds and
            pos.x >= bounds.X and pos.x <= bounds.X + bounds.Width and
            pos.y >= bounds.Y and pos.y <= bounds.Y + bounds.Height then
            local windowID = windowInfo.kCGWindowNumber
            local win = ghosttyWindowsByID[windowID]
            if not win then
                win = hs.window.get(windowID)
                ghosttyWindowsByID[windowID] = win
            end
            return win, true
        end
    end

    return nil, false
end

local function getFocusableWindowUnderMouse()
    local pos = hs.mouse.absolutePosition()
    local ghosttyWindow, isOverGhosttyQuickTerminal =
        getGhosttyQuickTerminalUnderMouse(pos)

    if isOverGhosttyQuickTerminal then
        return ghosttyWindow, true
    end

    -- The default ordering is most recently focused first, which also gives us
    -- the frontmost window when two window frames overlap.
    for _, win in ipairs(windowFilter:getWindows()) do
        local frame = win:frame()
        if pos.x >= frame.x and pos.x <= frame.x + frame.w and
            pos.y >= frame.y and pos.y <= frame.y + frame.h then
            return win, false
        end
    end

    return nil, false
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

    local targetWindow, blocksUnderlyingWindow = getFocusableWindowUnderMouse()
    if blocksUnderlyingWindow and not targetWindow then
        autofocusArmed = false
        resetHover()
        return
    end

    local targetWindowID = targetWindow and targetWindow:id() or nil

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
        targetWindow:focus()
        lastFocusedWindowID = targetWindowID
        resetHover()
    end
end)

-- Returning the module keeps the timer alive in package.loaded after
-- require("autofocus") finishes.
return autofocus
