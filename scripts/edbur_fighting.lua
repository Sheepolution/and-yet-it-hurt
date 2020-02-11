local EdburFighting = Fight:extend()

local huge = math.huge
function EdburFighting:new()
	EdburFighting.super.new(self, "weapon shop")
	Art.new(self, "edbur_fighting")

	self.anim:add("attacking", 3);
	self.anim:add("prepareAttack", 2);
	self.anim:add("defending", 1);
	self.anim:add("prepareDefense", 1);

	self.state = "defending"

	self.attack = 2

	self.health = 100
	self.strength = 1

	self.timeAttacking = huge
	self.timeDefending = huge
	self.pauseTimer = huge

	self.learnedDefending1 = false
	self.learnedAttacking1 = false
	self.learnedDefending2 = false
	self.learnedAttacking2 = false

	self.learningState = 1

	self.description = [["Whenever you enter a fight, this box will contain a description of the enemy."]]
end


function EdburFighting:update(dt)
	EdburFighting.super.update(self, dt)
end


function EdburFighting:draw()
	EdburFighting.super.draw(self)
end


function EdburFighting:updateDescription(state, damage)
	if self.learningState == 3 then return end
	self.player.health = 100
	self.health = 100
	print(state)
	print(self.learningState)
	if state == "prepareDefense" then
		if self.learningState == 1 then
			if damage > 0 then
				self:setText([["Very good. The number of attacks you can do, and how much damage each attack does, depends on the weapon. Normally you will have limited time to block and attack."
(Save to continue)]])
				self.learnedAttacking1 = true
				if self.learnedAttacking1 and self.learnedDefending1 then
					self.learningState = 2
				end
			else
				self:setText([["You missed! Make sure to put any character other than a space in the marks: <{ a }>"
(Save to continue)]])
			end
		elseif self.learningState == 2 then
			if damage > 0 then
				-- self.timeAttacking = huge
				-- self.timeDefending = huge
				self.learnedAttacking2 = true
				if self.learnedDefending2 and self.learnedAttacking2 then
					self:setText([["Well done! One last piece of advice: Instead of clicking next to the 'x' and pressing backspace, you can select the 'x' and replace it with a space instead." 
(Save to continue)]])
					self.learningState = 3
				else
					self:setText([["Very good! You were able to attack me.
(Save to continue)]])
				end
			else
				self:setText([["You missed! Make sure to put any character other than a space in the marks: <{ a }>"
(Save to continue)]])
			end
		end
	elseif state == "defending" then
		if self.learningState == 1 then
			self:setText([["When you're being attacked, one or more of these marks will pop up: <{ x }>. Each mark counts as 1 attack. Remove the 'x' from the mark to block the attack, or replace it with a space. Once all the 'x's are removed, save the file. Don't try to remove the mark itself, it won't work."]])
		elseif self.learningState == 2 then
			self:setText([["Try to block my attack in a limited amount of time. At the bottom it says how much time you have."]])
			self.timeAttacking = 10
		end
	elseif state == "prepareAttack" then
		if damage > 0 then
			self:setText([["That's no good. Make sure to remove the 'x' from the marks."
(Save to continue)]])
		else
			if self.learningState == 2 then
				self.learnedDefending2 = true
				if self.learnedDefending2 and self.learnedAttacking2 then
					self:setText([["Well done! One last piece of advice: Instead of clicking next to the 'x' and pressing backspace, you can select the 'x' and replace it with a space instead." 
	(Save to continue)]])
					self.learningState = 3
				else
					self:setText([["Very good! You were able to block my attack."
	(Save to continue)]])
				end
			else
				self:setText([["Very good! You were able to block my attack. But remember, if you don't save before the time runs out, none of your blocks will be registered. Sometimes it might be better to let some attacks go."
(Save to continue)]])
				self.learnedDefending1 = true
				if self.learnedAttacking1 and self.learnedDefending1 then
					self.learningState = 2
				end
			end
		end
	elseif state == "attacking" then
		if self.learningState == 1 then
			-- self:setText([["When you're being attacked, these marks will pop up: <{ x }>. Remove the 'x' to block the attacks. Once all the 'x's are removed, save the file."]])
			self:setText([["When it's your turn to attack, these marks will pop up: <{  }>. Fill the marks with any character besides a space and save the file. For example: <{a  }> or <{h}>. Don't try to add your own marks, it won't work."]])
		elseif self.learningState == 2 then
			self.timeDefending = 10
			self:setText([["Try to attack me in a limited amount of time. At the bottom it says how much time you have."]])
		end
		-- self:setText([["When you're being attacked, these marks will pop up: <{ x }>. Remove the 'x' to block the attacks.]])
	end
end


function EdburFighting:onEdit()
	if self.learningState == 3 then
		Game:replaceFile("weapon shop", require("edbur_post_fight")())
	end
	EdburFighting.super.onEdit(self)
end

function EdburFighting:__tostring()
	return lume.tostring(self, "EdburFighting")
end

return EdburFighting