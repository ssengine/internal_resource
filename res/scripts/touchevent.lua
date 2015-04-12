local Class = require("oo").Class

local TouchEvent = Class.new()

function TouchEvent:__init(type, index, x, y)
	self.type = type
	self.index = index
	self.x = x
	self.y = y
end

local function processEvent(event)
end

_G.touchevent = {
	TouchEvent = TouchEvent,
	processEvent = processEvent
}
return touchevent