local Elli = File:extend()

function Elli:new(text)
    Elli.super.new(self, "house")
    
    if Events.movedAnn then
        Art.new(self, "room3")
    elseif Events.postLament then
        Art.new(self, "room2_empty")
    else
        Art.new(self, "room2")
    end

    if Events.movedAnn then
        if text then
            self:setText(text)
        else
            self:setText([["Hello, [username]," said the old lady. "Thanks again for helping me move."]])
            self:setOptions({
                {
                    text = [["Do you have another key?"]],
                    condition = function () return Events.sawSecondGate end,
                    response = [["Another key? I'm afraid not. But I bet that with some imagination a single key is all you need."]],
                    remove = true
                }
            })
        end
    else
        if Events.postLament then
            self:setText([[[username] entered the house. It was empty.]])
            self:setOptions({
                {
                    text = [["Anyone home?"]],
                    default = true,
                    func = F(self, "checkRoom")
                }
            })
        elseif Events.bellRang then
            self:setText([[As [username] entered the house Elli was visibly panicking. "What are you doing?! Run! Run as fast as you can."]])
            self:setOptions({
                {
                    text = [["Why?"]],
                    response = [["Why?! The dragon of course! It's gonna kill us all!"]],
                    remove = true
                },
                {
                    text = [["What about you?"]],
                    response = [["I'm leaving as soon as I have packed everything. Now go!"]],
                    remove = true
                }
            })
        else
            if text then
                self:setText(text)
            else
                self:setText([["Oh, hello [username]. What can I do for you?", asked Elli. She was good friends with [username]'s mother.]])
            end

            self:setOptions({
                {
                    text = [["Can I help you with something?"]],
                    func = F(self, "asking"),
                    condition = function () return not Events.cleanedWindow end
                },
                {
                    text = [["Do you need any new clothes?"]],
                    response = [["No thank you, dear. My clothes are fine."]],
                    remove = true
                }
            })

            self:setOnItems({
            {
                request = "pantsEdbur",
                response = [["I'm sorry dear but I think you're confusing me for someone else. These are certainly not my pants."]]
            }})
        end
    end
end


function Elli:asking()
    Art.new(self, "elli")
    self:setText([["Well I'm glad you asked! You see, I was cleaning the house, but I'm too tired to clean this last window. Could you do it for me?"]])
    self:setOptions(
    {
        {
            text = [["Sure."]],
            func = F(self, "window")
        },
        {
            text = [["Sorry, not now."]],
            func = F(self, "new")
        }
    })
end


function Elli:window()
    Art.new(self, "windows")
    self:setText([["Wonderful! Okay it's very simple. All you have to do is remove some dirt. Make sure the window on the left looks the same as the window on the right. And if you make a big mistake you can always go back with Ctrl + Z."]])
    self:setOptions({
        {
            text = [["Done!"]],
            default = true,
            func = F(self, "checkWindows")
        },
        {
            text = [["I changed my mind."]],
            func = F(self, "new", "Oh, okay. Thanks anyway.")
        }
    })
end

function Elli:checkWindows()
    local failed = false
    local i = 0
    for line in (self.rContent .. "\n"):gmatch("(.-)\n") do
        i = i + 1
        if i > 17 and i < 28 then
			if  (i == 18 and not line:find("|       | |       |        |       | |       |", 1, true)) or
				(i == 19 and not line:find("|       | |       |        |       | |       |", 1, true)) or
				(i == 20 and not line:find("|       | |       |        |       | |       |", 1, true)) or
				(i == 21 and not line:find("|_______| |_______|        |_______| |_______|", 1, true)) or
				(i == 22 and not line:find("|_______   _______|        |_______   _______|", 1, true)) or
				(i == 23 and not line:find("|       | |       |        |       | |       |", 1, true)) or
				(i == 24 and not line:find("|       | |       |        |       | |       |", 1, true)) or
				(i == 25 and not line:find("|       | |       |        |       | |       |", 1, true)) or
				(i == 26 and not line:find("|_______|_|_______|        |_______|_|_______|", 1, true))
			then
				failed = true
				break
			end
        end
    end

    if failed then
        self:setText([["Oh, well, no I think you missed a spot. Try again."]])
    else
        Events.cleanedWindow = true
        self:setText([["Ah, thank you so much! Here, I'll give you 10 gold."]])
        self.player.gold = self.player.gold + 10
        Art.new(self, "elli")
        self:setOptions({
            {
                text = [["You're welcome."]],
                func =  F(self, "new", [["You're welcome," said [username].]])
            }
        })
        self:setOptions({
            {
                text = [["No problem."]],
                func =  F(self, "new", [["No problem," said [username].]])
            }
        })
    end
end

function Elli:checkRoom()
    self:setText([["Anyone home?" shouted [username]. From the lack of response [he] got [his] answer.]])
    print(Events.postLament, Events.metAnn, Events.movedAnn)
    if Events.postLament and Events.metAnn and not Events.movedAnn then
        self.rContent = love.filesystem.read(self.file)
        print(self.rContent:find("|_____|||_.` `*                       `. |||", 1, true))
        if self.rContent:find("|_____|||_.` `*                       `. |||", 1, true) then
            print("?????")
            Art.new(self, "room3")
            self:setText([[The old lady looked outside and saw she's in Eastown. "Wonderful! Thank you dear." She grabbed the key from her closet, and handed it to [username], along with 20 gold. "Good luck defeating my grandfather", she said with a smile.]])
            self.player.gold = self.player.gold + 20
            Events.movedAnn = true
            local t = lume.clone(Items["castleGateKey"])
            t.tag = "castleGateKey"
            table.insert(self.player.inventory, t)

            self:setOptions({
                {
                    text = [["Thanks."]],
                    func = F(self, "new", [["Thanks." said [username], feeling a bit uncomfortable.]]),
                    remove = true
                }
            })
        end
    end
end

return Elli