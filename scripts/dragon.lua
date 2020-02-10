local Dragon = Fight:extend()

function Dragon:new(...)
	Dragon.super.new(self, ...)
	Art.new(self, "dragon")

	self.enemyName = "dragon"

	self.anim:add("attacking", 3);
	self.anim:add("defending", 1);
	self.anim:add("prepareAttack", 2);
	self.anim:add("prepareDefense", 1);

	self.health = 750

	self.attack = 7
	self.timeAttacking = 8
	self.timeDefending = 3

	self.strength = 20

	self.description = "[username] approached the dragon, who took note of [username]'s presence and started to roar. The battle was on."
	self.attackDescription = "The dragon spew its flames at [username]"
	self.prepareAttackDescription = "Then the dragon opened its mouth."
end

return Dragon