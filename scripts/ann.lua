local Ann = File:extend()

function Ann:new(text)
	Ann.super.new(self, "house")
    Art.new(self, "room3")
    self.anim:add("face", 2)
    self.anim:add("room", 1)

    print(Events.sawCastleGate, Events.gaveNoteToFerdan)

    if Events.metAnn then
        self:setText([[Please let me know when you're done with moving."]])
        self:setOptions({
            {
                    text = [["Okay."]]
            },
            {
                text = [["I'm not sure how to do this."]],
                response = [["How hard could it be? Surely there is an empty house in Eastown after the dragon attacked. Just move me and all my stuff over there."]]
            }
        })
    else
        self:setText([[[username] saw an old woman sittng at a table. "Why hello there. What can I do for you?"]])
        self:setOptions({
            {
                text = [["Do you have the key for the gate to the castle?"]],
                response = [[The old woman smiled. "Why yes, I do. Do you want me to give it to you? Well maybe you can help me with something first."]],
                condition = function () return Events.gaveNoteToFerdan and Events.sawCastleGate end,
                anim = "face",
                options = {
                    {
                        text = [["What do you mean?"]],
                        response = [["I've always wanted to live in Eastown, but at my old age it's hard to move. Especially since I want to bring all my belongings. Will you help me?"]],
                        event = "metAnn",
                        options = {
                            {
                                text = [["I'm on it."]],
                                response = [["Please let me know when you're done with moving."]],
                                anim = "room",
                                options = {
                                    {
                                        text = [["Okay."]]
                                    },
                                    {
                                        text = [["I'm not sure how to do this."]],
                                        response = [["How hard could it be? Surely there is an empty house in Eastown after the dragon attacked. Just move me and all my stuff over there."]]
                                    }
                                },
                            },
                            {
                                text = [["Aren't you afraid of the dragon?"]],
                                response = [["Silly kid. Do you really think I fear death at my age?"]],
                                remove = true
                            }
                        }
                    }
                }
            },
            {
                text = [["Who are you?"]],
                response = [["Shouldn't I be the one asking that since you're entering my house?" The old woman smiled. "My name is Ann. Just a regular old lady living the last of her days."]],
                anim = "face",
                remove = true
            }
        })
    end
end


return Ann