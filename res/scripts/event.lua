local Dispatcher = {}
Dispatcher.__index = Dispatcher

function Dispatcher.new()
	local ret = {
		map = {},
		list = {},
		count = 0
	}
	setmetatable(ret, Dispatcher)
	return ret
end

function Dispatcher:addListener(f)
	if (self.map[f]) then
		self:removeListener(f)
	end
	self.count = self.count + 1
	self.map[f] = self.count
	self.list[self.count] = f
end

function Dispatcher:removeListener(f)
	local i = self.map[f]
	if (i) then
		self.map[f] = nil
		self.list[i] = nil
	end
end

function Dispatcher:__call(...)
	for i=1, self.count do
		if (self.list[i]) then
			self.list[i](...)
		end
	end

	local j = 0
	for i=1, self.count do
		if (self.list[i]) then
			j = j+ 1
			if (i ~= j) then
				self.list[j],self.list[i] = self.list[i], nil
			end
		end
	end
	self.count = j
end

_G.event = {Dispatcher = Dispatcher}
return event