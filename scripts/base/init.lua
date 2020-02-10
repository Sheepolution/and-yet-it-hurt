local oldrandomseed = math.randomseed
local currentrandomseed = 0

function math.randomseed(v)
	v = v or os.time()
	currentrandomseed = v
	oldrandomseed(v)
end


function math.getrandomseed()
	return currentrandomseed
end

math.randomseed()

GLOBAL = _G
PI = math.pi
TAU = PI * 2
TIMER = 0
DT = 1/60

function warning(...)
	lume.debug(1, "[WARNING] -", ...)
end


function info(...)
	lume.debug(1, "[INFO] -", ...)
end

--prints table
function tprint(...)
	local s = ""
	for i,v in ipairs({...}) do
		s = s .. lume.serialize(v) .. "  "
	end
	print(s)
end

--prints on a stacks back
function bprint(n, ...)
	lume.debug(n, ...)
end

--prints if a is true
function printif(a, ...)
	if not a then return end
	lume.debug(1, ...)
end


function lprint(...)
	local t = {...}
	for i,v in ipairs(t) do
		t[i] = v:gsub("\n", "\\n")
	end
	lume.debug(1, unpack(t))
end

--Example: F(self, "kill")
function F(a, f, ...)
	local args = {...}
	return function () return a[f](a, unpack(args)) end
end


function requireDir(dir)
	local files = love.filesystem.getDirectoryItems(dir)
	local path = dir:gsub("/",".")
	for i,v in ipairs(files) do
		local d = dir .. "/" .. v
		if love.filesystem.isDirectory(d) then
			requireDir(d)
		else
			if v:find(".lua") then
				require(path .. "." .. v:match("[^.]+"))
			end
		end
	end
end

return base