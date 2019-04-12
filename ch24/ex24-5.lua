--[[
	Exercise 24.5
	
	Can you use the coroutine-based library (Listing 24.5) to run multiple
threads concurrently? What would you have to change?
]]

local lib = require "examples.async-lib"

--[[
function run (code1, code2)
	local co1 = coroutine.create(function ()
		code1()
		lib.stop()
	end)
	
	local co2 = coroutine.create(function ()
		code2()
	end)
	
	coroutine.resume(co1)
	coroutine.resume(co2)
	lib.runloop()
end

function putline (stream, line)
	local co = coroutine.running()
	local callback = function () coroutine.resume(co) end
	lib.writeline(stream, line, callback)
	coroutine.yield()
end
--]]

-- FIXME: This general version doesn't work - find the misstep. tbc.
function run (code1, ...)
	local co1 = coroutine.create(function ()
		code1()
		lib.stop()
	end)
	

	local cbodies = table.pack(...)
	local co_s = {}
	
	for i = 1, cbodies.n  do
		table.insert(co_s, coroutine.create(function () cbodies[i]() end))
	end
	
	coroutine.resume(co1)
	
	for _, co in ipairs(co_s) do
		coroutine.resume(co)
	end
	
	lib.runloop()
end

function getline (stream)
	local co = coroutine.running()
	local callback = function (l) coroutine.resume(co, l) end
	lib.readline(stream, callback)
	local line = coroutine.yield()
	return line
end

function lines (stream)
	return function ()
		return getline(stream)
	end
end

function reverse_lines (inp)
	local t = {}
	inp = inp or io.stdin
	local out = io.output()
	
	for line in lines(inp) do
		t[#t + 1] = line
	end
	
	for i = #t, 1, -1 do
		putline(out, t[i] .. "\n")
	end
end

function label_lines ()
	local t = {}
	local inp = io.input()
	local out = io.output()
	
	for line in lines(inp) do
		t[#t + 1] = line
	end
	
	for num, line in ipairs(t) do
		putline(out, string.format("%d %s\n", num, line))
	end
end

-- Try to use something different from stdin for the input stream here.
fstream = io.open("examples/fragment.lua")

run(function () reverse_lines(fstream) end, label_lines)