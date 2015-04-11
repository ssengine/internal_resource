local metaMethods = {
	__call = true,
	__index = true,
	__newindex = true,
	__add = true,
	__sub = true,
	__mul = true,
	__div = true,
	__mod = true,
	__pow = true,
	__unm = true,
	__concat = true,
	__len = true,
	__eq = true,
	__lt = true,
	__le = true,
	__ipairs = true,
	__pairs = true,
	__tostring = true
}

if (_VERSION == "Lua 5.2") then
	metaMethods.__gc = true
end

local Class = {}

Class.statics = {} -- Include static values and methods.
Class.getters = {}
Class.setters = {}
Class.inherts = {[Class] = true}

function makeMetatable(class)
	local mt = {
		__index = function(t, k)
			if (class.getters[k]) then
				return class.getters[k](t)
			end
			return class.statics[k]
		end,
		__newindex = function(t, k, v)
			if (class.setters[k]) then
				return class.setters[k](t)
			end
			rawset(t,k,v)
		end
	}
	return mt
end

function makeConstructor(class, k)
	return function (...)
		local ret = {}
		setmetatable(ret, class.__mt)
		class.statics[k](ret, ...)
		return ret
	end
end

Class.__mt = {}
function Class.__mt:__index(k)
	return (Class.getters[k] and Class.getters[k](self))
		or Class.statics[k] or self.statics[k] 
end
function Class.__mt:__newindex(k, v)
	-- metamethods
	if (type(k) == 'string' and k:sub(1, 2) == '__') then
		if (k:sub(1, 6) == '__init') then
			-- constructors
			rawset(self, 'new'..k:sub(7), makeConstructor(self, k))
		elseif (k:sub(1, 6) == '__get_') then
			self.getters[k:sub(7)] = v
			return
		elseif (k:sub(1, 6) == '__set_') then
			self.setters[k:sub(7)] = v
			return
		elseif (metaMethods[k]) then
			self.__mt[k] = v
			return
		end
	end
	-- support statics like Class.foo = 1 or function Class:foo()
	self.statics[k] = v
end
setmetatable(Class, Class.__mt)

function Class:__init(args)
	rawset(self, 'statics', {})
	rawset(self, 'getters', {})
	rawset(self, 'setters', {})
	rawset(self, 'inherts', {[self] = true})
	if (args) then
		for k,v in pairs(args) do
			self[k] = v
		end
	end

	rawset(self, '__mt', makeMetatable(self))
end

function Class:extend(args)
	local ret = Class.new(self)
	for k,v in pairs(self.statics) do
		ret.statics[k] = v
	end
	for k,v in pairs(self.getters) do
		ret.getters[k] = v
	end
	for k,v in pairs(self.setters) do
		ret.setters[k] = v
	end
	for k,v in pairs(self.inherts) do
		ret.inherts[k] = v
	end
	rawset(ret, 'super', self)
	return ret
end

function Class:static(k, v)
	self.statics[k] = v
end

Class.method = Class.static

function Class:getter(k, f)
	self.getters[k] = f
end

function Class:setter(k, f)
	self.setters[k] = f
end

function Class:property(k, getter, setter)
	self.getters[k] = getter
	self.setters[k] = setter
end

return {
	Class = Class
}
