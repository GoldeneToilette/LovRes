local Material = {}
Material.__index = Material

-- Parent object for all materials. It holds generic data used by all materials like a missing texture and some default flags.
function Material.new()
    local self = setmetatable({}, Material)
    self.color = {1.0, 0.0, 0.0, 1.0}
    self.shader = nil
    self.missingTexture = love.graphics.newImage("LovRes/MISSING_TEXTURE.png")
    self.missingTexture:setFilter("nearest", "nearest")

    self.id = "placeholder"
    self.hasLighting = false
    self.useTexture = true

    return self
end

-- If set to false, the material will use its color value instead of a texture.
function Material:setUseTexture(flag)
    self.useTexture = flag
end

-- Send the data to the fragment shader. This method is overriden in child classes.
function Material.send(shader) 
    error("The 'send' method should be overridden in a child class")    
end

return Material
