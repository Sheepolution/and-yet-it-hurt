File = Object:extend()

File:implement(Art)

function File:new(name, path)
	self.name = name

	if ADMIN then
		self.filename = name .. ".tхt" -- This is with a different kind of 'x'.
	else
		self.filename = name .. ".txt"
	end

	self.path = path and (path .. "/") or ""
	self.file = "Game/" .. self.path .. self.filename 

	self.interval = .1
	self._timer = 0

	self.lastEdit = os.time()

	if not self.isOpen then
		self.isOpen = false
	end

	self.artList = buddies.new(self)

	self.inCutscene = false
	self.base = true

	self.z = 0

	self.visible = true

	self.canvasWidth = 130
	self.canvasHeight = 30
	self.inventoryWidth = 38

	self.narrator = ""

	self.onItemList = {}

	self.player = Game.player
	self.inventory = Player.inventory

	self.tick = tick.group()
end


function File:postNew()
	self.inited = true
	if self.content then
		self.content = self.frames[self.anim:getRealFrame()]
		if not self.canvas then
			self:makeCanvas()
			self:makeNarrator()
			self:makeOptions()
			self:makeHealth()
			self:makeGold()
			self:makeInventory()
		end
	end

	self:draw()
end


function File:update(dt)
	self.tick:update(dt)

	local last = self:getLastMod()
	if not self.isOpen then

		if last > self.lastEdit then
			self.tick:delay(0.05, function ()
				self:onOpen()
			end)
			self.lastEdit = last
		else
			return
		end
	end

	for i,v in ipairs(self.artList) do
		if v ~= self then
			v:update(dt)
		end
	end

	Art.update(self, dt)

	if self.anim.loops >= 4 then
		self.anim:stop()
		self.anim:setFrame(1)
	end

	self._timer = self._timer + dt
	if self._timer > self.interval then
		local last = self:getLastMod()

		if last > self.lastEdit then
			self.lastEdit = last
			self:onEdit()
		else
			if lume.any(self.artList,function (art) return art.hasChanged end) then
				self:draw()
			end
		end
		self._timer = self._timer - self.interval
	end
end


function File:addArt(art)
	self.artList:add(art)
end


function File:draw()
	if self.dead then return end

	self.artList:set("hasChanged", false)
	self.artList:format()

	self:clearCanvas()
	self:centerArt(self)
	
	self.artList:sort("z")

	for i,v in ipairs(self.artList) do
		if v.visible then
			self:drawOnCanvas(v)
		end
	end

	self:drawNarrator()
	self:drawOptions()
	self:drawHealth()
	self:drawGold()
	self:drawInventory()
	self:write()
end


function File:drawOnCanvas(art, x, y)
	x = math.floor(x or art.x)
	y = math.floor(y or art.y)

	local lines = self.canvas.lines

	for i,v in ipairs(art.lines) do
		local spaces = v:match("(%s*)") or " "
		local text = v:match("%s*(.+)") or ""

		if spaces == "\n" then
			spaces = ""
		end

		local xx = x + spaces:len() + 1
		local yy = y + i + 1

		-- Check if this line appears in the canvas.
		if yy > 1 and yy < self.canvasHeight + 2 then
			
			local len = text:len()
			local lennn = math.min(xx + len, self.canvasWidth) - xx
			line = lines[yy]
			line_len = lines[yy]:len()
			if xx + len > 1 and xx < self.canvasWidth then
				local left = xx <= 0
				local right = xx + len > self.canvasWidth-1
				if left and right then
					lines[yy] = line:sub(2,xx) .. text:sub(math.abs(xx) + 1, lennn) .. line:sub(line_len, 1)
				elseif left then
					lines[yy] = line:sub(1,1) .. text:sub(math.abs(xx) + 1, len) .. line:sub(xx + len + 2, line_len)
				elseif right then
					lines[yy] = line:sub(1,xx) .. text:sub(1, lennn-1) .. line:sub(self.width, self.width)
				else
					lines[yy] = line:sub(1,xx) .. text .. line:sub(xx + text:len() + 1, line_len)
				end
			end
		end
	end

	local str = ""
	for i,v in ipairs(lines) do
		str = str .. v
		if i < #lines then
			str = str .. "\n"
		end
	end

	self.canvas.lines = lines
	self.canvas.content = str
end


function File:kill()
	self.dead = true
	love.filesystem.remove(self.file)
end


function File:getLastMod()
	local info = love.filesystem.getInfo(self.file)
	if not info then
		self:write()
		return 0
	end
	local last = info.modtime
	if not last and not self.dead then
		self:write()
		return os.time()
	end
	return last
end


function File:write()
	if self.dead then return end

	love.filesystem.write(self.file, self.canvas.content)
	self.lastEdit = os.time()
end


function File:onOpen()
	Game:closeFiles()
	self.isOpen = true
	self.inited = false
	if not self:is(Scene) then
		self:new()
		self:postNew()
		self:draw()
	else
		self:new(self.sceneObject)
		self:postNew()
		self:draw()
	end
end


function File:onEdit()
	self:checkOptions()
	self:checkItems()
	self:draw()
end


function File:checkOptions()
	if not self.options then return end
	self.rContent = love.filesystem.read(self.file)
	local i = 1
	local default = nil
	local defaultPos = nil

	for i,v in ipairs(self.options) do
		if not v.condition or v.condition() then
			if v.default then
				default = v
				defaultPos = i
			end

			local a = self.rContent:match("%[([^%]]+)%]%s%-%s" .. Utils.litString(v.text:gsub("%[username%]", Player.name)))

			if a and a ~= "" then
				self:onSelectedOption(v, i)

				if Events.postLament then
					SAVE.exists = true
					SAVE.Events = Events
					SAVE.name = self.player.name
					SAVE.pronoun = self.player.pronoun
					SAVE.inventory = self.player.inventory
					SAVE.gold = self.player.gold
					love.filesystem.write(".data", lume.serialize(DATA))
				end
				return
			end
		end
	end

	if default then
		self:onSelectedOption(default, defaultPos)
	end

end


function File:onSelectedOption(v, i)
	self.hasChanged = true

	if v.item then
		local t = lume.clone(Items[v.item])
		t.tag = v.item
		if t.weapon then
			self.player.weapon = t
		end
		table.insert(self.inventory, t)
	end

	if v.event then
		Events[v.event] = true
	end

	if v.func then
		v.func()
	end

	if v.anim then
		self.anim:set(v.anim)
	end

	if v.gold then
		self.player.gold = self.player.gold + v.gold
	end

	if v.response then
		self:setText(v.response)
	end

	if v.remove then
		table.remove(self.options, i)
	end

	if v.options then
		self.base = false
		self.options = v.options
	end

	if v.onItem then
		table.insert(self.onItemList, v.onItem)
	end
end


function File:checkItems()
	self.rContent = love.filesystem.read(self.file)
	if not self.rContent then return end

	for i,v in ipairs(self.inventory) do

		local a = self.rContent:match("%[([^%]]+)%]" .. Utils.litString(v.name))

		if a and a ~= "" then
			for j,w in ipairs(self.onItemList) do
				if w.request == v.tag then
					self:onItem(w)
					return
				end
			end

			-- Default action for this item
			self:onItemActionless(v)
		end
	end
end


function File:removeItem(item)
	for i,v in ipairs(self.inventory) do
		if v.tag == item then
			table.remove(self.inventory, i)
			return
		end
	end
end


function File:onItem(e)
	if e.func then
		e.func()
	end

	if e.response then
		self:setText(e.response)
	end

	if e.anim then
		self.anim:set(e.anim)
	end

	if e.remove then
		self:removeItem(e.request)
	end

	if e.event then
		Events[e.event] = true
	end

	if e.gold then
		self.player.gold = self.player.gold + e.gold
	end

	if e.options then
		self.options = e.options
	end
end


function File:onItemActionless(e)
	if (not self.base) or self.fight or self.inCutscene then
		return
	end

	if e.art then
		Art.new(self, e.art)
		self:setOptions({
			{
				text = "Back.",
				func = F(self, "new")
			}
		})
	end

	if e.text then
		self:setText(e.text)
	end
end


function File:hasItem(item)
	return lume.any(self.inventory, function (a) return a.tag == item end)
end


function File:makeCanvas(width, height)
	width = self.canvasWidth
	height = self.canvasHeight

	local topbot = " " .. Utils.makeString("=", width) .. " "
	local line = "|" .. Utils.makeString(" ", width) .. "|"
	local cnvs = topbot .. "\n"
	cnvs = cnvs .. Utils.makeString(line .. "\n", height)
	cnvs = cnvs .. topbot

	self.clearCanvasString = cnvs
	self.canvas = Art()
	self.canvas:setArt(cnvs)
end


function File:makeNarrator()
	width = self.canvasWidth
	height = 3

	local topbot = " " .. Utils.makeString("=", width) .. " "
	local line = "|[T]{{" .. Utils.makeString(" ", width) .. "}}|"
	local cnvs = topbot .. "\n"
	cnvs = cnvs .. Utils.makeString(line .. "\n", height)

	self.narratorBox = Art()
	self.narratorBox:setArt(cnvs)
end


function File:makeOptions()
	width = self.canvasWidth
	height = 4

	local topbot = " " .. Utils.makeString("=", width) .. " "
	local line = "|[T]{{" .. Utils.makeString(" ", width) .. "}}|"
	local cnvs = ""
	cnvs = cnvs .. Utils.makeString(line .. "\n", height)
	cnvs = cnvs .. topbot

	self.optionsBox = Art()
	self.optionsBox:setArt(cnvs)
end


function File:makeHealth()
	width = self.inventoryWidth
	height = 1

	local topbot = Utils.makeString("=", width) .. " "
	local line = "[T]{{" .. Utils.makeString(" ", width) .. "}}|"
	local cnvs = ""
	cnvs = topbot .. "\n" .. "             -- Health --             |" .. "\n" .. topbot
	cnvs = cnvs .. "\n" .. line .. "\n" .. topbot

	self.healthBox = Art()
	self.healthBox:setArt(cnvs)
	self.healthBox.referal = self.player
	self.healthBox.text = "                   [V]{{health}}"
end


function File:makeGold()
	width = self.inventoryWidth
	height = 5

	local topbot = Utils.makeString("=", width) .. " "
	local line = "[T]{{" .. Utils.makeString(" ", width) .. "}}|"
	local cnvs = ""
	cnvs = topbot .. "\n" .. "              -- Gold --              |" .. "\n" .. topbot
	cnvs = cnvs .. "\n" .. line .. "\n" .. topbot

	self.goldBox = Art()
	self.goldBox:setArt(cnvs)
	self.goldBox.referal = self.player
	self.goldBox.text = "                   [V]{{gold}}"
end


function File:makeInventory()
	width = self.inventoryWidth
	height = 30

	local topbot = Utils.makeString("=", width) .. " "
	local line = "[T]{{" .. Utils.makeString(" ", width) .. "}}|"
	local cnvs = ""
	cnvs = topbot .. "\n" .. "            -- Inventory --           |" .. "\n" .. topbot .. "\n"

	cnvs = cnvs .. Utils.makeString(line .. "\n", height-1)
	cnvs = cnvs .. topbot

	self.inventoryBox = Art()
	self.inventoryBox:setArt(cnvs)
end


function File:drawNarrator()
	self.narratorBox.text = self.narrator
	self.narratorBox:format()
	self.canvas:setArt(self.narratorBox.content .. self.canvas.content)
end


function File:drawOptions()
	local text = ""
	if self.options then
		for i,v in pairs(self.options) do
			if not v.condition or v.condition() then
				text = text .. "[] - " .. v.text:gsub("%[username%]", Player.name)
				if i < #self.options then
					text = text .. "\n"
				end
			end
		end
	end

	self.optionsBox.text = text
	self.optionsBox:format()
	self.canvas:setArt(self.canvas.content .. "\n" .. self.optionsBox.content)
end


function File:drawHealth()
	self.healthBox:format()
	local lines = self.canvas.lines
	for i,v in ipairs(lines) do
		lines[i] = v .. self.healthBox.lines[i] 
		if i == 4 then
			break
		end
	end

	local str = ""
	for i,v in ipairs(lines) do
		str = str .. v
		if i < #lines then
			str = str .. "\n"
		end
	end

	self.canvas:setArt(str)

	self.canvas:format()
end

function File:drawGold()
	self.goldBox:format()
	local lines = self.canvas.lines
	for i,v in ipairs(lines) do
		if i > 4 then
			lines[i] = v .. self.goldBox.lines[i - 4]
			if i == 8 then
				break
			end
		end
	end

	local str = ""
	for i,v in ipairs(lines) do
		str = str .. v
		if i < #lines then
			str = str .. "\n"
		end
	end

	self.canvas:setArt(str)

	self.canvas:format()
end


function File:drawInventory()

	local text = ""
	if self.inventory then
		for i,v in pairs(self.inventory) do
			text = text .. "[]" .. v.name .. "\n"
		end
	end

	self.inventoryBox.text = text
	self.inventoryBox:format()

	local lines = self.canvas.lines
	for i,v in ipairs(lines) do
		if i > 8 then
			lines[i] = v .. self.inventoryBox.lines[i - 8]
		end
	end

	local str = ""
	for i,v in ipairs(lines) do
		str = str .. v
		if i < #lines then
			str = str .. "\n"
		end
	end

	self.canvas:setArt(str)

	self.canvas:format()
end


function File:setText(text)
	local pronouns = {
		he = {
			he = "he",
			him = "him",
			his = "his",
			He = "He",
			Him = "Him",
			His = "His",
			was = "was"
		},
		she = {
			he = "she",
			him = "her",
			his = "her",
			He = "She",
			Him = "Her",
			His = "Her",
			was = "was"
		},
		they = {
			he = "they",
			him = "them",
			his = "their",
			He = "They",
			Him = "Them",
			His = "Their",
			was = "were"
		}
	}

	text = text:gsub("%[he%]", pronouns[Player.pronoun].he)
	text = text:gsub("%[him%]", pronouns[Player.pronoun].him)
	text = text:gsub("%[his%]", pronouns[Player.pronoun].his)
	text = text:gsub("%[He%]", pronouns[Player.pronoun].He)
	text = text:gsub("%[Him%]", pronouns[Player.pronoun].Him)
	text = text:gsub("%[His%]", pronouns[Player.pronoun].His)
	text = text:gsub("%[was%]", pronouns[Player.pronoun].was)

	text = text:gsub("%[username%]", Player.name)

	self.narrator = text
	if self.narrator:len() <= self.canvasWidth then return end

	local pos = 0

	local text = ""
	while true do
		local t = self.narrator:sub(pos, self.narrator:len())

		if t:len() <= self.canvasWidth then
			text = text .. t
			break
		end

		local indexnl = t:find("\n")
		if indexnl and indexnl <= self.canvasWidth then
			text = text .. t:sub(1, indexnl)
			pos = text:len() + 1 
		else

			local i = 1

			repeat 
				t = self.narrator:sub(text:len(), text:len() + self.canvasWidth - i)
				i = i + 1
			until t:sub(t:len(), t:len()):find("[%s?!.,]")
			local ends_on_nl = text:sub(text:len()-1, text:len()-1) == "\n"
			text = text .. t .. (ends_on_nl and "" or "\n")
			pos = text:len()-1
		end
	end

	self.narrator = text
end


function File:centerArt(art)
	art.x = math.ceil((self.canvasWidth - art.width)/2)
	art.y = math.ceil((self.canvasHeight - art.height)/2)
end


function File:clearCanvas()
	self.canvas:setArt(self.clearCanvasString)
end


function File:setOptions(t)
	self.options = t
end


function File:setOnItems(t)
	self.onItemList = t
end