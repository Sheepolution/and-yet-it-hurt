--
-- buddies 
--
-- Copyright (c) 2015 Sheepolution
--
-- This library is free software; you can redistribute it and/or modify it
-- under the terms of the MIT license. See LICENSE for details.

local buddies = {}
local func = {}
local superfunc = {}

function buddies:__index(f)
	if type(f) == "string" then
		if f:sub(f:len(),f:len()) == "_" then
			local k = f:sub(0,f:len()-1)
			self[f] = function (self,...)
				for i=1,#self do
					if self[i][k] then
						self[i][k](self[i],...)
					end
				end
			end
		else
			self[f] = function (self,...)
				for i=#self,1,-1 do
					if self[i] and self[i][f] then
						self[i][f](self[i],...)
					end
				end
			end
		end
		return self[f]
	end
end


function buddies.new(a, ...)
	local t
	if a == true then
		t =  setmetatable({
		add = superfunc.add, 
		count = superfunc.count,
		find = superfunc.find,
		table = superfunc.table,
		clone = superfunc.clone,
		others = superfunc.others,
		others_ = superfunc.others_,
		}, buddies)
		for i,v in ipairs({...}) do
			table.insert(t, v)
		end
	else
		t =  setmetatable({
		add = func.add,
		addAt = func.addAt,
		remove = func.remove,
		removeIf = func.removeIf,
		count = func.count,
		find = func.find,
		table = func.table,
		clone = func.clone,
		call = func.call,
		call_ = func.call_,
		others = func.others,
		others_ = func.others_,
		flush = func.flush,
		set = func.set,
		sort = func.sort
		}, buddies)
		t:add(a, ...)
	end
	return t
end


function func:add(...)
	for i,v in ipairs({...}) do
		table.insert(self, v)
	end
end


function func:addAt(p, v)
	table.insert(self, p, v)
end

--Removes the object. If a number is passed, the object on that position will be removed instead.
function func:remove(obj)
	t = type(obj)
	
	local kill = 0
	
	if t == "table" then
		for i=1,#self do
			if self[i] == obj then
				kill = i
				break
			end
		end
	elseif t == "number" then
		kill = obj
	end

	if kill > 0 then
		if #self == 1 then
			self[1] = nil
		else
			for i=kill + 1,#self do
				self[i-1] = self[i]
			end

			self[#self] = nil
		end
	end
end


function func:removeIf(func)
	for i=#self,1,-1 do
		if func(self[i]) then
			self:remove(self[i])
		end
	end
end


function func:find(func)
	local t = {}
	for i=#self,1,-1 do
		if func(self[i]) then
			table.insert(t, self[i])
		end
	end
	return t
end


function func:table()
	local t = {}
	for i=#self,1,-1 do
		table.insert(t, self[i])
	end
	return t
end


function func:clone()
	return buddies.new(unpack(self:table()))
end


function func:count(func)
	local a = 0
	for i=1,#self do
		if func(self[i]) then
			a = a + 1
		end
	end
	return a
end

--Calls the passed function for each object, passing the object as first argument.
function func:call(func)
	for i=#self,1,-1 do
		func(self[i])
	end
end

function func:call_(func)
	for i=1,#self do
		func(self[i])
	end
end

--Has all the objects iterate through the other objects, allowing for interactivity.
--Calls the passed function, giving both objects as arguments.
function func:others(func)
	for i=#self,2,-1 do
		for j=i-1,1,-1 do
			if func(self[i],self[j]) then break end
		end
	end
end


function func:others_(func)
	for i=1,#self-1 do
		for j=i+1,#self do
			if func(self[i],self[j]) then break end
		end
	end
end

--Sets a value to all the objects.
--Will only set the value if the object already has the property, unless force is true.
function func:set(k,v,force)
	for i=1,#self do
		if force or self[i][k]~=nil then
			self[i][k] = v
		end
	end
end

--Removes all the objects, but keeps the functions.
function func:flush()
	for i=1,#self do
		self[i] = nil
	end
end

--Sorts all the objects on a property.
--If an object does not have the passed property, it will be treated as 0.
--Will automatically sort from low to high, unlesss htl (high to low) is true.
function func:sort(k,htl)
	local sorted = false
	while not sorted do
		sorted = true
		for i=1,#self-1 do
			for j=i+1,#self do
				local propA, propB
				propA = self[i][k] or 0
				propB = self[j][k] or 0
				
				if (htl and propA < propB) or (not htl and propA > propB) then
					local old = self[j]
					self[j] = self[i]
					self[i] = old
					sorted = false
				end
			end
		end
	end
end


function superfunc:add(n, ...)
	assert(type(n) == "number", "Superbuddy needs a number as first argument", 2)
	self[n]:add(...)
end

function superfunc:count(func)
	local a
	for i,v in ipairs(self) do
		a = a + v:count(func)
	end
	return a
end


function superfunc:others(func)
	local t = self:find(function () return true end)
	for i=#t,2,-1 do
		for j=i-1,1,-1 do
			if func(t[i],t[j]) then break end
		end
	end
end


function superfunc:others_(func)
	local t = self:find(function () return true end)
	for i=#t,#t-1 do
		for j=i+1,#t do
			if func(t[i],t[j]) then break end
		end
	end
end


function superfunc:find(func)
	local t = {}
	for i,v in ipairs(self) do
		for j,w in ipairs(v:find(func)) do
			table.insert(t, w)
		end
	end
	return t
end


function superfunc:table()
	local t = {}
	for i,v in ipairs(self) do
		for j,w in ipairs(v:table()) do
			table.insert(t, w)
		end
	end
	return t
end

function superfunc:clone()
	return buddies.new(unpack(self:table()))
end

return buddies