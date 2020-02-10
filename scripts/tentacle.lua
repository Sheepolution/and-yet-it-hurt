local Tentacle = Fight:extend()

function Tentacle:new(...)
	Tentacle.super.new(self, ...)
	Art.new(self, "tentacle")

	self.enemyName = "tentacle monster"

	self.anim:add("attacking", 1);
	self.anim:add("defending", 1);
	self.anim:add("prepareAttack", 1);
	self.anim:add("prepareDefense", 1);

	self.health = 90

	self.attack = 2
	self.timeAttacking = 4
	self.timeDefending = 3

	self.strength = 15

	self.description = "Suddenly, a tentacle monster popped out of the ground. "
	self.attackDescription = "The tentacle monster flung himself at [username]"
	self.prepareAttackDescription = "Then the tentacle monster was preparing for an attack!"
end

return Tentacle