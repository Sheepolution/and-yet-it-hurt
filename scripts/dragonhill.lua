local DragonHill = File:extend()

function DragonHill:new()
	DragonHill.super.new(self, "dragonhill")
    Art.new(self, "dragonhill")

    self:setText("At last, [username] finally reached the top of the hill. There [he] saw it. The dragon. All this time [username] had built up [his] emotions, [his] rage, and it was time to unleash it.")
    self:setOptions({{
        text = "Fight the dragon.",
        func = F(self, "fight")
    }})
end


function DragonHill:fight()
	Game:replaceFile("dragonhill", require("dragon")("dragonhill", "dragon_defeat"))
end

return DragonHill