local Home = File:extend()

function Home:new()
	Home.super.new(self, "home")
	self:init()
end

function Home:init()
	Art.new(self, "clothing_shop")
	print(self.isOpen)
	if not self.isOpen then return end

	if Events.hasBeenAtHomeBefore then
		self:setText("")
	else
		Events.hasBeenAtHomeBefore = true
		self:setText("[username]'s parents were tailors. Everyone in town had their clothes made by them. Today all the sheep were brought inside to be sheared by [username]'s father, while [his] mother was sewing new clothes.")
	end

	self:setOptions({
		{
			text = "Talk to your mom.",
			func = F(self, "mom")
		},
		{
			text = "Talk to your dad.",
			func = F(self, "dad")
		}
	})
end


function Home:mom()
	self:loadArt("mom")

	if Events.gotPantsFromMom then
		self:setText([["Hi, sweetie. Did you give Edbur his pants?" said [username]'s mother.]])
		self:setOptions({
			{
				text = [["I did."]],
				condition = function () print(Events.gavePantsToEdbur) return Events.gavePantsToEdbur end,
				response = [["Thanks, sweety, could you hand me the-" Suddenly [username]'s mother was interrupted by a loud bell. [His] mother's smile instantly vanished. "It can't be! What do we do, Harold?". [username] was confused and asked what was going on.]],
				func = function () Game:removeFile("house") Game:removeFile("weapon_shop") end,
				options = {
					{
						text = "Continue.",
						func = F(self, "event", 1)
					}
				}
			},
			{
				text = [["I did not."]],
				response = [["Well please hurry, Edbur's legs are probably getting cold."]],
				options = {
					{
						text = "Back.",
						func = F(self, "init")
					}
				}
			}	
		})
	else
		self:setText([["Hi, sweetie. Can you bring these pants to Edbur?", asked [username]'s mother]])
		self:setOptions({
			{
				text = [["Okay."]],
				response = [["Okay," said [username] with a clear lack of enthusiasm in [his] voice. [His] mother thanked [him] and handed [him] Edbur's pants.]],
				item = "pantsEdbur",
				event = "gotPantsFromMom",
				options = {
					{
						text = "Back.",
						func = F(self, "init")
					}
				}
			},
			{
				text = [["Not now."]],
				func = F(self, "init")
			}	
		})
	end
end


function Home:dad()
	self:loadArt("dad")

	if Events.goldTakenByDad then
		self:setText([["I hate lunch without milk," said [username]'s father.]])
		self:setOptions({
			{
				text = [[Back.]],
				func = F(self, "init")
			}
		})
	elseif Events.gotGoldFromDad then
		self:setText([["Hello [username]," said [username]'s father, who was still shearing the sheep. "Did you get the milk?"]])
		self:setOptions({
			{
				text = [["The store is closed today."]],
				condition = function () return Events.sawStore end,
				response = [["It is? Darn." said [username]'s father as he took the 5 gold from [username]. "No milk with today's lunch then."]],
				gold = -5,
				event = "goldTakenByDad",
				options = {
					{
						text = "Back.",
						func = F(self, "init")
					}
				}
			},
			{
				text = [["Not yet."]],
				response = [["Well hurry up," said [username]'s father, "or else we'll have lunch without milk."]],
				options = {
					{
						text = "Back.",
						func = F(self, "init")
					}
				}
			}	
		})
	else
		self:setText([["Hello [username]," said [username]'s father, who was busy shearing the sheep. "Can you go to the store and buy some milk?"]])
		self:setOptions({
			{
				text = [["Okay."]],
				response = [["Okay.", agreed [username] reluctantly. [His] father thanked [him] and gave [him] 5 gold for the milk.]],
				gold = 5,
				event = "gotGoldFromDad",
				options = {
					{
						text = "Back.",
						func = F(self, "init")
					}
				}
			},
			{
				text = [["Not now."]],
				func = F(self, "init")
			}
		})
	end
end


function Home:event(i)
	self:loadArt("dad")

	self:setOptions({
		{
			text = "Next.",
			func = F(self, "event", i + 1)
		}
	})

	if i == 1 then
		self:setText([["Calm down," said [username]'s father. "If we stay inside and keep quiet we should be safe." [username] once again asked what was going on.]])
	elseif i == 2 then
		self:setText([["Quiet!" said [username]'s father in a fierce but whispering tone. [username], still confused, didn't dare to speak one more word.]])
	elseif i == 3 then
		-- self.visible = false
		self:setText([[Suddenly the ground started shaking, making the sheep start bleating hysterically.]])
	elseif i == 4 then
		-- self.visible = true
		self:setText([["Shit!" said [username]'s father, not whispering anymore. "Help me calm them down, if they are too loud the dra-"]])
	elseif i == 5 then
		self.visible = false
		Art.new(self, "the_end_qm")
		self:setText([[The next instance, [username] was surrounded by flames. The heat was extreme, and [he] screamed in pain as [he] [was] burned alive. It was the end of [him].]])
		self:setOptions({
			{
				text = "Restart.",
				func = F(self, "restart")
			}
		})
	end
end


function Home:restart()
	love.event.quit("restart")
end

return Home