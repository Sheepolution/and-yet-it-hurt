local EdburPostLament = File:extend()

function EdburPostLament:new(first, revive)
	EdburPostLament.super.new(self, "weapon_shop")
	Art.new(self, "weapon_shop")
	self.anim:add("blush", 6)
    self.anim:add("idle", 4)

    if revive then
        self.revived = revive
    end

    if self.revived then
        self:room(self.revived)
        return
    end

	self:setOnItems({
	{
		request =  Player.pronoun .. "NoteEdbur",
		response = [[Edbur started blushing. "D-Don't read it! Just hand it to Ferdan."]],
		anim = "blush",
	}})

    if Events.passedForest then
        self.anim:add("naked", 7)
        self:setText([["Good to see you're still alive [username]!"]])
        self:setOptions({
            {
                text = [["I'm kind of stuck on my adventure."]],
                func = F(self, "advice"),
            },
            {
                text = [["Why are you naked?"]],
                response = [["I accidentally cut my shirt open, and well, your parents were the only one who made clothes in this town. So no shirt for me."]],
                remove = true
            },
            {
                text = [[Go to your room.]],
                func = F(self, "room")
            }
        })
    else
        if not self.inited and not first then
            self:setText([["Good to see you're still alive, [username]!"]])
        end

        if first and type(first) == "string" then
            self:setText(first)
        else
            self:setOptions({
                {
                    text = [["I'm kind of stuck on my adventure."]],
                    func = F(self, "advice"),
                    anim = "idle"
                },
                {
                    text = [[Go to your room.]],
                    func = F(self, "room")
                }
            })
        end
    end

    self.inited = true
end


function EdburPostLament:advice()
    self:setText([["Creative thinking is key! Sometimes you just need to imagine the world in a different way to find the right path."]])
    self:setOptions({
        {
            text = [["What do you mean?"]],
            response = [["Well, let's put it this way. Just like how we fight, by removing and adding something, we can use this technique to manipulate the world around us."]],
            options = {
                {
                    text = [["This is all very confusing."]],
                    response = [[¯\_(ツ)_/¯   ]],
                    func = F(self, "new")
                },
                {
                    text = [["I think I understand."]],
                    response = [["Good!"]],
                    func = F(self, "new")
                }
            }
        }
    })
end


function EdburPostLament:room(revive)
    Art.new(self, "room")

    if revive then
        if revive == 9 then
            self:setText([[[username] woke up. He was well rested, and ready to continue his adventure.]])
        else
            self:setText([[Suddenly, [username] woke up in sweat. Was it all a dream? Perhaps a warning to be careful. [He] got up, and put on [his] clothes.]])
        end
        if self.isOpen then
            self.player:regainHealth()
            self.revived = false
            Game:addFile(require("elli")())
            Game:addFile(require("dragonhill_gate")())
            Game:addFile(require("westown_gate")())
        end
    else
        self:setText([["It's so nice of Edbur that he lets me stay here with him," said [username].]])
    end

    self:setOptions({
        {
            text = "Check the closet.",
            response = [[[username] looked in the closet. [He] saw an odd stone, a box filled with sweets and found 10 gold on the top shelf. [username] took the gold and put it in [his] pocket.]],
            condition = function () return not Events.searchedCloset end,
            event = "searchedCloset",
            gold = 10,
            remove = true
        },
        {
            text = [[Mourn.]],
            response = [["I miss you, Mom, Dad," said [username].
It still hurt.]],
        },
        {
            text = "Go back.",
            func = function () self.revived = false self:new(nil) end
        }
    })
end

function EdburPostLament:update(dt)
	EdburPostLament.super.update(self, dt)
end


function EdburPostLament:draw()
	EdburPostLament.super.draw(self)
end


function EdburPostLament:__tostring()
	return lume.tostring(self, "EdburPost")
end

return EdburPostLament