local Castle = File:extend()

function Castle:new(notfirst)
    Castle.super.new(self, "castle")
    if Events.skeletonKingDefeated then
        if type(notfirst) == "string" then
            self:setText(notfirst)
        end
        Art.new(self, "castle_no_castle")
        self:setOptions({
            {
                text = "Go back to Westown.",
                func = F(self, "back")
            }
        })
    else
        Art.new(self, "castle")
        self.anim:add("door", 2)
        self.anim:add("unlocked", 3)
        self.anim:add("key", 4)
        self.anim:add("hill", 1)
        if not notfirst then
            self:setText("[username] saw the castle up ahead.")
        end

        self:setOptions({
            {
                text = "Walk to the castle.",
                func = F(self, "door")
            },
            {
                text = "Go back to Westown.",
                func = F(self, "back")
            }
        })
    end
end

function Castle:door()
    Events.sawSecondGate = true
    self:setText("[username] stood in front of a huge door.")
    if Events.castleUnlocked then
        self.anim:set("unlocked")
        self:setOptions({
            {
                text = "Go inside.",
                func = F(self, "inside")
            },
            {
                text = "Go back.",
                func = F(self, "new", true)
            }
        })
    else
        self.anim:set("door")
        self:setOptions({
            {
                text = "Go inside.",
                response = "[username] tried to open the door, but it was locked."
            },
            {
                text = "Go back.",
                func = F(self, "new", true)
            }
        })

		self:setOnItems({
		{
            request = "castleGateKey",
            func = F(self, "enter")
		}})
    end
end


function Castle:enter()
    local fail = true
    self.rContent = love.filesystem.read(self.file)
    if self.rContent:lower():find("||===||===||===||===| (x) |===||===||===||===||", 1, true) then
        fail = false
    end

    if not fail then
        Events.castleUnlocked = true
        self:setText("[username] tried to unlock the door with the key, and it opened.")
        self.anim:set("unlocked")
        self:setOptions({
            {
                text = "Go inside.",
                func = F(self, "inside")
            },
            {
                text = "Go back.",
                func = F(self, "new", true)
            }
        })
    else
        self:setText("[username] tried to unlock the door with the key, but it did not fit.")
        self.anim:set("key")
        self:setOptions({
            {
                text = "Back.",
                func = F(self, "door")
            }
        })
    end
end


function Castle:inside()
    self.dead = true
    Game:replaceFile("castle", require("castle_inside")())
end


function Castle:back()
    self:setText("[username] decided to walk back through the castle gate.")
    self:setOptions({})
    self.deleteOnClose = true
    Game:addFile(require("eastown_gate")())
    Game:addFile(require("armor_shop")())
    Game:addFile(require("castle_gate")())
    Game:addFile(require("smith")())
end

return Castle