c = require("coroutines")
hotkey = require("hotkey")
getCurrentURL = require("chrome-get-current-url")

hotkey.bindToWindow("Google Chrome", "⌘⇧", "c", c(function()
    url = c.yield(getCurrentURL)
    hs.pasteboard.setContents(url)
    hs.alert("Copied URL to clipboard!")
end))
