local skybox = require "LovRes.objects.Skybox"

local Scene = {}
Scene.__index = Scene

-- Creates a new scene. Scenes hold objects, lights and the skybox. 
function Scene.new()
    local self = setmetatable({}, Scene)
    self.objects = {}
    self.lights = {}
    self.skybox = skybox.new()
    return self
end

-- Adds an object to the scene
function Scene:addObject(object)
    table.insert(self.objects, object)
end

-- Adds a light to the scene
function Scene:addLight(light)
   table.insert(self.lights, light) 
end

-- Turns the light data into arrays so it can be sent to the shaders
function Scene:prepareLights()
    local newTable = {}
    for _, light in ipairs(self.lights) do
        newTable[#newTable + 1] = light:toArray()
    end

    return newTable
end

-- draws the entire scene
function Scene:draw(renderer)
    -- render skybox before everything else
    self.skybox:draw(renderer)

    -- render rest of the objects
    for i, obj in ipairs(self.objects) do
        obj:draw(renderer)
    end
end

return Scene
