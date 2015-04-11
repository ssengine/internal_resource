-- This is a prototype definination for Scene
-- Implement your own factory module instead of "extend" this class.

local Scene = {}
Scene.__index = Scene

function Scene.new(agent, layers)
	local ret = {
		agent = agent,
		layers = layers
	}
	setmetatable(ret, Scene)
	return ret
end

function Scene:start(runtime)
	self.agent:setParent(runtime)
end

function Scene:stop(runtime)
	self.agent:setParent(nil)
end

function Scene:show(display)
	display:add(self.layers)
end

function Scene:hide(display)
	display:remove(self.layers)
end

_G.Scene = Scene
return Scene