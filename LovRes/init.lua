--[[
MIT License

Copyright (c) 2025 glittershitter

Permission is hereby granted, free of charge, to any person obtaining a copy
of this software and associated documentation files (the "Software"), to deal
in the Software without restriction, including without limitation the rights
to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
copies of the Software, and to permit persons to whom the Software is
furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all
copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE
SOFTWARE.
]]--
local cam = require "LovRes.objects.Camera"
local object = require "LovRes.objects.Object"
local scene = require "LovRes.objects.Scene"
local light = require "LovRes.objects.Light"

local LovRes = {}
LovRes.__index = LovRes

-- Creates an instance of the renderer. This is where everything happens basically.
function LovRes.new(pixelSize, width, height)
    local self = setmetatable({}, LovRes)
    self.vertexPath = love.filesystem.read("LovRes/shaders/LovRes.vert")
    self.shaders = {}

    self.pixelSize = pixelSize or 1
    self.width = width or love.graphics.getWidth()
    self.height = height or love.graphics.getHeight()

    self.canvasWidth = math.floor(self.width / self.pixelSize) 
    self.canvasHeight = math.floor(self.height / self.pixelSize)
    self.mainCanvas = love.graphics.newCanvas(self.canvasWidth, self.canvasHeight, { format = "normal" })
    self.mainCanvas:setFilter("nearest", "nearest")

    self.depthCanvas = love.graphics.newCanvas(self.canvasWidth, self.canvasHeight, { format = "depth24" })

    -- settings
    love.graphics.setFrontFaceWinding("ccw")
    love.graphics.setMeshCullMode("back")
    love.graphics.setDepthMode("lequal", true)

    self.camera = cam.new()

    self.drawing = false
    return self
end

-- Loads a shader into the shader table. These shaders will be used across multiple objects.
-- Accepts either a string path or a material object as parameter
function LovRes:loadShader(shaderPath)
    -- path
    if type(shaderPath) == "string" then
        local name = shaderPath:match("([^/]+)$"):match("^(.*)%.")

        self.shaders[name] = love.graphics.newShader(self.vertexPath, shaderPath)
    -- material object
    elseif type(shaderPath) == "table" then
        self.shaders[shaderPath.id] = love.graphics.newShader(self.vertexPath, shaderPath.shader)
        print(#self.shaders)
    else
        error("Unknown shader type! Use a path or material object")
    end
end

-- Start of rendering. This function prepares the canvas.
function LovRes:start()
    if not self.drawing then
        self.drawing = true
        love.graphics.setCanvas({
            self.mainCanvas, 
            depthstencil = self.depthCanvas
        })
        love.graphics.clear(0, 0, 0.1, 1)
    end
end

-- Function for drawing objects and scenes to the canvas. This has to be between start() and stop()
function LovRes:draw(object)
    object:draw(self)
end

-- End of rendering. This is where the canvas is drawn to the screen.
function LovRes:stop()
    if self.drawing then
        love.graphics.setCanvas()
        love.graphics.setShader()
        love.graphics.draw(self.mainCanvas, 0, 0, 0, self.pixelSize, self.pixelSize)
        self.drawing = false
    end
end

-- Creates a new object. Valid file types: ".obj"
function LovRes:newObject(path, position, rotation, scale) 
    return object.new(path, position, rotation, scale)
end

-- Creates a new scene. Scenes allow you to make more complex stuff like lighting and shadows. 
function LovRes:newScene()
    return scene.new()
end

-- Creates a new light ("point", "directional", "spot")
function LovRes:newLight(type, ...)
    if type == "point" then
        return light.PointLight.new(...)
    elseif type == "directional" then
        return light.DirectionalLight.new(...)
    elseif type == "spot" then
        return light.SpotLight.new(...)
    else
        error("Unknown light type: " .. type)
    end
end

-- keeps track of all materials and their corresponding file path (might refactor later)
local Materials = {
    unlit = "LovRes.objects.materials.UnlitMaterial",
    lit = "LovRes.objects.materials.LitMaterial"
}


-- Creates a new material. Materials define how the objects look like.
-- They hold data like textures, maps and references to shaders.
-- The actual shaders are loaded into a seperate table so they can be reused across objects.
function LovRes:newMaterial(key, ...)
    local materialPath = Materials[key]
    if materialPath then
        local materialClass = require(materialPath)
        return materialClass.new(...)
    else
        error("Material with key '" .. key .. "' not found.")
    end
end

return LovRes