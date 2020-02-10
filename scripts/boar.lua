local Boar = Fight:extend()

function Boar:new(...)
	Boar.super.new(self, ...)
	Art.new(self, "boar")

	self.enemyName = "boar"

	self.anim:add("attacking", 1);
	self.anim:add("defending", 1);
	self.anim:add("prepareAttack", 2);
	self.anim:add("prepareDefense", 1);

	self.health = 20

	self.attack = 1
	self.timeAttacking = 3
	self.timeDefending = 6

	self.strength = 25

	self.description = "Suddenly, [username] encountered a boar. They take a while to prepare their attack, but once they're ready it's over before you know it."
	self.attackDescription = "The boar rushed at [username]"
	self.prepareAttackDescription = "Then the boar was preparing for an attack!"
end


function Boar:update(dt)
	Boar.super.update(self, dt)
end


function Boar:draw()
	Boar.super.draw(self)
end


function Boar:__tostring()
	return lume.tostring(self, "Boar")
end

return Boar