local Material = require "LovRes.objects.Material"

local UnlitMaterial = {}
UnlitMaterial.__index = UnlitMaterial
setmetatable(UnlitMaterial, { __index = Material })

-- Unlit material. Only supports a texture and color
function UnlitMaterial.new(texture)
    local self = setmetatable(Material.new(), UnlitMaterial)
    self.texture = texture or nil
    self.shader = "LovRes/shaders/Unlit.glsl"
    self.id = "Unlit"

    return self
end

-- send the material properties to the given shader
function UnlitMaterial:send(shader)
    if not shader then return end -- prevents crash if no shader exists
    shader:send("u_texture", self.texture or self.missingTexture)
    shader:send("u_useTexture", self.useTexture)
    shader:send("u_color", self.color)
end

return UnlitMaterial