local Material = require "LovRes/objects/Material"

local UnlitMaterial = {}
UnlitMaterial.__index = UnlitMaterial
setmetatable(UnlitMaterial, Material)

-- constructor
function UnlitMaterial.new(texture)
    local self = Material.new()
    setmetatable(self, UnlitMaterial)
    self.texture = texture or nil
    self.shader = "LovRes/shaders/Unlit.glsl"
    self.id = "Unlit"

    return self
end

-- send the material properties to the given shader
function UnlitMaterial:send(shader)
    if self.texture then
        shader:send("u_texture", self.texture)
        shader:send("u_useTexture", true)
    else
        shader:send("u_texture", self.missingTexture)
        shader:send("u_useTexture", false)
    end

    shader:send("u_color", self.color)
end

return UnlitMaterial