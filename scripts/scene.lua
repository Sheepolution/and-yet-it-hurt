Scene = File:extend()

function Scene:new(scene)
	self.sceneObject = scene
	Scene.super.new(self, scene.name)
	Art.new(self, scene.art)
	
	scene.anims(self)

	self.scene = scene

	self.page = 0
	
	if self.isOpen then
		self:next()
	end

	self:setOptions({
		{
			text = "Continue.",
			default = true,
			func = function ()
				self:next()
			end 
		}
	})
end


function Scene:next()
	self.page = self.page + 1

	if self.page == #self.scene.scenes then
		self:setOptions({})
	end

	local scene = self.scene.scenes[self.page]

	if scene.text then
		self:setText(scene.text)
	end

	if scene.anim then
		self.anim:set(scene.anim)
	end

	if scene.func then
		scene.func()
	end

	if scene.option then
		self:setOptions({
			{
				text = scene.option,
				default = true,
				func = function ()
					self:next()
				end 
			}
		})
	end
end


function Scene:onOpen()
	if self.scene.onOpen then
		self.scene.onOpen()
	end
	Scene.super.onOpen(self)
end


function Scene:__tostring()
	return lume.tostring(self, "Scene")
end