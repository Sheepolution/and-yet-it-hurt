local DragonhillGate = File:extend()

function DragonhillGate:new(text)
	DragonhillGate.super.new(self, "dragonhill gate")
	Art.new(self, "guard_hill")
	self.anim:add("leaves", 2)
	self.anim:add("guard", 1)

	if not text then
		self:setText([[A knight was guarding the gate. "Greetings," said the knight. "No one is allowed to enter. Uphill is where the dragon lives."]])
	elseif type(text) == "string" then
		self:setText(text)
	end

	self:setOptions({
		{
			text = [["Let me in."]],
			condition = function () return not Events.skeletonKingDefeated end,
			response = [["What are you planning, kid? It's impossible to kill the dragon. I mean not unless... but that's just a legend. Now go away."]],
			options = {
				{
					text = [["Unless what?"]],
					response = [["Nothing! Ignore what I said!"]],
					remove = true
				},
				{
					text = [["If you say so..."]],
					func = F(self, "new", [["If you say so...," said [username].]])
				}
			}
		},
		{
			text = [["Let me in."]],
			condition = function () return Events.skeletonKingDefeated end,
			response = [["What are you planning, kid? It's impossible to kill the dragon. I mean not unless..." The knight stopped as he looked at the sword in [username]'s hand. "Is that, it can't be, the legendary sword Nightblood?"]],
			options = {
				{
					text = [["It is."]],
					func = F(self, "enter"),
					response = [["I can't believe it. Very well then, you may enter. Good luck out there, kid."]],
				},
				{
					text = [["That's correct."]],
					func = F(self, "enter"),
				}
			}
		},
		{
			text = [["Who are you?"]],
			response = [["The name is Nord. I am one of the three Serpent Knight Brothers."]]
		},
		{
			text = [["What's up?"]],
			anim = "leaves",
			condition = function () return not Events.foundGuardsRing end,
			response = [["Well I'm glad you asked. You see, I lost my ring in this mountain of leaves. It looks like a '9'. Can you find it for me?
When you find it, replace it with a '0'."]],
			options = {
				{
					text = [["I found it!"]],
					default = true,
					func = F(self, "findRing")
				},
				{
					text = [["Not now."]],
					anim = "guard",
					func = F(self, "new", [["Not now."]])
				}
			}
		}
	})

	self.inited = true
end


function DragonhillGate:findRing()
    self.rContent = love.filesystem.read(self.file)
	if self.rContent:find("566556565056565656565") then
		Events.foundGuardsRing = true
		self.player.gold = self.player.gold + 25
		self.anim:set("guard")
		self:setText([["You really did find it! Thanks a lot!" The knight handed [username] 25 gold.]])
		self:setOptions({
			{
				text = [["You're welcome."]],
				func = F(self, "new", [["You're welcome," said [username].]])
			},
			{
				text = [["No problem."]],
				func = F(self, "new", [["No problem," said [username].]])
			}
		})
	else
		self:setText([["Well, no, not really. Are you sure you found my ring that looks like a '9' and replaced it with a '0'?"]])
	end
end

function DragonhillGate:enter()
	self:setText([["I can't believe it. Very well then, you may enter. Good luck out there, kid."]])
	self:setOptions({})
	self.deleteOnClose = true
	Game:removeFile("weapon shop")
	Game:removeFile("house")
	Game:removeFile("westown gate")
	Game:addFile(require("troll")())
end

return DragonhillGate