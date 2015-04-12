local node2d = require("node2d")
local Class = require("oo").Class

local Node2D = Class.new()

function Node2D:__init(parent)
	if (parent) then
		self._ptr = node2d.newChild(parent._ptr)
		self._parent = parent
		parent._children[self._ptr] = self
	else
		self._root = node2d.createRoot()
		self._ptr = node2d.getRoot(self._root)
	end
	self._children = {}
end

local newChildMethods = {}

function Node2D:__index1(k)
	return newChildMethods[k]
end

-- hack: left "self" of parent as arguments of __init
newChildMethods.newNode = Node2D.new

function Node2D:detach()
	assert(self._parent, "Cannot detach a root node!")
	self._parent[self._ptr] = nil
	self._root = node2d.detach(self._ptr);
end

-- No actually remove for Node2D.
Node2D.remove = Node2D.detach

function enumChildren(self, key)
	if (key) then
		key = node2d.next(key._ptr)
	else
		key = node2d.firstChild(self._ptr)
	end
	return key and self._children[key]
end

function Node2D:children()
	return enumChildren, self, nil
end

function enumDescendants(self, key)
	if (not key) then
		return self
	end
	local next = node2d.firstChild(key._ptr)
	if (next) then
		return key._children[next]
	end
	while (true) do
		next = node2d.next(key._ptr)
		if (next) then
			return key._parent._children[next]
		end
		key = key._parent
		if (key == self) then
			return nil
		end
	end
end

function Node2D:descendants()
	return enumDescendants, self, nil
end

function Node2D:walk(enter, leave)
	enter(self)
	for node in self:children() do
		node:walk(enter, leave)
	end
	leave(self)
end

Node2D:property("x", function(self)
		return node2d.getx(self._ptr)
	end,function(self, v)
		node2d.setx(self._ptr, v)
	end)

Node2D:property("y", function(self)
		return node2d.gety(self._ptr)
	end,function(self, v)
		node2d.sety(self._ptr, v)
	end)

function Node2D:setXY(x, y)
	node2d.setxy(self._ptr, x, y)
end

function Node2D:getXY()
	return nde2d.getxy(self._ptr)
end

Node2D:property("rotation", function(self)
		return node2d.getRotation(self._ptr)
	end,function(self, v)
		node2d.setRotation(self._ptr, v)
	end)

Node2D:property("scale", function(self)
		return node2d.getScale(self._ptr)
	end,function(self, v)
		node2d.getScale(self._ptr, v)
	end)

function Node2D:calc()
	node2d.calc(self._ptr)
end

function Node2D:enter()
end

function Node2D:leave()
end

function Node2D:render()
end

function Node2D:transMatrix(rc)
	node2d.transMatrix(self._ptr, rc or r2d)
end

local Camera2D = Class.new()
function Camera2D:enter()
end

function Camera2D:leave()
end

local Stage2D = Node2D:extend()
function Stage2D:__init()
	Node2D.statics.__init(self)
	self.camera = Camera2D.new()
end

function Stage2D:__call()
	self:calc()
	self.camera.enter()
	-- TODO: optimize walk, skip empty nodes.
	self:walk(function(node)
			node:enter()
			node:render()
		end, function(node)
			node:leave()
		end)
	self.camera.leave()
end

return {
	Stage2D = Stage2D,
	Node2D = Node2D,
	Camera2D = Camera2D,
	newChildMethods = newChildMethods
}
