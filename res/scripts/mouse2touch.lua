local TouchEvent = require("touchevent").TouchEvent
local processEvent = require("touchevent").processEvent

local mouse2touch = {}
_G.mouse2touch = mouse2touch

-- single touch mode:
local isLButtonDown

local lastx, lasty

function mouse2touch.onMouseDown(btn, x, y, t)
	lastx, lasty = x, y
	if (btn == 1) then
		isLButtonDown = true
		processEvent(TouchEvent.new("down", 1, x, y))
	end
end

function mouse2touch.onLostFocus(t)
	if (isLButtonDown) then
		isLButtonDown = false
		processEvent(TouchEvent.new("up", 1, lastx, lasty))
	end
end

function mouse2touch.onMouseUp(btn, x, y, t)
	lastx, lasty = x, y
	if (isLButtonDown) then
		isLButtonDown = false
		processEvent(TouchEvent.new("up", 1, x, y))
	end
end

function mouse2touch.onMouseMove(x, y, t)
	lastx, lasty = x, y
	if (isLButtonDown) then
		processEvent(TouchEvent.new("move", 1, lastx, lasty))
	end
end

return mouse2touch