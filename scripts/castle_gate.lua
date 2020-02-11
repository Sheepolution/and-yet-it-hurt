local CastleGate = File:extend()

function CastleGate:new()
	CastleGate.super.new(self, "castle gate")
	-- self:init()

	if self.isOpen then
		Events.sawCastleGate = true
	end

	Art.new(self, "gate")
	self.anim:add("open", 2)
	self.anim:add("closed", 1)
	self:setOnItems({
		{
			request = "castleGateKey",
			event = "gateUnlocked",
			response ="[username] tried to unlock the gate with the key, and it opened.",
			anim = "open",
			options = {
				{
					text = "Go through the gate.",
					func = F(self, "enter")
				}
			}
		}
	})

	self:setText([[[username] arrived at another gate, the one that leads to the castle. This time there was no guard.]])
	self:setOptions({
		{
			text = "Open the gate.",
			response = "[username] tried to open the gate, but it was locked."
		}
	})
end


function CastleGate:enter()
	self:setOptions({})
	self.deleteOnClose = true
	Game:removeFile("smith")
	Game:removeFile("eastown gate")
	Game:removeFile("armor shop")
	Game:addFile(require("castle")())
end

return CastleGate