local EastownGate = File:extend()

function EastownGate:new(text)
	EastownGate.super.new(self, "eastown gate")
	if Events.gaveGuardLongerSword then
		Art.new(self, "guard_long_sword")
	else
		Art.new(self, "guard_short_sword")
	end

	if not text then
		self:setText([[A knight was guarding the gate. "Greetings," said the knight. "This is the gate to Eastown. You're not allowed to enter if you don't have a weapon to defend yourself. Wild animals live in the tall grass!"]])
	elseif type(text) == "string" then
		self:setText(text)
	end
	self:setOptions({
		{
            text = [["Let me in."]],
			response = [["I see you have a weapon. Very well then. Be careful out there."]],
            func = F(self, "enter")
		},
		{
            text = [["Who are you?"]],
            response = [["The name is Righ. I am one of the three Serpent Knight Brothers."]]
		},
		{
			text = [["What's up?"]],
			condition = function () return not Events.gaveGuardLongerSword end,
			response = [["Well I'm glad you asked. You see, compared to my brothers my sword is the shortest. Could you make it so that my sword is the longest? Make it go as high as my eyes."]],
			options = {
				{
					text = [["I fixed it."]],
					default = true,
					func = F(self, "extendSword")
				},
				{
					text = [["Not now."]],
					func = F(self, "new", [["Not now."]])
				}
			}
		}
	})
end


function EastownGate:enter()
	self:setOptions({})
	self.deleteOnClose = true
	Game:removeFile("castle gate")
	Game:removeFile("armor shop")
	Game:removeFile("smith")
	if not Events.movedAnn then
		Game:removeFile("house")
	end
	Game:addFile(require("forest")("east"))
end


function EastownGate:extendSword()
    local fail = false
    local i = 0
    for line in (self.rContent .. "\n"):gmatch("(.-)\n") do
        i = i + 1
        if i >= 12 and i <= 25 then
			line = line:sub(83, 84)
            if line ~= "||" then
                fail = true
                break
            end
        end
	end

	if not fail then
		Events.gaveGuardLongerSword = true
		self.player.gold = self.player.gold + 25
		Art.new(self, "guard_long_sword")
		self:setText([["That's perfect! Thanks a lot! Here, have some gold." The knight handed [username] 25 gold.]])
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
		self:setText([["Not really what I had in mind. Maybe try again? Make it go as high as my eyes."]])
	end
end

return EastownGate