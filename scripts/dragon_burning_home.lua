local scene = {
	isScene = true,
	name = "home",
	art = "dragon_burning_home",
	anims = function (self)
		self.anim:add("eye", 2)
		self.anim:add("charge", 3)
		self.anim:add("stopped", 4)
		self.anim:add("Edbur", 5)
		self.anim:add("dragon", 6)
		self.anim:add("dragon_burning", 1)
	end,
	scenes = {
		{
			anim = "dragon_burning",
			text = "With the town in turmoil [username] rushed towards [his] home. Upon arrival [his] biggest fear became reality. The dragon, more terrifying than [username] had imagined, spew its blazing flames straight onto [his] home.",
			func = function () Game:removeFile("house") end
		},
		{
			anim = "eye",
			text = "[username] watched as the flames destroyed everything [he] owned, everything [he] loved. [He] could hear the screams of [his] parents pierce through the burning walls.",
		},
		{
			anim = "charge",
			text = "[username] looked at [his] dagger in [his] hand. Rushed with emotions [his] mind had no room for any rational thought. [He] held up the dagger and rushed towards the dragon.",
		},
		{
			anim = "stopped",
			text = "But before [he] could get even close to the dragon [he] [was] grabbed by the arm.",
		},
		{
			anim = "Edbur",
			text = [[It was Edbur. "What do you think you're doing?! Do you want to die?!", he yelled at [username].]],
		},
		{
			anim = "dragon",
			text = [[[username] took a second to collect [his] thoughts, all [his] mixed emotions suddenly turned into grief as [he] hugged Edbur. "Come," said Edbur as the dragon made its leave, "you can rest at my place."]],
			func = function ()
				Game:addFile(require("scenes.players_lament"))
			end
		}
	}
}

return Scene(scene)