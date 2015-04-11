local bind = require("bind")
local Dispatcher = require("event").Dispatcher
local Class = require("oo").Class

local rtAgent = Class.new()

function rtAgent:__init(parent)
	self._ratio = 1
	self._t = 0
	self.onTick = Dispatcher.new()
	self.list = {}
	if (parent) then
		self:setParent(parent)
	end
end

function rtAgent:newAgent()
	return rtAgent.new(self)
end

function rtAgent:setParent(parent)
	if (self.parent) then
		self.parent.onTick:removeListener(self._tick)
	end
	self._tick = self._tick or bind(self.tick, self)
	self.parent = parent
	if (parent) then
		parent.onTick:addListener(self._tick)
	end
end

function rtAgent:setTimeRatio(ratio)
	self._ratio = ratio or 1
end

local bit = bit or bit32
local rshift = bit.rshift
local band = bit.band

local Timer = {}
Timer.__index = Timer
Timer.name = "runtime.Timer"

local function shift_up(list, pos, node)
	node = node or list[pos]
	local val = node.t

	while (pos > 1) do
		-- local par = math.floor(pos/2)
		local par = rshift(pos, 1)
		local parn = list[par]
		if (parn.t <= val) then
			-- in position
			break
		else
			-- move parent node
			list[pos] = parn
			parn.pos = pos
			-- list[par] = nil

			-- keep poping
			pos = par
		end
	end

	node.pos = pos
	list[pos] = node
end

local function shift_down(list, pos, node)
	node = node or list[pos]
	local val = node.t

	local size = #list

	while true do
		local child = pos*2
		-- Find smaller child.
		if (list[child+1] and list[child+1].t<=list[child].t) then
			child = child + 1
		end
		local childn = list[child]
		if (childn and node.t > childn.t) then
			list[pos] = childn
			childn.pos = pos

			pos = child
		else
			break
		end
	end

	node.pos = pos
	list[pos] = node
end

local function addTimer(list, timer)
	local pos = #list+1
	-- list[pos] = timer
	-- timer.pos = pos
	shift_up(list, pos, timer)
end

local function removeTimer(list, timer)
	if (timer.pos > 1) then
		-- pop timer to top
		timer.t = list[1].t - 1
		shift_up(list, timer.pos, timer)
		assert(timer.pos == 1)
	end
	-- use last element instead
	if (#list > 1) then
		local node = list[#list]
		list[#list] = nil
		list[1] = node

		-- shift down last element
		shift_down(list, 1, node)
	else
		list[1] = nil
	end

	timer.list = nil
	timer.pos = nil
end

function Timer:cancel()
	if (self.list) then
		removeTimer(self.list, self)
	end
end

function rtAgent:setTimeout(f, delay)
	assert(delay>=0, "Cannot call setTimeout with a negetive delay.")
	local ret = {
		list = self.list,
		func = f,
		t = self._t+delay
	}
	setmetatable(ret, Timer)
	addTimer(self.list, ret)
	return ret
end

function rtAgent:setInterval(f, delay, rpt)
	assert(delay>=0, "Cannot call setInterval with a negetive delay.")
	local ret = {
		list = self.list,
		func = f,
		t = self._t+delay,
		delay = delay,
		rpt = rpt or true
	}
	setmetatable(ret, Timer)
	addTimer(self.list, ret)
	return ret
end

function rtAgent:tick(dt)
	if (self._paused) then
		return
	end
	local t = self._t
	local endt = t + dt*self._ratio

	while true do
		local n = self.list[1]
		if (not n or n.t > endt) then
			break
		end
		removeTimer(self.list, n)
		self._t = n.t
		n:func()
		if (n.rpt) then
			if (n.rpt ~= 1) then
				if (type(n.rpt)=='number') then
					n.rpt = n.rpt - 1
				end
				n.t = n.t + n.delay
				addTimer(self.list, n)
			end
		end
	end

	self._t = endt
	self.onTick(dt, self._t)
end

function rtAgent:getTime()
	return self._t
end

_G.runtime = rtAgent.new()
_G.runtime.Agent = rtAgent
_G.runtime.Timer = Timer
return _G.runtime
