local Smith = File:extend()

function Smith:new(text)
	Smith.super.new(self, "smith")
	Art.new(self, "smith")
	self.anim:add("idle", 1)

	self.gaveNote = false

	if Events.gaveNoteToFerdanStart and not Events.gaveNoteToFerdan then
		Art.new(self, "ferdan")
		self.anim:add("idle", 1)
		self.anim:add("opening", 1)
		self.anim:add("angry", 3)
		self.anim:set("angry")
		self:setText([["Do you think it's normal to walk away in the middle of a conversation?" Ferdan said angrily.]])
		self:setOptions({
			{
				text = [["Sorry."]],
				func = F(self, "note")
			}
		})
		return
	end

	if text then
		self:setText(text)
		self:setOptions({})
	elseif Events.gaveNoteToFerdan then
		self:setText([["Hello [username]," said Ferdan. "Have you changed your foolish mind yet?"]])
		if not Events.movedAnn then
			self:setOptions({
				{
					text = [["Do you have the key for the gate to the castle?"]],
					response = [["No, why? Is it locked? Good! It prevents people like you from making stupid decisions. Whoever has it I hope they keep it."]],
					condition = function () return not Events.metAnn end,
					options = {}
				},
				{
					text = [["No."]],
					response = [["No," said [username]. "Idiot," said Ferdan.]],
					remove = true
				}
			})
		end
	else
		self:setText([[As [username] walked in [he] saw a big and strong man hammering down on a sword. "What can I do for ya?", the man asked.]])

		self:setOptions({
			{
				text = [["I'm a friend of Edbur"]],
				response = [["Edbur? What's that old fella been up to? Anyway, you could be friends with the king for all I care. If you don't have money then leave."]],
				remove = true
			},
			{
				text = [["Can I buy a sword?"]],
				response = [["It depends, do you have 200 gold? If not then leave."]],
				remove = true
			}
		})

		if not Events.gaveNoteToFerdan and not self.gaveNote then
			self:setOnItems({
			{
				request = Player.pronoun .. "NoteEdbur",
				response = [[[username] handed Edbur's note to Ferdan. "Edbur asked me to give this to you. He said you would understand."]],
				func = function ()
					self.inCutscene = true
					self.gaveNote = true
					Events.gaveNoteToFerdanStart = true
					self:setOnItems({})
				end,
				options = {
					{
						text = "Continue.",
						func = F(self, "note")
					},
				}
			}})
		end
	end
end


function Smith:update(dt)
	Smith.super.update(self, dt)
end


function Smith:draw()
	Smith.super.draw(self)
end


function Smith:note()
	Art.new(self, "ferdan")
	self.anim:add("idle", 1)
	self.anim:add("angry", 3)
	self.anim:add("opening", 1)
	self:setText([["Let's see, what is this all about," said Ferdan as he read the note. "Gragragragra!" Ferdan laughed. "You've gone soft Edbur."]])
	self:setOptions({
		{
			text = "Continue.",
			default = true,
			response = [["And you, what are you a fool?" Ferdan asked annoyed. "Killing a dragon for vengeance. Not that I can convince you not to, according to Edbur."]],
			anim = "angry",
			options = {
				{
					text = "Continue.",
					response = [[Ferdan sighed. "You can't kill it, kid. Not with that dagger nor with any of my swords."]],
					default = true,
					anim = "idle",
					options = {
						{
							text = [["What do you mean?"]],
							response = [["The legend says that the dragon can only be killed with Nightblood, a sword forged from the blood of demons. It's so edgy that it can cut right through dragon scale."]],
							options = {
								{
									text = [["Where is it?"]],
									response = [["Nightblood, if it exists at all, is said to be wielded by the Skeleton King who lives in the castle nearby."]],
									options = {
										{
											text = [["Thanks, I know what to do now."]],
											anim = "angry",
											response = [["Don't do it kid. The Skeleton King, if he exists at all, has been undefeated. If you believe in this stuff you're an idiot, and if it were to be true you're an even bigger idiot!"]],
											options = {
												{
													text = [["I'm sorry, Ferdan. I have no choice."]],
													response = [["Well if you're gonna do it, do it properly!" Ferdan went in the other room and came back with a sword. "Here, take it," said Ferdan as he pushed the sword in [username]'s arms. "Edbur better not come crying at my feet when you're dead!"]],
													func = function ()
														Events.gaveNoteToFerdan = true
														Player.inventory.note = nil
													end,
													item = "sword",
													options = {
														{
															text = [["Thanks."]],
															func = F(self, "new", [["Thanks, Ferdan," said [username]. Ferdan shook his head and continued his work.]])
														}
													}
												}
											}
										},
										{
											text = [["Skeleton King?"]],
											response = [["Keep up with the legends, kid. 138 years ago the Skeleton King used forbidden magic to gain eternal life. He has lost all his flesh, but his soul and bones live on. Not that I believe any of these fairy tales."]],
											remove = true
										}
									}
								}
							}
						}
					}
				}
			}
		}
	})
end


function Smith:__tostring()
	return lume.tostring(self, "Smith")
end

return Smith