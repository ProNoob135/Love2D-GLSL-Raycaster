local lastModified = {}
local fileInfo = {}

lastModified.shader = {}
local loadedShader
local shaderList = love.filesystem.getDirectoryItems("shaders")
shader = {}

lastModified.texture = {}
local textureList = love.filesystem.getDirectoryItems("textures")
texture = {}

local function errHandler(err)
    print("ERROR: " .. err)
end

function load_shaders(forceLoad)
    for i = 1, #shaderList do
        fileInfo = love.filesystem.getInfo("shaders/" .. shaderList[i])
        if fileInfo.modtime ~= lastModified.shader[i] or forceLoad then
            loadedShader = love.filesystem.read("shaders/" .. shaderList[i])
            if pcall(love.graphics.newShader, loadedShader) or forceLoad then
                shader[string.gsub( shaderList[i], ".frag", "")] = love.graphics.newShader(loadedShader)
                print("test")
            else
                xpcall(love.graphics.newShader, errHandler, loadedShader)
            end
            lastModified.shader[i] = fileInfo.modtime
        end
    end
end

function load_textures(forceLoad)
    for i = 1, #textureList do
        fileInfo = love.filesystem.getInfo("textures/" .. textureList[i])
        if fileInfo.modtime ~= lastModified.texture[i] or forceLoad then
            texture[string.gsub(textureList[i], ".png", "")] = love.graphics.newImage("textures/" .. textureList[i])
            lastModified.texture[i] = fileInfo.modtime
        end
    end
end
