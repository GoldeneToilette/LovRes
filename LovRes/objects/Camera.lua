local matrix = require "LovRes.utils.Matrix"
local vector = require "LovRes.utils.Vector3D"

local Camera = {}
Camera.__index = Camera

-- Creates a new camera. 
function Camera.new()
    local self = setmetatable({}, Camera)    
    self.position = {-7, 0, 0}
    self.up = {0, 1, 0}
    self.lookAt = {0, 0, 0}

    self.fov = math.rad(45)
    self.aspect = love.graphics.getWidth() / love.graphics.getHeight()
    self.near = 0.1
    self.far = 1000

    self.yaw = 0
    self.pitch = 0
    self.mouseLocked = true

    self.viewMatrix = matrix.new()
    self.projectionMatrix = matrix.new()

    self.viewMatrix:viewMatrix(self.position, self.lookAt, self.up)
    self.projectionMatrix:perspectiveMatrix(self.fov, self.aspect, self.near, self.far)
    return self
end

-- This update function updates the cameras matrices
function Camera:update(dt)
    self.viewMatrix:viewMatrix(self.position, self.lookAt, self.up)
    self.projectionMatrix:perspectiveMatrix(self.fov, self.aspect, self.near, self.far)
end

-- Implements first person keyboard movement (put it in love.update(dt))
function Camera:firstPersonKeyboard(dt, speed)
    local forward = {math.cos(self.yaw), 0, math.sin(self.yaw)}
    local right = {math.sin(self.yaw), 0, -math.cos(self.yaw)}

    if love.keyboard.isDown("w") then
        self.position[1] = self.position[1] + forward[1] * speed * dt
        self.position[3] = self.position[3] + forward[3] * speed * dt
    end
    if love.keyboard.isDown("s") then
        self.position[1] = self.position[1] - forward[1] * speed * dt
        self.position[3] = self.position[3] - forward[3] * speed * dt
    end
    if love.keyboard.isDown("a") then
        self.position[1] = self.position[1] + right[1] * speed * dt
        self.position[3] = self.position[3] + right[3] * speed * dt
    end
    if love.keyboard.isDown("d") then
        self.position[1] = self.position[1] - right[1] * speed * dt
        self.position[3] = self.position[3] - right[3] * speed * dt
    end
    if love.keyboard.isDown("lshift") then
        self.position[2] = self.position[2] - speed * dt
    end
    if love.keyboard.isDown("space") then
        self.position[2] = self.position[2] + speed * dt
    end

    self.lookAt[1] = self.position[1] + math.cos(self.yaw) * math.cos(self.pitch)
    self.lookAt[2] = self.position[2] + math.sin(self.pitch)
    self.lookAt[3] = self.position[3] + math.sin(self.yaw) * math.cos(self.pitch)
end

-- Implements first person mouse movement (put it in love.mousemoved())
function Camera:firstPersonMouse(dx, dy, sensitivity)
    if self.mouseLocked then
        love.mouse.setRelativeMode(true)
    end
    
    -- update yaw and pitch
    self.yaw = self.yaw + dx * sensitivity / 200
    self.pitch = self.pitch - dy * sensitivity / 200

    -- clamp the pitch to avoid 90° angles
    self.pitch = math.max(math.min(self.pitch, math.rad(89.9)), math.rad(-89.9))

    -- calculate cosPitch
    local cosPitch = math.cos(self.pitch)

    -- Prevents issues when pitch has extreme values
    if math.abs(self.pitch) < math.rad(89) then
        self.lookAt[1] = self.position[1] + math.cos(self.yaw) * cosPitch
        self.lookAt[2] = self.position[2] + math.sin(self.pitch)
        self.lookAt[3] = self.position[3] + math.sin(self.yaw) * cosPitch
    else
        self.lookAt[1] = self.position[1] + math.cos(self.yaw) * 0.0001
        self.lookAt[2] = self.position[2] + math.sin(self.pitch) * 0.0001
        self.lookAt[3] = self.position[3] + math.sin(self.yaw) * 0.0001
    end
end

-- Returns the normalized frustum planes of the camera
function Camera:getFrustum()
    local m = self.projectionMatrix:multiplyMatrix(self.viewMatrix)
    local planes = {
        {normal = {m[4] + m[1], m[8] + m[5], m[12] + m[9]}, distance = m[16] + m[13]},
        {normal = {m[4] - m[1], m[8] - m[5], m[12] - m[9]}, distance = m[16] - m[13]},
        {normal = {m[4] + m[2], m[8] + m[6], m[12] + m[10]}, distance = m[16] + m[14]},
        {normal = {m[4] - m[2], m[8] - m[6], m[12] - m[10]}, distance = m[16] - m[14]},
        {normal = {m[4] - m[3], m[8] - m[7], m[12] - m[11]}, distance = m[16] - m[15]},
        {normal = {m[4] + m[3], m[8] + m[7], m[12] + m[11]}, distance = m[16] + m[15]}
    }
    
    -- normalize the planes
    for i, plane in ipairs(planes) do
        local n = plane.normal
        local magnitude = vector.magnitude(n)
        plane.normal = vector.normalize(n)
        plane.distance = plane.distance / magnitude
    end

    return planes
end

-- Checks if a 3D point is inside the frustum
function Camera:isPositionInFrustum(position)
    local position4D = {position[1], position[2], position[3], 1}
    
    local view = self.viewMatrix:multiplyVector(position4D)
    local clip = self.projectionMatrix:multiplyVector(view)

    local x, y, z, w = clip[1], clip[2], clip[3], clip[4]

    if x < -w or x > w or y < -w or y > w or z < -w or z > w then
        return false
    end

    return true
end

-- checks if a sphere intersects with the frustum
function Camera:isSphereInFrustum(c, r)
    local view = self.viewMatrix:multiplyVector({c[1], c[2], c[3], 1})
    local clip = self.projectionMatrix:multiplyVector(view)
    local x, y, z, w = clip[1], clip[2], clip[3], clip[4]

    x, y, z = x / w, y / w, z / w

    local planes = self:getFrustum()
    for _, plane in ipairs(planes) do
        local distance = math.abs(plane.normal[1] * x + plane.normal[2] * y + plane.normal[3] * z + plane.distance) 
        / math.sqrt(plane.normal[1]^2 + plane.normal[2]^2 + plane.normal[3]^2)
        if distance > r then
            print("CULLED!")
            return false
        end
    end

    return true
end

return Camera