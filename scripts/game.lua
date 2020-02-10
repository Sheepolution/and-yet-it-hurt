local GameManager = Object:extend()

function GameManager:new()
	Game = self
	self.player = Player()
	self.files = buddies.new()
	self.files:add(require("readme")())
end


function GameManager:update(dt)
	self.files:removeIf(function (f) return f.dead end)
	self.files:update(dt)
end


function GameManager:removeFile(f)
	self.files:removeIf(function (e) if e.name == f then e:kill() return true end end)
end


function GameManager:killFile(f)
	self.files:call(function (e) if e.name == f then e:kill() end end)
end


function GameManager:addFile(f)
	self.files:add(f)
end


function GameManager:replaceFile(f, nf)
	self.files:removeIf(function (e) if e.name == f then e.isOpen = false return true end end)
	nf.hasChanged = true
	nf.isOpen = true
	self:addFile(nf)
end


function GameManager:onPlayerDeath()
	self.files:kill()
	self:addFile(require("edbur_post_lament")(nil, true))
end


function GameManager:closeFiles()
	self.files:removeIf(function (e)
		if e.isOpen then
			e.isOpen = false
			if e.deleteOnClose then
				e:kill()
				return true
			end
		end
	end)
end


return GameManager