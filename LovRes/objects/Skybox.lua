local unlitMaterial = require "LovRes.objects.materials.UnlitMaterial"

local Skybox = {}
Skybox.__index = Skybox

-- renders a skybox around the camera
function Skybox.new(scale, material)
    local self = setmetatable({}, Skybox)
    self.scale = scale or 100
    self.material = material or unlitMaterial.new(love.graphics.newImage("/LovRes/MISSING_TEXTURE.png"))

    return self
end

return Skybox
