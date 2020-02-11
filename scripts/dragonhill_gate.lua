local DragonhillGate = File:extend()

function DragonhillGate:new(text)
	DragonhillGate.super.new(self, "dragonhill gate")
	Art.new(self, "guard")

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
					text = [["If you say so...," said [username].]],
					func = F(self, "new", [["If you say  so..."]])
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
			condition = function () return not Events.guessedGuardsName end,
			response = [["I am one of the three Serpent Knight Brothers. Can you guess what my name is? If you guess correct I'll give you some gold. Fill the brackets ([]) with my name."]],
			options = {
				{
					text = [["Is that your name?"]],
					func = F(self, "guessName")
				},
				{
					text = [["I'll guess it later."]],
					func = F(self, "new", [["I'll guess it later."]])
				}
			}
		},
		{
			text = [["What's up?"]],
			response = [["Nothing, really."]]
		}
	})

	self.inited = true
end


function DragonhillGate:guessName()
    local fail = true
    local i = 0
    for line in (self.rContent .. "\n"):gmatch("(.-)\n") do
        i = i + 1
		if i == 37 then
			print(line)
            if line:lower():find("%[%s?sanderu%s?%]") then
                fail = false
                break
            end
        end
	end

	if not fail then
		Events.guessedGuardsName = true
		self.player.gold = self.player.gold + 25
		self:setText([["That's correct! Amazing!" The knight named Sanderu handed [username] 25 gold.]])
		self:setOptions({
			{
				text = [["Thanks!"]],
				func = F(self, "new", [["Thanks!"]])
			},
			{
				text = [["Cool!"]],
				func = F(self, "new", [["Cool!"]])
			}
		})
	else
		self:setText([["A good guess, but alas, that is not my name."]])
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