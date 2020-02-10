local SkeletonKingDefeat = File:extend()

function SkeletonKingDefeat:new(text)
	SkeletonKingDefeat.super.new(self, "castle")

	Art.new(self, "dead_skeleton_king")
	self.anim:add("nosword", 2)
	self.anim:add("shake", {3, 4, 3, 4, 3, 4, 2}, 12, "once")
	self.anim:add("idle", 1)

	Events.skeletonKingDefeated = true

	self.player:regainHealth()

	self:setText([["Th-thank you," said the skull, followed by complete silence in the throne room.]])
	self:setOptions({
		{
			text = [[Grab the sword.]],
			anim = "nosword",
			item = "nightblood",
			response = "[username] grabbed the sword. As [he] held Nightblood in [his] hand [he] immediately felt its incredible power.",
			options = {
				{
					text = [[Go back.]],
					response = [[Suddenly, the whole castle started shaking. The roof was falling apart. [username] knew that [he] had little time.]],
					anim = "shake",
					options = {
						{
							text = "Run.",
							func = F(self, "run")
						}
					}
				}
			}
		}
	})
end

function SkeletonKingDefeat:run()
	Game:replaceFile("castle", require("castle")("[username] ran through the corridors, dodging the bricks that fell from the roof. And just as [username] had escaped the castle, it collapsed into rubble."))
end

return SkeletonKingDefeat