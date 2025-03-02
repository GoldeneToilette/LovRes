local Material = require "LovRes/objects/Material"

local LitMaterial = {}
LitMaterial.__index = LitMaterial
setmetatable(LitMaterial, { __index = Material })

-- constructor
function LitMaterial.new(texture, normal)
    local self = setmetatable(Material.new(), LitMaterial)
    self.texture = texture
    self.normal = normal or texture
    self.shader = "LovRes/shaders/Lit.glsl"
    self.id = "Lit"
    self.hasLighting = true

    return self
end

-- send the material properties to the given shader
function LitMaterial:send(shader)
    if not shader then return end -- prevents crash if no shader exists
    shader:send("u_texture", self.texture or self.missingTexture)
    shader:send("u_useTexture", self.useTexture)

    shader:send("u_normalMap", self.normal)
    
    shader:send("u_color", self.color)
end

return LitMaterial