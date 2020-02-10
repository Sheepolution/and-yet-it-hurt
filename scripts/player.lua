Player = Object:extend()

Player.inventory = {
}

Player.gold = 0
Player.pronoun = "he"
Player.name = "Jonathan"

function Player:new(...)

	self:regainHealth()
end


function Player:getStrength()
	return self.weapon.strength
end


function Player:takeDamage(damage)
	if Events.helmetBought then
		damage = math.ceil(damage - (damage*.2))
	end
	self.health = self.health - damage
	if self.health <= 0 then
		self.health = 0
		return true
	end
end


function Player:regainHealth()
	self.health = 100

	if Events.breastplateBought then
		self.health = self.health + 50
	end
end


function Player:__tostring()
	return lume.tostring(self, "Player")
end