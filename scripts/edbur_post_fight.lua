local EdburPost = File:extend()

function EdburPost:new()
	EdburPost.super.new(self, "weapon shop")
	Art.new(self, "weapon_shop")
	self.anim:add("blush", 6)
	self.anim:add("idle", 4)
	self.cutscene = true
	self:setText([["Now you know how to fight. But tell me, [username], are you sure you want to do this? Are you sure you want to fight the dragon?"]])
	local destiny = F(self, "destiny")
	self:setOptions({
		{
			text = [["I have to do this."]],
			func = destiny
		},
		{
			text = [["It's my destiny."]],
			func = destiny
		},
		{
			text = [["This is the only way."]],
			func = destiny
		},
		{
			text = [["I don't feel like I have a choice."]],
			response = [["Of course you have a choice! You can stay here with me. Live a peaceful life under my protection. What do you say, [username]?"]],
			options = {
				{
					text = [["I must avenge my parents."]],
					func = destiny
				},
				{
					text = [["I won't find happiness in my life as long as that dragon's heart beats."]],
					func = destiny
				},
				{
					text = [["I rather die trying than live a peaceful life of regret."]],
					func = destiny
				},
				{
					text = [["No I mean it, Edbur. There is no option where I don't fight the dragon."]],
					func = destiny
				}
			}
		}
	})

	self:setOnItems({
	{
		request =  Player.pronoun .. "NoteEdbur",
		response = [[Edbur started blushing. "D-Don't read it! Just hand it to Ferdan."]],
		anim = "blush",
	}})
end


function EdburPost:destiny()
	self:setText([["Alright, I understand," said Edbur, who did not entirely understand. "In any case, you won't be able to beat it with a mere dagger."]])
	self:setOptions({
		{
			text = [["Can't you give me a weapon of yours?"]],
			response = [["I would if I could, but while you were laying in bed I sold all my weapons. People want to be able to protect themselves for when the dragon comes back."]],
			options = {
				{
					text = [["So what do I do now?"]],
					response = [["I have an old friend who is a blacksmith in Westown. He might be able to help you. His name is Ferdan. Give him this note, he'll understand." Edbur wrote something on a piece of paper and handed it to [username].]],
					item = Player.pronoun .. "NoteEdbur",
					options = {
						{
							text = [["Thanks!"]],
							anim = "idle",
							remove = true,
							options = {},
							func = F(self, "endCutscene")
						},
						{
							text = [["What does the note say?"]],
							response = [[Edbur started blushing. "That's a secret! So don't read it! Just hand it to Ferdan."]],
							anim = "blush",
							remove = true
						}
					}
				},
			}
		}
	})
end


function EdburPost:endCutscene()
	Events.postLament = true
	local text = [["Thanks Edbur!" said [username] as [he] gave Edbur a hug. "No problem, kid," said Edbur. "Be careful out there."
(From now on your progress will be saved automatically)]]
	self:setText(text)
	Game:replaceFile("weapon shop", require("edbur_post_lament")(text))
	Game:addFile(require("westown_gate")())
	Game:addFile(require("dragonhill_gate")())
	Game:addFile(require("elli")())
end


function EdburPost:update(dt)
	EdburPost.super.update(self, dt)
end


function EdburPost:draw()
	EdburPost.super.draw(self)
end


function EdburPost:__tostring()
	return lume.tostring(self, "EdburPost")
end

return EdburPost