local WestownGate = File:extend()

function WestownGate:new(text)
	WestownGate.super.new(self, "westown gate")
	if Events.fixedGuardsSigil then
		Art.new(self, "guard")
	else
		Art.new(self, "guard_no_serpent")
	end

	if not text then
		self:setText([[A knight was guarding the gate. "Greetings," said the knight. "This is the gate to Westown. You're not allowed to enter if you don't have a weapon to defend yourself. Wild animals live in the tall grass!"]])
	elseif type(text) == "string" then
		self:setText(text)
	end

	self:setOptions({
		{
            text = [["Let me in."]],
			response = [["I see you have a weapon. Very well then. Be careful out there."]],
			options = {},
			func = F(self, "enter"),
		},
		{
            text = [["Who are you?"]],
            response = [["The name is Leff. I am one of the three Serpent Knight Brothers."]]
		},
		{
			text = [["What's up?"]],
			condition = function () return not Events.fixedGuardsSigil end,
			response = [["Well I'm glad you asked. You see, the sigil on my breastplate isn't quite right. The dagger is missing the serpent. Could you fix it for me?"]],
			options = {
				{
					text = [["I fixed it."]],
					func = F(self, "fixSigil"),
					default = true
				},
				{
					text = [["Not now."]],
					func = F(self, "new", [["Not now."]])
				}
			}
		}
	})

end


function WestownGate:enter()
	self:setOptions({})
	self.deleteOnClose = true
	Game:removeFile("dragonhill gate")
	Game:removeFile("weapon shop")
	Game:removeFile("house")
	Game:addFile(require("forest")("west"))
end

function WestownGate:fixSigil()
    local fail = false
    local i = 0
    for line in (self.rContent .. "\n"):gmatch("(.-)\n") do
        i = i + 1
        if i > 21 and i < 26 then
			line = line:sub(65, 68)
			print(line)
			if (i == 22 and not line:find(" ||O", 1, true)) or
				(i == 23 and not line:find("((| ", 1, true)) or
				(i == 24 and not line:find(" |))", 1, true)) or
				(i == 25 and not line:find("<|| ", 1, true))
			then
				fail = true
				break
			end
        end
	end

	if not fail then
		Events.fixedGuardsSigil = true
		self.player.gold = self.player.gold + 25
		Art.new(self, "guard")
		self:setText([["That's perfect! Thanks a lot! Here, have some gold." The knight handed username 25 gold.]])
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
		self:setText([["No, that doesn't seem right. Try again will ya?"]])
	end
end

return WestownGate