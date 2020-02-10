local scene = {
	isScene = true,
	name = "weapon_shop",
	art = "players_lament",
	anims = function (self)
		self.anim:add("bed", 2)
		self.anim:add("food", 3)
		self.anim:add("edbur_sad", 4)
		self.anim:add("sun", 5)
		self.anim:add("edbur_smiling", 6)
		self.anim:add("edbur_angry", 7)
		self.anim:add("eye", 8)
		self.anim:add("edbur_neutral", 9)
		self.anim:add("door", 1)
	end,
	
	onOpen = function ()
		Game:removeFile("home")
	end,

	scenes = {
		{
			anim = "door",
			text = [[Edbur slowly opened the door. "[username], are you awake?". As usual, [username] didn't respond.]]
		},
		{
			anim = "bed",
			text = [["It's been 3 days. I know this must be hard on you, but you can't just lay in bed all day." Still no response.]],
		},
		{
			anim = "food",
			text = [["At least eat. I know I'm not the best cook, but it's made with love. And isn't that what's most important? Rhahaha.. ha..," Edbur laughed awkwardly. [username] remained silent.]],
		},
		{
			anim = "edbur_sad",
			text = [["Alright, well, I'll leave the plate next to your bed as usual." He put down the plate and picked up another plate filled with food gone cold.]],
		},
		{
			anim = "door",
			text = [[I wish I was good at this kind of stuff, he thought to himself as he closed the door.]]
		},
		{
			anim = "sun",
			text = [[2 more days passed when [username] finally decided to leave the bed.]]
		},
		{
			anim = "edbur_smiling",
			text = [["[username]! Are.. are you alright?" Edbur asked carefully.]],
			option = [["I want to kill the dragon"]]
		},
		{
			anim = "edbur_angry",
			text = [["I want to kill the dragon," said [username]. It took Edbur a second to realize what words came out of [username]'s mouth. "Have you gone mad? Didn't you see.."]],
			option = "Continue."
		},
		{
			anim = "eye",
			text = [[Edbur held his breath as he looked straight into [username]'s eyes. They were filled with pure hatred. Edbur realized that there was nothing he could say to change [username]'s mind.]]
		},
		{
			anim = "edbur_neutral",
			text = [[Edbur sighed. "Very well. Follow me. I will teach you how to fight."]]
		},
		{
			func = function () Game:replaceFile("weapon_shop", require("edbur_fighting")()) end
		}
	}
}

return Scene(scene)