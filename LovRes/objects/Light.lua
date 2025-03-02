-- Directional light
local DirectionalLight = {}
DirectionalLight.__index = DirectionalLight

function DirectionalLight.new(direction, color, intensity)
    local self = setmetatable({}, DirectionalLight)
    self.direction = direction or {0, -1, 0}
    self.color = color or {1, 1, 1}
    self.intensity = intensity or 1.0
    self.type = 2

    return self
end

function DirectionalLight:toArray()
    return {
        self.type,
        self.direction[1],
        self.direction[2],
        self.direction[3],
        self.color[1],
        self.color[2],
        self.color[3],
        self.intensity
    }
end

-- Point light
local PointLight = {}
PointLight.__index = PointLight

function PointLight.new(position, color, intensity, attenuation)
    local self = setmetatable({}, PointLight)
    self.position = position or {0, 0, 0}
    self.color = color or {1, 1, 1}
    self.intensity = intensity or 1.0
    self.attenuation = attenuation or {constant = 1.0, linear = 0.09, quadratic = 0.032}
    self.type = 1

    return self
end

function PointLight:toArray()
    return {
        self.type,
        self.position[1],
        self.position[2],
        self.position[3],
        self.color[1],
        self.color[2],
        self.color[3],
        self.intensity,
        self.attenuation.constant,
        self.attenuation.linear,
        self.attenuation.quadratic
    }
end


-- Spotlight
local SpotLight = {}
SpotLight.__index = SpotLight

function SpotLight.new(position, direction, angle, color, intensity, attenuation)
    local self = setmetatable({}, SpotLight)
    self.position = position or {0, 0, 0}
    self.direction = direction or {0, -1, 0}
    self.angle = angle or 30
    self.color = color or {1, 1, 1}
    self.intensity = intensity or 1.0
    self.attenuation = attenuation or {constant = 1.0, linear = 0.09, quadratic = 0.032}
    self.type = 3

    return self
end

function SpotLight:toArray()
    return {
        self.type,
        self.position[1],
        self.position[2],
        self.position[3],
        self.direction[1],
        self.direction[2],
        self.direction[3],
        self.angle,
        self.color[1],
        self.color[2],
        self.color[3],
        self.intensity,
        self.attenuation.constant,
        self.attenuation.linear,
        self.attenuation.quadratic
    }
end

return {
    DirectionalLight = DirectionalLight,
    PointLight = PointLight,
    SpotLight = SpotLight
}
