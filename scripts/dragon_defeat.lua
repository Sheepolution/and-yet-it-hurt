local DragonDefeat = File:extend()

function DragonDefeat:new()
	DragonDefeat.super.new(self, "dragonhill")

    Art.new(self, "starry_night")
    self.anim:add("end", "2>13", 18, "once")
    self.anim:add("idle", 1)

	Events.dragonDefeated = true

	self:setText([[With the decapitated dragon next to [him] and with the red Nightblood in [his] hands, [username] fell to [his] knees. It was done.]])
	self:setOptions({
		{
			text = [[Look.]],
            response = [[[username] stared into the starry sky. It looked pretty. Slowly tears started pouring out of [username]'s eyes.]],
			options = {
				{
					text = [[Mourn.]],
                    response = [["I miss you, Mom, Dad," said [username].
And yet it hurt.]],
                    func = F(self, "ending")
				}
			}
		}
	})
end

function DragonDefeat:ending()
    self:setOptions({})
    self.tick:delay(4, function ()
		self.deleteOnClose = true
		local credits = love.filesystem.read("assets/art/credits.txt")
		love.filesystem.write("Game/credits.txt", credits)
        self.anim:set("end")
	end)
end

return DragonDefeat