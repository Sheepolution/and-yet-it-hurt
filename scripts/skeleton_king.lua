local SkeletonKing = Fight:extend()

function SkeletonKing:new(...)
	SkeletonKing.super.new(self, ...)
	Art.new(self, "skeleton_king")

	self.enemyName = "Skeleton King"

	self.anim:add("attacking", 1);
	self.anim:add("defending", 1);
	self.anim:add("prepareAttack", 2);
	self.anim:add("prepareDefense", 1);

	self.health = 200

	self.attack = 5
	self.timeAttacking = 7
	self.timeDefending = 2

	self.strength = 10

	self.description = "[username] and the Skeleton King approached each other and found themselves in the center of the throne room."
	self.attackDescription = "The Skeleton King swung its sword at [username]"
	self.prepareAttackDescription = "Then the Skeleton King raised its sword!"
end


function SkeletonKing:update(dt)
	SkeletonKing.super.update(self, dt)
end


function SkeletonKing:draw()
	SkeletonKing.super.draw(self)
end


function SkeletonKing:__tostring()
	return lume.tostring(self, "SkeletonKing")
end

return SkeletonKing