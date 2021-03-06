--[[
	Exercise 25.8
	
	One problem with the sandbox in Listing 25.6 is that sandboxed code
cannot call its own functions. How can you correct this problem?

	Ans: Use a modified version of Listing 25.6 that checks whether the source
of the called function is arg[1] itself.
]]

local debug = require "debug"

-- load chunk
local chunk = assert(loadfile(arg[1], "t", {}))

-- maximum "steps" that can be performed
local steplimit = 1000

local count = 0 -- counter for steps

-- set of authorized functions
local validfunc = {
	[string.upper] = true,
	[string.lower] = true,
}

local function hook (event)
	print(event)
	if event == "call" then
		local info = debug.getinfo(2, "Sfn")
		
		local good = validfunc[info.func] or -- valid smuggle
						info.what == "main" or -- the main chunk itself
						info.source:match("^@"..arg[1]) -- defined inside the chunk's code
						
		if not good then
			error("calling bad function: " .. (info.name or "?"))
		end
	end

	count = count + 1
	if count > steplimit then
		error("script uses too much CPU")
	end
end

debug.sethook(hook, "c", 100) -- set hook
chunk()