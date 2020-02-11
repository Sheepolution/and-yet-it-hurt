local Troll = File:extend()

function Troll:new()
	Troll.super.new(self, "dragonhill")
    -- self:init()
	Art.new(self, "troll")
	self.anim:add("may", 3)
    self.anim:add("none", 1)
	self.anim:add("not", 2)

    self:setText([[As [username] walked up the hill, [he] encountered a troll blocking the bridge. "You may NOT pass!" said the troll.]])
    self:setOptions({
        {
            text = [["May I pass?"]],
            func = F(self, "ask"),
            default = true
        },
        {
            text = [["Why not?"]],
            response = "Because that is what I said!",
            remove = true
        },
        {
            text = "Back.",
            func = F(self, "back")
        }
    })

end

function Troll:ask()
    self.rContent = love.filesystem.read(self.file)
    if self.rContent:find("   |     | # /``-.    | You may pass!", 1, true) or self.rContent:find("   |     | # /``-.    | You may  pass!", 1, true) then
        self:setText([["Did you not hear what I said? You may pass! Wait, no that's not what I meant to say!"]])
        self.anim:set("may")
        self:setOptions({
            {
                text = [["Thanks!"]],
                response = [["Thanks!" said [username], and [he] crossed the bridge.]],
                options = {
                    {
                        text = "Continue walking.",
                        func = F(self, "cross")
                    }
                }
            }
        })
    else
        self:setText([["Did you not hear what I said? You may NOT pass!"]])
        self:setOptions({
            {
                text = [["May I pass?"]],
                func = F(self, "ask")
            },
            {
                text = [["Why not?"]],
                response = "Because that is what I said!"
            },
            {
                text = "Back."
            }
        })
    end
end


function Troll:cross()
    self.dead = true
    Game:replaceFile("dragonhill", require("dragonhill")())
end

function Troll:back()
    self:setText("[username] decided to walk back.")
	self.deleteOnClose = true
	self:setOptions({})
	Game:addFile(require("westown_gate")())
	Game:addFile(require("dragonhill_gate")())
	Game:addFile(require("edbur_post_lament")())
	Game:addFile(require("elli")())
end

return Troll