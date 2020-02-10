local ReadMe = File:extend()

function ReadMe:new()
    ReadMe.super.new(self, "readme")
    if self.isOpen then
        Art.new(self, "logo")
    else
        Art.new(self, "readme_noadmin")
        return
    end

    if SAVE.exists then
        self:setText([[Hey, welcome back. I see you've played this game before. Do you want to continue from where you left off?]])
        self:setOptions({
            {
                text = "Yes, load my game.",
                func = F(self, "load")
            },
            {
                text = "No, start a new game.",
                func = F(self, "tips")
            },
        })
    else
        self:setText([[How to play: At the bottom you will see the options. You can select an option by filling the [] with one or multiple characters.
For example: [s] - I understand how options work.
After filling your selection you can save the file with Ctrl + S. Try it out!]])
        self:setOptions({
            {
                text = "I understand how to select an option.",
                func = F(self, "tips")
            }
        })
    end
end


function ReadMe:tips()
    self:setText([[Good! Before we start the game I have some tips for you.
With Windows key + Left/Right arrow key you can put the windows nicely next to each other.
And did you know you can scroll in and out with Ctrl + Scroll wheel?]])
    self:setOptions({
        {
            text = "Thank you for the tips.",
            func = F(self, "continue", 1)
        },
        {
            text = "I did not know that!",
            func = F(self, "continue", 2)
        },
        {
            text = "I already knew that!",
            func = F(self, "continue", 3)
        }
    })
end

function ReadMe:continue(n)
    local start = ""
    if n == 1 then
        start = "You're welcome!"
    elseif n == 2 then
        start = "Well now you do know!"
    elseif n == 3 then
        start = "Very good!"
    end

    self:setText(start .. [[ You are almost ready to go on an adventure. Almost.
First, fill the brackets ([])  with the name of your character. The name can't be longer than 15 characters.
For example: [William] or [Elizabeth] -  That is the name of my character.]])

    if n == 4 then
        self:setText([[You changed your mind on the name? That's okay.
Fill the brackets ([]) with the name of your character. The name can't be longer than 15 characters.
For example: [William] or [Elizabeth] -  That is the name of my character.]])
    end

	self:setOptions({
        {
            text = "That is the name of my character.",
            func = F(self, "setName")
        },
        {
            text = "I can't decide on a name.",
            func = F(self, "setName", true)
        }
    })
end

function ReadMe:setName(pick)
    print(pick)
    local name
    if pick then
        local names = {"Elizabeth", "Isabella", "Margaret", "Johnathon", "Daniel", "Thaeson"}
        name = lume.randomchoice(names)
        self:setText("Okay, then I'll choose... " .. name .. "! Now, how should we talk about this character?")
    else
        local match = self.rContent:sub(1000, #self.rContent):match("%[([^%]]+)%]%s%-%s" .. Utils.litString("That is the name of my character"))

        if match then
            if #match > 15 then
                self:setText("This name is too long! Please don't use more than 15 characters.")
                return
            end
            self:setText([[So your character's name is ]] .. match .. [[? I like it!
How should we talk about this character?]])
            name = match
        else
            return
        end
    end

    Player.name = name

    self:setOptions({
        {
            text = "he/him/his",
            func = F(self, "pronouns", "he")
        },
        {
            text = "she/her/her",
            func = F(self, "pronouns", "she")
        },
        {
            text = "they/their/them",
            func = F(self, "pronouns", "they")
        },
        {
            text = "I want to change the name.",
            func = F(self, "continue", 4)
        }
    })
end

function ReadMe:pronouns(p)
    Player.pronoun = p

    self:setText([[It is done. Now, let us begin.
And yet it hurt. A story about [username], a kid from Eastown who lived a happy and peaceful life with [his] parents.
(Open one of the files in the folder.)]])
    self:setOptions({})

    self.deleteOnClose = true
    Game:addFile(require("edbur")())
    Game:addFile(require("home")())
    Game:addFile(require("elli")())
    Game:addFile(require("grocery_store")())
end

function ReadMe:load()
    print(SAVE.Events)
    Events = SAVE.Events
    print(Events)
    Player.name = SAVE.name
    Player.pronoun = SAVE.pronoun
    Player.inventory = SAVE.inventory
    Player.gold = SAVE.gold
    local w = 0
    for i,v in ipairs(Player.inventory) do
        if v.tag == "nightblood" then
            self.player.weapon = v
            w = 3
        elseif w < 3 and v.tag == "sword" then
            self.player.weapon = v
            w = 2
        elseif w < 2 and v.tag == "dagger" then
            self.player.weapon = v
            w = 1
        end
    end
    self:setText("Very well. Let's continue the adventure of " .. Player.name .. ".")
    self:setOptions({})
    self.deleteOnClose = true
    Game:addFile(require("edbur_post_lament")(nil, 9))
end

return ReadMe