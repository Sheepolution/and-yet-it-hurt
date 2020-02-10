local ThroneRoom = File:extend()

function ThroneRoom:new(text)
	ThroneRoom.super.new(self, "castle")

	Art.new(self, "throne_room")
	self.player.health = 100

	self:setText([[[username] opened two big doors, and [he] found [him]self inside a huge room. At the end of the room there stood a throne, occupied by a skeleton. The skeleton moved. It talked. "Who goes there?" it said.]])
	self:setOptions({
		{
			text = [["Give me that sword!"]],
			response = [["What? Give my precious Nightblood to you?" said the skeleton. "You're just like that kid from 30 years ago."]],
			options = {
				{
					text = [["If you won't give me the sword I'll have to kill you."]],
					response = [["Kill me?!", the skeleton shouted angrily. "You dare to even suggest that you have the ability to release me from this curse I have bestowed upon myself? Come then. I'll show you that which I desire the most. Death."]],
					options = {
						{
							text = "Fight the Skeleton King.",
							func = F(self, "fight")

						}
					}
				},
				{
					text = [["Who are you talking about?"]],
					response = [["The fool! He got lucky that he was able to escape with a mere scar. After all these years I still laugh thinking about it." And indeed, the skeleton laughed.]],
					remove = true
				}
			},
		},
		{
			text = [["My name is [username]."]],
			response = [["Greetings, [username]. My name is Lord Theodore IV, the Immortal, Defier of Death, Lord Bones, the Skeleton King. What does a kid like you seek in my monstrous castle?"]],
			remove = true
		}
	})
end

function ThroneRoom:fight()
	self.dead = true
	Game:replaceFile("castle", require("skeleton_king")("castle", "skeleton_king_defeat"))
end

return ThroneRoom