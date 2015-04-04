require("log")

function _G.bind(f, ...)
	local argn = select('#', ...)
	if (argn == 0) then
		return function(...)
			return f(...)
		end
	elseif (argn == 1) then
		local a1 = select(1, ...)		-- faster than local a1=... for LUAJIT
		return function(...)
			return f(a1, ...)
		end
	end
	local arg = table.pack(...)
	return function(...)
		local cargs = table.pack(table.unpack(arg))
		local nargn = select('#', ...)
		for i = 1, nargn do
			cargs[i+argn] = select(i, ...)
		end
		f(table.unpack(cargs, 1, argn+nargn))
	end
end

return bind
