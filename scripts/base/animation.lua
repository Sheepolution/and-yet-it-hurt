local Animation = Object:extend()

local mt_anim = {}
mt_anim.__index = mt_anim

function mt_anim:onComplete(func, first)
	if func then
		self._ocFunc = func
		self._ocFuncFirst = first
	else
		self._ocFunc = nil
	end
	return self
end


function mt_anim:onFrame(frame, func, first)
	if func then
		local f = {}
		f.func = func
		f.frame = frame
		f.first = first
		self._oFrames[frame] = f
	else
		self._oFrames[frame] = nil
	end
	return self
end


function mt_anim:onUpdate(func)
	if func then
		self._ouFunc = func
	else
		self._ouFunc = nil
	end
	return self
end


function mt_anim:after(a, l)
	self._after = a
	self._afterLoop = l or 1
	return self
end


function Animation:new()
	self.frame = 1;
	self.ended = false
	self.playing = true
	self.stopped = false
	self.paused = false
	self.name = ""
	self.offset = {0, 0}

	self._current = {}
	self._anims = {}
	self._timer = 1
	self._direction = 1
	self._semi = false
	self._numberOfFrames = 0
	self._offset = nil
	self.loops = 0

	self:add("_",{1})
end


function Animation:update(dt)
	local current = self._current
	if self._numberOfFrames == 1 then self.frame = 1 self.ended = true return end
	if #current.frames == 1 then self.frame = 1 self.ended = true  return end
	if self.stopped or self.paused then return end

	if self.frame ~= math.floor(self._timer) then self._timer = self.frame end

	local speed = self._semi and current.semiSpeed or current.speed

	if current.speedType == "number" then
		self._timer = self._timer + self._direction * speed * dt
	elseif current.speedType == "table" then
		self._timer = self._timer + self._direction * speed[self.frame] * dt
	elseif current.speedType == "function" then
		self._timer = self._timer + self._direction * speed() * dt
	end

	if self._timer > #current.frames + 1 or self._timer < 1 then
		self.ended = true
		if current._ocFunc then
			if not current._ocFuncFirst or self.loops == 0 then
				current._ocFunc(self.loops)
			end
		end

		if current._after then
			if current._afterLoop == self.loops + 1 then
				self:set(current._after)
				return
			end
		end
		if current.mode == "loop" then
			self.loops = self.loops + 1
			self._semi = true
			current.frames = current.semi
			self._timer = self._timer - math.floor(self._timer) + 1
		elseif current.mode == "pingpong" then
			if self._timer < 1 then
				self._direction = 1
				self._timer = 2
				self.loops = self.loops + 1
			else
				self._direction = -1
				self._timer = #current.frames
			end
		elseif current.mode == "once" then
			self.stopped = true
			self._timer = #current.frames
		end
	end

	local oldframe = self.frame
	self.frame = math.floor(self._timer)

	if self.frame ~= oldframe then
		if current._ouFunc then
			current._ouFunc(self.frame, self.loops)
		end
		
		local _oFrame = current._oFrames[self.frame]
		if _oFrame then
			if not _oFrame.first or self.loops == 1 then
				_oFrame.func()
			end
		end
	end

	if current.offsetType == "table" then
		local offset = self._semi and current.semiOffset or current.offset
		self.offset = offset[self.frame]
	end
end


function Animation:_setFrames(numberOfFrames)
	self._numberOfFrames = numberOfFrames
end


local function countnumbers(a, z)
	n = {}
	for i=a,z do
		table.insert(n, i)
	end
	return n
end


function Animation:add(name, frames, speed, mode, offset, semi)
	self._anims._ = nil
	local anim = {}

	if frames then
		if type(frames) == "string" then
			local t = {}

			for part in frames:gmatch("|?([^|]+)|?") do
				if part:find(">") then
					local start, stop = part:match("(%d+)>(.?%d+)")
					local a, b = tonumber(start), tonumber(stop)
					for i=a, b, a > b and -1 or 1 do
						table.insert(t, i)
					end
				else
					for n in part:gmatch("(%d+)") do
						table.insert(t, tonumber(n))
					end
				end
			end

			anim.frames = t
		elseif type(frames) == "table" then
			anim.frames = frames
		else
			anim.frames = {frames}
		end
	else
		anim.frames = lume.numbers(1,self._numberOfFrames)
	end

	
	anim.startFrames = anim.frames

	anim.speed = speed or 12
	anim.speedType = type(anim.speed)

	if anim.speedType == "table" then
		assert(#anim.speed == #anim.frames,"The number of frames (" .. #anim.frames .. ") is not equal to the number of speed steps (" .. #anim.speed .. ")!", 2)
	elseif anim.speedType == "string" then
		local t = {}
		local base = anim.speed:match("%.?%d+")

		for i=1,#anim.frames do
			t[i] = base
		end

		for frame, op, speed in anim.speed:gmatch("(%d+)([><])(.?%d+)") do
			local a = tonumber(op == ">" and frame or 1)
			local b = tonumber(op == ">" and #anim.frames or frame)
			local c = tonumber(speed)
			for i=a,b do t[i] = c end
		end
		
		for frame, speed in anim.speed:gmatch("(%d+)=(%.?%d+)") do
			t[tonumber(frame)] = tonumber(speed)
		end

		anim.speedType = "table"
		anim.speed = t
	end

	anim.mode = mode or "loop"

	assert((anim.mode == "loop" and semi) or not semi, "Semi only works with looping")

	anim.offset = offset or {0,0}
	anim.offsetType = type(anim.offset[1])

	if anim.offsetType == "table" then
		assert(#anim.offset == #anim.frames,"The number of frames (" .. #anim.frames .. ") is not equal to the number of offset steps (" .. #anim.offset .. ")!", 2)
	end

	anim.semi = semi and lume.slice(anim.frames,semi,#anim.frames) or anim.frames
	anim.semiSpeed = anim.speedType == "table" and lume.slice(anim.speed,#anim.frames - #anim.semi + 1, #anim.speed) or anim.speed
	anim.semiOffset = anim.offsetType == "table" and lume.slice(anim.offset,#anim.frames - #anim.semi + 1, #anim.offset) or anim.offset

	anim._oFrames = {}

	anim = setmetatable(anim, mt_anim)

	self._anims[name] = anim
	self:set(name, true)
	return anim
end


function Animation:set(name, force)
	assert(self._anims[name],"The animation " .. name .. " doesn't exist.", 2)
	if self.name ~= name or force then
		self.name = name
		self.ended = false
		self._current = self._anims[name]
		self._current.frames = self._current.startFrames
		self._semi = false
		self.loops = 0
		self.offset = self._current.offset 
		self._timer = 1
		self.frame = 1
		self._direction = 1
		self:play()
	end
	return self._current
end


function Animation:get()
	return self.name
end


function Animation:is(t, ...)
	if type(t) == "string" then
		for i,v in ipairs({t, ...}) do
			if self.name == v then
				return self.name
			end
		end
		return false
	else
		return Animation.super.is(self, t)
	end
	
end


--Plays or resumes the animation
function Animation:play()
	self.playing = true
	if self.stopped then
		self._current.frames = self._current.startFrames
	end
	self.paused = false
	self.stopped = false
	self.ended = false
end


--Does only play the animation if it was paused
function Animation:resume()
	if self.paused then
		self.playing = true
		self.paused = false
	end
end


--Stops, and sets the frame to 1
function Animation:stop()
	self.playing = false
	self.stopped = true
	self.paused = false
	self.frame = 1
end


--Stops, keeps the frame in position. Only works if playing.
function Animation:pause()
	if not self.stopped then
		self.playing = false
		self.paused = true
	end
end


--Restarts the animation
function Animation:restart()
	self.playing = true
	self.paused = false
	self.stopped = false
	self._current.frames = self._current.startFrames
	self.frame = 1
	self.ended = false
end


function Animation:setFrame(frame)
	self.frame = frame
end


function Animation:getFrame()
	return self.frame
end


function Animation:getRealFrame()
	return self._current.frames[self.frame]
end


function Animation:getNumberOfFrames()
	return self._numberOfFrames
end


function Animation:getLoops()
	return self.loops
end


function Animation:has(name)
	return self._anims[name] ~= nil
end


function Animation:trySet(name)
	if self:has(name) then
		return self:set(name)
	end
end


function Animation:clone(name, clone)
	self._anims[clone] = self._anims[name]
end


function Animation:getQuad()
	return self._current.frames[self.frame]
end


return Animation