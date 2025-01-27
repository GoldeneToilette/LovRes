local Scene = {}
Scene.__index = Scene

-- constructor
function Scene.new()
    local self = setmetatable({}, Scene)
    self.objects = {}
    self.lights = {}

    return self
end


return Scene
