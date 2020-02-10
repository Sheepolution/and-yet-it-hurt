Fight = File:extend()

function Fight:new(name, location)
	Fight.super.new(self, name)
	self.toLocation = location

	self.state = "attacking"
	self.fight = true

	self.pauseTimer = 5

	self.defeatedEnemy = false

	self.coil = coil.group()
	self.startedFight = false
	self.pointsHaveBeenDrawn = false
	self.blinking = false
end

function Fight:postNew()
	if Events.shieldBought then
		self.timeAttacking = self.timeAttacking + 1
	end
	if Events.gauntletsBought then
		self.timeDefending = self.timeDefending + 1
	end
	self.fightTimer = self.timeAttacking
	if self.timeAttacking == math.huge then
		self:setText(self.description .. "\n(Save to continue)")
	else
		self:setText(self.description .. "\nAttack time: " .. self.timeDefending .. " seconds. Block time: " .. self.timeAttacking .. " seconds.\n(Save to continue)")
	end
	Fight.super.postNew(self)
end


function Fight:update(dt)
	Fight.super.update(self, dt)
	if self.isOpen then
		if self.fightStarted and not self.playerDead and not self.defeatedEnemy then
			self.coil:update(dt)
			self.fightTimer = self.fightTimer - dt
			if self.fightTimer < 0 then
				self:endState()
			end
		end
	end
end


function Fight:write()
	if not self.playerDead then
		if self.state == "prepareAttack" then --The ENEMY is PREPARING
			if not self.pointsHaveBeenDrawn then
				self:drawDefensePoints()
				self.pointsHaveBeenDrawn = true
			end
		elseif self.state == "prepareDefense" then --THE ENEMY is DEFENDING
			if not self.pointsHaveBeenDrawn then
				self:drawAttackPoints()
				self.pointsHaveBeenDrawn = true
			end
		else
			self.pointsHaveBeenDrawn = false
		end
	end
	Fight.super.write(self)
end


function Fight:drawAttackPoints()
	self:drawTable("<{  }>", self:createPoints(self.player.weapon.attack))
end


function Fight:drawDefensePoints()
	self:drawTable("<{ x }>", self:createPoints(self.attack))
end


function Fight:createPoints(amount)
	local t = {}
	local check = {}
	for i=1,amount do
		local x, y
		repeat
			x = math.random(1, 5)
			y = math.random(1, 20)
		until not check[x .. "+" .. y]
		table.insert(t, {x, y})
		check[x .. "+" .. y] = true
	end
	return t
end


function Fight:drawTable(symbol, table)
	local lines = self.canvas.lines
	local len = symbol:len()/2

	for i,v in ipairs(lines) do
		for j,w in ipairs(table) do
			local x = self.canvasWidth/2 - 20 + w[1] * 7 + 2
			local y = (self.canvasHeight + 8 )/2 - 10 + w[2] + 2
			if i == y then
				lines[i] = lines[i]:sub(0, x - math.floor(len)-1) .. symbol .. lines[i]:sub(x + math.ceil(len), lines[i]:len())
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


function Fight:drawOptions()
	local text = [[                                                             [V]{{health}} health]]
	if self.state == "prepareAttack" then
		text = [[                                                             [V]{{health}} health
                                                              [V]{{timeAttacking}} seconds]]

	elseif self.state == "prepareDefense" then
		text = [[                                                             [V]{{health}} health
                                                              [V]{{timeDefending}} seconds]]
	end
	
	self.optionsBox.text = text
	self.optionsBox.referal = self
	self.optionsBox:format()
	self.canvas:setArt(self.canvas.content .. "\n" .. self.optionsBox.content)
end


function Fight:switchState()
	if self.state == "prepareAttack" then
		self.state = "attacking"
	elseif self.state == "attacking" then
		self.state = "prepareDefense"
	elseif self.state == "prepareDefense" then
		self.state = "defending"
	elseif self.state == "defending" then
		self.state = "prepareAttack"
	end
end


function Fight:countFilledPoints()
	local content = love.filesystem.read(self.file)
	content = content:sub(549, 5807)

	local filled = 0
	local found = 0

	for point in content:gmatch("<{([^}]+)}>") do
		found = found + 1
		if point:find("%S") then
			filled = filled + 1
		end
	end

	return filled, found
end


function Fight:endState()
	if self.defeatedEnemy then
		self:onVictory()
		return
	end

	if self.playerDead then
		return
	end

	local filled, found = self:countFilledPoints()

	--What WAS the state?
	local damage, dead
	if self.state == "prepareDefense" then
		damage = self:resolveDamageTaken(filled, found)
	elseif self.state == "prepareAttack" then
		damage, dead = self:resolveDamageGiven(filled, found)
	end

	self:updateDescription(self.state, damage, dead)
	if dead then
		self.hasChanged = true
		self.playerDead = true
		self:onPlayerDead()
		return
	end

	self:switchState()

	self.anim:trySet(self.state)

	if self.state == "prepareDefense" then
		self.fightTimer = self.timeDefending
	elseif self.state == "prepareAttack" then
		self.fightTimer = self.timeAttacking
	else
		self.fightTimer = math.huge
	end

	self.hasChanged = true
end


function Fight:onEdit()
	self.fightStarted = true
	if not self.blinking then
		self:endState()
	end
end


function Fight:updateDescription(state, damage, dead)
	if dead then
		self:resetStep()
		self:setText(self.attackDescription .. " and dealt " .. damage .. " damage! It was the end of [username].")
		return
	end

	if self.state == "prepareDefense" then
		self:setText("[username] swung " .. Game.player.weapon.attackName .. " and dealt " .. damage .. " damage!\n(Save to continue)")
		self:setOptions({
			{
				text = "Continue."
			}
		})
	elseif self.state == "defending" then
		self:setOptions({})
		self:setText(self.prepareAttackDescription .. " [username] tried to defend [him]self.")
	elseif self.state == "prepareAttack" then
		self:setOptions({
			{
				text = "Continue."
			}
		})
		if damage == 0 then
			self:setText(self.attackDescription .. " but the attack was blocked!\n(Save to continue)")
		else
			self:setText(self.attackDescription .. " and dealt " .. damage .. " damage!\n(Save to continue)")
		end
	elseif self.state == "attacking" then
		self:setOptions({})
		self:setText("It was then that [username] had a chance to attack!")
	end
end


function Fight:resolveDamageTaken(filled, found)
	if found > self.player.weapon.attack then
		filled = 0
	end

	local damage = filled * self.player:getStrength()
	self.health = self.health - damage

	if self.health <= 0 then
		self.health = 0
	end

	if damage > 0 then
		self:blink()
	end
	return damage
end


function Fight:resolveDamageGiven(filled, found)
	if found ~= self.attack then
		filled = math.min(self.attack, math.max(0, filled + (self.attack - found)))
	end

	local damage = filled * self.strength
	return damage, self.player:takeDamage(filled * self.strength)
end


function Fight:blink()
	self.blinking = true
	self.coil:add(function ()
		for i=1,4 do
			coil.wait(0.12)
			self.hasChanged = true
			self.visible = not self.visible
		end

		self.blinking = false
		if self.health > 0 then
			self.visible = true
		else
			self.health = 0
			self.visible = false
			self.defeatedEnemy = true
			self:setText("At last, the " .. self.enemyName .. " was defeated.\n(Save to continue)")
		end
	end)
end


function Fight:onPlayerDead()
	self.deleteOnClose = true
	Game:addFile(require("edbur_post_lament")(nil, true))
end


function Fight:onVictory()
	Game:replaceFile(self.name, require(self.toLocation)())
end

function Fight:resetStep()

end