lume = require "libs.lume"
oldprint = print
print = DEBUG and lume.trace or function () end
assert = lume.assert

Object = require "libs.classic"
tick = require "libs.tick"
coil = require "libs.coil"

-- My own :)
buddies = require "libs.buddies"

local libs = {}

function libs.update(dt)
	tick.update(dt)
	coil.update(dt)
end

return libs