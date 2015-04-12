local Dispatcher = require("event").Dispatcher

_G.display = Dispatcher.new()

_G.r2d = require("render2d").newContext()

return _G.display