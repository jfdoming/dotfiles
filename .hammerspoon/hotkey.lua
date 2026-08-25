function bindToWindow(windowQuery, ...)
    local windowFilter = hs.window.filter.new(windowQuery)
    local boundHotkey = hs.hotkey.new(...)

    windowFilter:subscribe(hs.window.filter.windowFocused, function()
        boundHotkey:enable()
    end)
    windowFilter:subscribe(hs.window.filter.windowUnfocused, function()
        boundHotkey:disable()
    end)
end

return {
    bindToWindow = bindToWindow,
}
