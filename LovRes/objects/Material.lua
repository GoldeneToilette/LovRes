local Material = {}
Material.__index = Material

-- constructor
function Material.new()
    local self = setmetatable({}, Material)
    self.color = {1.0, 0.0, 0.0, 1.0}
    self.shader = nil
    self.missingTexture = love.graphics.newImage("/LovRes/MISSING_TEXTURE.png")
    self.id = "placeholder"
    self.hasLighting = false
    self.useTexture = true

    return self
end

function Material:setUseTexture(flag)
    self.useTexture = flag
end

function Material.send(shader) 
    error("The 'send' method should be overridden in a child class")    
end

return Material
