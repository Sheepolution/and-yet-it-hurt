local Forest = File:extend()

Forest.step = 1

function Forest:new(goal)
	Forest.super.new(self, "forest")
	Art.new(self, "forest")

	self.animals = {"boar", "bear", "snake", "bat"}

	if goal then
		Forest.goal = goal
	end

	self:setText([[[username] walked through the forest.]])
	self:setOptions({
		{
			text = "Continue walking.",
			func = function () self:walk() end
		},
		{
			text = "Go back.",
			options = {},
			func = function () self:goBack() end
		}
	})
end

function Forest:update(dt)
	Forest.super.update(self, dt)
end

function Forest:draw()
	Forest.super.draw(self)
end

function Forest:walk()
	if Forest.step == 3 then
		self.player:regainHealth()
		self:setText("Finally, [username] got out of the forest.")
		self:setOptions({})
		if Forest.goal == "east" then
			self:loadEast()
		else
			self:loadWest()
		end
		Forest.goal = nil
		Forest.step = 1
		return
	elseif Events.passedForest then
		local animal = table.remove(self.animals, math.random(1, #self.animals))
		print(animal)
		Game:replaceFile("forest", require(animal)("forest", "forest"))
	elseif Forest.step == 1 then
		Game:replaceFile("forest", require("bat")("forest", "forest"))
	else
		Game:replaceFile("forest", require("boar")("forest", "forest"))
	end
	Forest.step = Forest.step + 1
	self.dead = true
end

function Forest:goBack()
	self.player:regainHealth()
	self:setText("[username] decided to walk back and got out of the forest.")
	self:setOptions({})
	self.deleteOnClose = true
	if Forest.goal == "east" then
		self:loadWest()
	else
		self:loadEast()
	end
end

function Forest:loadEast()
	self.deleteOnClose = true
	Game:addFile(require("westown_gate")())
	Game:addFile(require("dragonhill_gate")())
	Game:addFile(require("edbur_post_lament")())
	Game:addFile(require("elli")())
end

function Forest:loadWest()
	Events.passedForest = true
	self.deleteOnClose = true
	Game:addFile(require("eastown_gate")())
	Game:addFile(require("castle_gate")())
	Game:addFile(require("armor_shop")())
	Game:addFile(require("smith")())
	if not Events.movedAnn then
		Game:addFile(require("ann")())
	end
end

function Forest:resetStep()
	Forest.step = 1
end

function Forest:__tostring()
	return lume.tostring(self, "Forest")
end

return Forest