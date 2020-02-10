Art = Object:extend()

local Animation = require "base.animation"

function Art:new(name)
	self.frames = {}
	self.anim = Animation()

	if name then
		self:loadArt(name)
		self:format()
	end

	self.x = 0
	self.y = 0
	self.z = 10
	self.width = 0
	self.height = 0

	self.visible = true

	self.currentFrame = self.anim:getRealFrame()
end

function Art:update(dt)
	self.anim:update(dt)
	local nf = self.anim:getRealFrame()
	if nf ~= self.currentFrame then
		self.hasChanged = true
		self.currentFrame = nf
	end
end


function Art:getOriginal(i)
	return i and self.frames[i] or self.frames[self.anim:getRealFrame()]
end


function Art:setDimensions()
	local width, height = 0, 0

	self.lines = {}

	for line in (self.content .. "\n"):gmatch("(.-)\n") do
		table.insert(self.lines, line)
		width = math.max(width, line:len())
		height = height + 1
	end

	self.width = width
	self.height = height-1

	if not self.oLines then
		self.oLines = lume.clone(self.lines)
	end
end


function Art:format()
	self.content = self.frames[self.anim:getRealFrame()]

	local text = self.text or ""

	text = text:gsub("%[V%]{{(%S*)}}", function (value)
		if self.referal then
			return self.referal[value] or self[value]
		end
		return self[value]
	end)

	self.content = self.content:gsub("%[T%]{{(%s-)}}", function (space)
		local space_len = space:len()

		if text == "" then
			return space
		end

		local nl = text:find("\n")

		if nl then
			local t = text:sub(1, nl-1)
			text = text:sub(nl+1, text:len())

			return t .. space:sub(0, math.max(0, space_len - t:len()))
		end

		text = text:match("%s?(.+)")

		if space_len >= text:len() then
			local t = text
			text = ""
			return t .. space:sub(0, space_len - t:len())
		end

		local t
		local i = -1

		repeat
			i = i + 1
			t = text:sub(1, space_len-i)
		until t:sub(t:len(), t:len()):find("[%s?!.,]")

		text = text:sub(space_len-i, text:len())

		return t .. space:sub(0, space_len - t:len())
	end)

	if text ~= "" then
		warning("Didn't finish the text! Left with: " .. text)
	end

	self:setDimensions()
end


function Art:loadArt(name)
	local art = love.filesystem.read("assets/art/" .. name .. ".txt")
	art = Utils.filterNewLines(art)

	local frames = {}

	if art:sub(1, 5) == "{{F}}" then
		art = art .. "\n\r{{F}}"
		self:grabFrames(art:sub(6, art:len()))
		art = self.frames[1]
	else
		self.frames[1] = art
	end

	self.oContent = art
	self.content = art
	self:setDimensions()
end


function Art:setArt(art)
	self.content = art
	self.frames = {art}
	self:setDimensions()
end


function Art:grabFrames(art)
	self.frames = {}
	self.hasAnimation = true
	for frame in art:gmatch("\n([%s%S]-){{F}}") do
		table.insert(self.frames, frame)
	end
end


function Art:reset()
	self.content = self.oContent
	self.lines = lume.copy(self.oLines)
end