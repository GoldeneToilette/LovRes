local Scene = {}
Scene.__index = Scene

-- constructor
function Scene.new()
    local self = setmetatable({}, Scene)
    self.objects = {}
    self.lights = {}
    self.skybox = {}
    return self
end

function Scene:addObject(object)
    table.insert(self.objects, object)
end

function Scene:addLight(light)
   table.insert(self.lights, light) 
end

-- Prepares the lights for being sent to the shader
function Scene:prepareLights()
    local newTable = {}
    for _, light in ipairs(self.lights) do
        newTable[#newTable + 1] = light:toArray()
    end

    return newTable
end

function Scene:draw(renderer)
    for i, obj in ipairs(self.objects) do
        obj.draw(renderer)
    end
end

return Scene
