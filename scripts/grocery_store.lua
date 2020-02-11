local GroceryStore = File:extend()

function GroceryStore:new()
	GroceryStore.super.new(self, "grocery store")
	Art.new(self, "grocery_store")
	self.anim:add("open", 2)
	self.anim:add("closed", 1)
	
	if self.isOpen then
		Events.sawStore = true
	end

    self:setText([[[username] stood in front of the door of the grocery store. The sign said CLOSED.]])

	self:setOptions({
		{
			text = [[Knock.]],
			default = true,
			func = F(self, "checkOpen")
		},
		{
            text = [[Shout "Is anyone there?"]],
            response = [["Is anyone there?" shouted [username]. No response.]]
		}
	})
end


function GroceryStore:checkOpen()
	self:setText([[[username] knocked on the door. No response.]])
	if self.rContent:find("OPEN") then
		self.anim:set("open")
		self:setText("Suddenly, the sign said OPEN. But still, the door was closed.")
	end
end

return GroceryStore