Utils = {}

local flip_chars = {
	["{"] = "}",
	["}"] = "{",
	["["] = "]",
	["]"] = "[",
	["<"] = ">",
	[">"] = "<",
	["("] = ")",
	[")"] = "(",
	["\\"] = "/",
	["/"] = "\\"
}

function Utils.flipArt(str)
	local maxlength = 0
	for line in str:gmatch("(.-)\n") do
		maxlength =  math.max(line:len(), maxlength)
	end

	local flip = ""

	for spaces, text in str:gmatch("(%s+)(.-)\n") do
		local len_text = text:len()
		local len_spaces = spaces:len()

		for i=1,maxlength - (len_spaces + len_text) do
			flip = flip .. " "
		end

		text:reverse():gsub(".", function (s)
			local char = flip_chars[s] or s
			flip = flip .. char
			return s
		end)

		flip = flip .. "\n"
	end

	flip = flip:sub(1, flip:len()-1)
	return flip
end


function Utils.litString(str)
	return str:gsub("[%(%)%.%%%+%-%*%?%[%]%^%$]", "%%%1")
end


function Utils.makeString(char, n)
	local t = {}
	for i=1,n do
		table.insert(t, char)
	end
	return table.concat(t)
end


function Utils.filterNewLines(art)
	return art:gsub("\r", "")
end