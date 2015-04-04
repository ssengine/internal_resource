-- This is a prototype definination for Scene
-- But you don't need to create a Scene object.
-- Implement your own factory module instead of "extend" this class.

local Scene = {}
Scene.__index = Scene

function Scene.new()
	local ret = {}
	setmetatable(ret, Scene)
	return ret
end

-- Enter a scene.
function Scene:enter()
end

function Scene:leave()
end

_G.Scene = Scene
return Scene