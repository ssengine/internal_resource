local Dispatcher = require("event").Dispatcher

_G.display = Dispatcher.new()

_G.r2d = require("render2d").newContext()

local width, height = 0, 0
function display:getSize()
	return width, height
end

display.onSizeChanged = Dispatcher.new()

display.onSizeChanged:add(function(w, h)
	width, height = w, h
end)

return _G.display