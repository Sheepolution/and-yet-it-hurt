local ArmorShop = File:extend()

function ArmorShop:new(text)
	ArmorShop.super.new(self, "armor_shop")
    Art.new(self, "armor_shop")

    self.player:regainHealth()
    
    self.costs = {
        helmet = 50,
        breastplate = 20,
        shield = 40,
        gauntlets = 40
    }

    if not Events.hasBeenInArmorShopBefore then
        self:setText([[[username] entered the armory shop and saw a kid about [his] age standing behind the counter. "Oh, hello," said the kid. "Welcome in our armor shop. We sell armor, I guess. Can I help you with anything, like, buying something, maybe?"]])
    else
        self:setText([["Oh, hello," said the kid. "Welcome in our shop. We sell armor, I guess. Do you want to buy something?"]])
    end
    
    if text then
        self:setText([["Oh. Okay, well, you see, if you don't have enough gold you can't buy it. That's like, how this works. So, yeah, sorry."]])
    end

    self:setOptions({
        {
            text = [["I would like to buy something."]],
            response = [["Right, okay, well, just mark the item that you want to buy. But, like, one at a time, please."]]
        },
        {
            text = [["Where are your parents?"]],
            response = [["Well my mom ran away ages ago, but my dad is upstairs. Had a bit too much of his 'special potion' as he calls it."]],
        }
    })

end

function ArmorShop:onEdit()
    self.rContent = love.filesystem.read(self.file)
    local items = {
        "helmet",
        "breastplate",
        "shield",
        "gauntlets"
    }

    local str = "%[([^%]%s]+)%]%s%-%s"
    for i,v in ipairs(items) do
        if self.rContent:lower():find(str .. v) then
            if Events[v .. "Bought"] then
                if v == "gauntlets" then
                    self:setText([["Gauntlets, right. The thing is, you already have gauntlets. So, like, there isn't really a point to buying another pair of gauntlets. I think."]])
                else
                    self:setText([["A ]] .. v .. [[, right. The thing is, you already have a ]] .. v .. [[. So, like, there isn't really a point to buying another ]] ..v .. [[. I think."]])
                end
            else
                self:setText([["The ]] .. v.. [[, right. That costs ]] .. self.costs[v] .. [[ gold. So, yeah, please give me ]] .. self.costs[v] ..  [[ gold, I suppose.]])
                if self.player.gold < self.costs[v] then
                    self:setOptions({
                        {
                            text = [["I don't have enough gold."]],
                            func = F(self, "new", [["Oh. Okay, well, you see, if you don't have enough gold you can't buy it. That's like, how this works. So, yeah, sorry."]])
                        }
                    })
                else
                    self:setOptions({
                        {
                            text = [[Give ]] .. self.costs[v] .. [[ gold.]] ,
                            response = [["Thanks. Here you have the ]] .. v .. [[. Have fun, I guess."]],
                            item = v,
                            gold = -self.costs[v],
                            event = v .. "Bought",
                            func = F(self, "new", [["Thanks. Here you have the ]] .. v .. [[. Have fun, I guess."]])
                        },
                        {
                            text = [["I changed my mind."]],
                            func = F(self, "new", [["Oh. Well, that's okay."]])
                        }
                    })
                end
            end
        end
    end

    ArmorShop.super.onEdit(self)
end

return ArmorShop