c = require("coroutines")

local function startswith(text, prefix)
    return text:find(prefix, 1, true) == 1
end

local searchQuery = hs.axuielement.searchCriteriaFunction({
    {attribute = "AXRole", value = "AXTextField"}
})
local searchOpts = {count = 1}

local function getCurrentURL()
    local chromeWindow = hs.axuielement.windowElement(hs.application.get("Google Chrome"):visibleWindows()[1])

    local msg, results, count = c.yield(
        c.bind(chromeWindow.elementSearch, chromeWindow),
        searchQuery,
        searchOpts
    )
    local addressBarFound = (count > 0)
    if addressBarFound then
        local addressBar = results[1]
        local currentURL = addressBar:attributeValue("AXValue")
        if currentURL:find("://") then
            return currentURL
        else
            return "https://" .. currentURL
        end
    end

    return nil
end

return c.coroutinize(getCurrentURL)
