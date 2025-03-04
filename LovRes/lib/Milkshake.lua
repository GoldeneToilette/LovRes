-- Small library for adding camera effects (WIP)

local Milkshake = {}
Milkshake.__index = Milkshake

-- Subtle idle animation. Arguments: amplitude (intensity), speed
local function idle(position, lookAt, up, args, speed, dt)
    local breathingAmplitude = args.breathing or 0.1
    local jitterAmplitude = args.jitter or 0.02
    local maxJitter = args.maxJitter or 0.01
    local heartbeatAmplitude = args.heartbeat or 0.05

    local time = os.clock()

    -- breathing effect with jitter applied to the breathing offset
    local breathingOffset = (math.sin(time * speed) * breathingAmplitude + (math.random() - 0.5) * jitterAmplitude) * dt
    position[2] = position[2] + breathingOffset

    -- heartbeat
    local heartbeatOffset = math.sin(time * speed*1.5) * heartbeatAmplitude * dt
    position[2] = position[2] + heartbeatOffset

    -- clamping so the camera doesnt wander off
    position[1] = position[1] + math.max(math.min((math.random() - 0.5) * jitterAmplitude * dt, maxJitter), -maxJitter)
    position[3] = position[3] + math.max(math.min((math.random() - 0.5) * jitterAmplitude * dt, maxJitter), -maxJitter)

    return position, lookAt, up
end

-- these functions return position, lookAt and up
local ShakeTypes = {
    idle = idle,
    walking = function() end,
    running = function() end,
}

-- constructor
function Milkshake.new(shake, speed, args)
    local self = setmetatable({}, Milkshake)
    self.shake = Milkshake:setShake(shake)
    self.speed = speed or 1.0
    self.args = args or {}
    self.paused = false

    return self
end

-- set the noise, takes a string or a custom function
function Milkshake:setShake(shake)
    if type(shake) == "function" then
        return shake
    elseif type(shake) == "string" then
        local shakeFunction = ShakeTypes[shake]
        if not shakeFunction then
            error("Unsupported shake type: " .. shake)
        end
        return shakeFunction
    else
        error("Invalid shake type. Must be a function or a string.")
    end
end

-- pause the noise; if no flag is provided, current one will be toggled
function Milkshake:setPaused(flag)
    if flag == nil then
        self.paused = not self.paused
    else
        self.paused = flag
    end
end

-- applies the noise to a view matrix
function Milkshake:update(position, lookAt, up, dt)
    if self.paused or not self.shake then
        return
    end

    return self.shake(position, lookAt, up, self.args, self.speed, dt)
end

return Milkshake
