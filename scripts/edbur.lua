local Edbur = File:extend()

function Edbur:new()
	Edbur.super.new(self, "weapon_shop")
	Art.new(self, "weapon_shop")

	self.anim:add("laughing", 2)
	self.anim:add("hand", 3)
	self.anim:add("idle", 1)

	if Events.gavePantsToEdbur then
		self:setText([["Where did you go?" said Edbur. "I told you to wait here."]])
		self:setOptions({
				{
					text = [["Sorry."]],
					response = [[Edbur gave [username] a dagger. "Here you go, your very own weapon."]],
					item = "dagger",
					func = function ()
						Game:removeFile("home")
						Game:removeFile("house")
						Game:removeFile("grocery_store")
					end,
					options = {
						{
							text = [["Thanks!"]],
							anim = "laughing",
							response = [[Holding the dagger brought a bright smile on [username]'s face. It made [him] feel strong, like [he] could take on the world. "Thank you so much Edbur!" said [username]. "Rgharharharha", laughed Edbur. "No problem kiddo, but be careful not to-"]],
							options = {
								{
									text = "Continue.",
									func = F(self, "event", 1)
								}
							}
						}
					}
				}
			}
		)
		return
	end

	self:setText([["Well hello there, [username]," said Edbur, a large and old man who despite his age was still one of the strongest in town. Edbur was good friends with [username]'s father. "What can I do for you?"]])

	self:setOnItems({
	{
		request = "pantsEdbur",
		response = [[[username] handed Edbur his pants. "Very good, here is 30 gold. And you know what? I'll give you something extra! Wait here."]],
		gold = 30,
		remove = true,
		anim = "idle",
		event = "gavePantsToEdbur",
		options = {
			{
				text = "Wait.",
				response = [[Edbur goes to the back of his shop and comes back with a dagger. "Here you go, your very own weapon."]],
				item = "dagger",
				func = function ()
					Game:removeFile("home")
					Game:removeFile("house")
					Game:removeFile("grocery_store")
				end,
				options = {
					{
						text = [["Thanks!"]],
						anim = "laughing",
						response = [[Holding the dagger brought a bright smile on [username]'s face. It made [him] feel strong, like [he] could take on the world. "Thank you so much Edbur!" "Rgharharharha", laughed Edbur. "No problem kiddo, but be careful not to-"]],
						options = {
							{
								text = "Continue.",
								func = F(self, "event", 1)
							}
						}
					}
				}
			}
		}
	}})

	self:setOptions({
		{
			text = [["I want to buy a weapon"]],
			response = [["Rgharharharha", laughed Edbur. "What does a kid like you need a weapon for? You don't have enough gold anyway."]],
			anim = "laughing",
			remove = true
		},
		{
			condition = F(self, "hasItem", "pantsEdbur"),
			text = [["I brought your pants"]],
			response = [["Ah great, hand them over"]],
			anim = "hand",
			options = {},
		}
	})
end


function Edbur:update(dt)
	Edbur.super.update(self, dt)
end


function Edbur:draw()
	Edbur.super.draw(self)
end


function Edbur:event(i)
	self:loadArt("edbur")
	self.anim:add("idle", 1)
	Events.bellRang = true
	self:setOptions({
		{
			text = "Continue.",
			default = true,
			func = F(self, "event", i + 1)
		}
	})

	if i == 1 then
		self:loadArt("weapon_shop")
		self.anim:add("idle", 1)
		self:setText([[Edbur was suddenly interrupted by the tower bell. He looked frightened, something that [username] had never seen before from the strong and brave Edbur. "30 years...," said Edbur, staring into the distance.]])
	elseif i == 2 then
		self:setText([["What's going on?", asked [username]. Edbur grabbed [username] by the shoulders. "That bell means that a dragon is heading our way."]])
	elseif i == 3 then
		self:setText([[Never before had [username] seen a dragon. But from the tales [he] heard about the creatures, and from Edbur's reaction, [he] knew that the town and everyone's live was in danger.]])
	elseif i == 4 then
		Game:addFile(require "dragon_burning_home")
		Game:addFile(require("elli")())
		self.deleteOnClose = true
		self:setText([["Listen carefully [username], I need you to be brave and make sure your parents are safe, their sheep might lure the dragon towards them. After I put on my pants I will head in the same direction."]])
		self:setOptions({})
	end

end


function Edbur:__tostring()
	return lume.tostring(self, "Edbur")
end

return Edbur