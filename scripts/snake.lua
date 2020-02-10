local Snake = Fight:extend()

function Snake:new(...)
	Snake.super.new(self, ...)
	Art.new(self, "snake")

	self.enemyName = "snake"

	self.anim:add("attacking", 1);
	self.anim:add("defending", 1);
	self.anim:add("prepareAttack", 1);
	self.anim:add("prepareDefense", 1);

	self.health = 50

	self.attack = 2
	self.timeAttacking = 2.5
	self.timeDefending = 2.5

	self.strength = 10

	self.description = "Suddenly, [username] encountered a snake. They are very fast, making them hard to attack and doge their fangs."
	self.attackDescription = "The snake aimed its fangs at [username]"
	self.prepareAttackDescription = "Then the snake was preparing for an attack!"
end


function Snake:update(dt)
	Snake.super.update(self, dt)
end


function Snake:draw()
	Snake.super.draw(self)
end

return Snake