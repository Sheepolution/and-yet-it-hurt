--[[

MIT License

Copyright (c) 2020 Sheepolution

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.

]]

-- Give a second argument to run in debug mode
RELEASE = arg[2] == nil
DEBUG = not RELEASE

local paths  = love.filesystem.getRequirePath()
love.filesystem.setRequirePath(paths .. ";scripts/?.lua;scripts/?/init.lua;")

DIRECTORY = love.filesystem.getSaveDirectory()

local libs = require "libs"
local base = require "base"

local sm

DEBUG = true

ADMIN = false

function love.load()
oldprint([[  ___,                                          _ 
 /   |             |                           | |
|    |   _  _    __|           _ _|_   o _|_   | |            ,_  _|_  
|    |  / |/ |  /  |    |   | |/  |    |  |    |/ \   |   |  /  |  |   
 \__/\_/  |  |_/\_/|_/   \_/|/|__/|_/  |_/|_/  |   |_/ \_/|_/   |_/|_/ 
                            /|
                            \|   by Sheepolution

Close Notepad to re-open the game folder.
Close this window to quit the game.

Version 1.1.1]])

    os.execute("title And yet it hurt")

    for i,v in ipairs(require "require") do
        local succes, msg = pcall(require, v)
        if not succes then
            if msg:match("not found:") then
                requireDir("scripts." .. v)
            else
                error(msg)
            end
        end 
    end

    local function deleteFolder( item )
        if love.filesystem.getInfo( item , "directory" ) then
            for _, child in pairs( love.filesystem.getDirectoryItems( item )) do
                deleteFolder( item .. '/' .. child )
                love.filesystem.remove( item .. '/' .. child )
            end
        elseif love.filesystem.getInfo( item ) then
            love.filesystem.remove( item )
        end
        love.filesystem.remove( item )
    end

    local info = love.filesystem.getInfo(".notepad/Notepad2.exe")
    if not info then
        local exe = love.filesystem.newFileData("_notepad/Notepad2.exe" )
        local ini = love.filesystem.newFileData("_notepad/Notepad2.ini" )
        local dll1 = love.filesystem.newFileData("_notepad/msvcp140.dll" )
        local dll2 = love.filesystem.newFileData("_notepad/vcruntime140.dll" )
        love.filesystem.createDirectory(".notepad")
        love.filesystem.write(".notepad/Notepad2.exe", exe)
        love.filesystem.write(".notepad/Notepad2.ini", ini)
        love.filesystem.write(".notepad/msvcp140.dll", dll1)
        love.filesystem.write(".notepad/vcruntime140.dll", dll2)
    end

    info = love.filesystem.getInfo(".data")
    if not info then
        local data = {version = "1.1.1"}
        love.filesystem.write(".data", lume.serialize(data))
    end

    local data = lume.deserialize(love.filesystem.read(".data"))

    DATA = data
    if DATA.admin then
        ADMIN = true
    else
        love.timer.sleep(.2)
        local error_code = os.execute([[assoc .tхt=tхt > NUL 2>&1
        ftype tхt=]] .. DIRECTORY ..  [[/.notepad/Notepad2.exe "%1" > NUL 2>&1]])

        if error_code == 0 then
            ADMIN = true
            DATA.admin = true
            love.filesystem.write(".data", lume.serialize(DATA))
            oldprint("Successfully configured. You can now open the files by double clicking.")
        end
    end

if RELEASE then
    oldprint = function () end
    print = function () end
end

    if not data.save then
        data.save = {}
    end

    SAVE = data.save

    if not ADMIN then
        os.execute('start "" "' .. DIRECTORY .. '/.notepad/Notepad2.exe" > NUL 2>&1')
    end

    -- Delete the game folder, if it exists.
    local info = love.filesystem.getInfo("Game")
    if info then
        deleteFolder("Game")
        love.timer.sleep(.2)
    end
    love.filesystem.createDirectory("Game")
    love.timer.sleep(.2)
    os.execute('start "" "' .. DIRECTORY .. '/Game" > NUL 2>&1')

    sm = require("game")()

    timer = 0
    reopened = 0
end

function love.update(dt)
    -- If for some reason the command doesn't work and after 3 times it still tries to reopen Notepad, just quit.
    if reopened < 3 then
        timer = timer + dt
        if timer > 2 then
            timer = 0
            -- Find an instance of Notepad2.exe
            local error_code = os.execute([[tasklist /FI "IMAGENAME eq Notepad2.exe" | find /I /N "Notepad2.exe" > NUL 2>&1]])
            if error_code ~= 0 then
                -- Error, meaning no instance of Notepad2.exe has been found. Open Notepad2.exe again.
                reopened = reopened + 1
                os.execute('start "" "' .. DIRECTORY .. '/.notepad/Notepad2.exe" 2>NUL')
                os.execute('start "" "' .. DIRECTORY .. '/Game" 2>NUL')
            else
                reopened = 0
            end
        end
    end
    sm:update(dt)
end