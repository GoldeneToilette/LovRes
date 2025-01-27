local matrix = require "LovRes.utils.Matrix"
local parser = require "LovRes.utils.MeshParser"
local unlitMaterial = require "LovRes.objects.materials.UnlitMaterial"

local Object = {}
Object.__index = Object

local vertexFormat = {
    {"VertexPosition", "float", 3},
    {"VertexUV", "float", 2},
    {"VertexNormal", "float", 3},
    {"VertexColor", "float", 4}
}

local instanceFormat = {
    {"InstancePosition", "float", 3}
}

-- constructor
function Object.new(mesh, position, rotation, scale)
    local self = setmetatable({}, Object)
    self.position = position or {0, 0, 0}
    self.rotation = rotation or {0, 0, 0}
    self.scale = scale or {1, 1, 1}
    self.visible = true
    self.vertices = {}
    self.mesh = {}
    self:setupMesh(mesh)

    self.transform = matrix.new()
    self.transform:setTransform(self.position, self.rotation, self.scale)

    self.material = unlitMaterial.new()
    return self
end
  
function Object:setupMesh(mesh)
    if type(mesh) == "string" then
        self.vertices = parser.parse(mesh)
        self.mesh = love.graphics.newMesh(vertexFormat, self.vertices, "triangles")
    else
        self.mesh = mesh
    end
    self.instancemesh = love.graphics.newMesh(instanceFormat, {{nil, nil, nil}}, nil, "static")
    self.mesh:attachAttribute("InstancePosition", self.instancemesh, "perinstance")
end

function Object:setInstances(vertices)
    self.instancemesh = love.graphics.newMesh(instanceFormat, vertices, nil, "static")
    self.mesh:attachAttribute("InstancePosition", self.instancemesh, "perinstance")    
end

function Object:setVisible(flag)
    self.visible = flag
end

function Object:setTransform(position, rotation, scale)
    self.position = position 
    self.rotation = rotation
    self.scale = scale
end

function Object:setPosition(x, y, z)
    self.position = {x, y, z}
end

function Object:setRotation(x, y, z)
    self.rotation = {x, y, z}
end

function Object:setScale(x, y, z)
    self.scale = {x, y, z}
end

function Object:update(dt)
    self.transform:setTransform(self.position, self.rotation, self.scale)
end

function Object:draw(renderer)
    if self.visible then
        -- load the shader and store it
        if not renderer.shaders[self.material.id] then
            renderer:loadShader(self.material)
        end
        local shader = renderer.shaders[self.material.id]

        love.graphics.setShader(shader)
        -- send the matrices
        shader:send("modelMatrix", self.transform)
        shader:send("projectionMatrix", renderer.camera.projectionMatrix)
        shader:send("viewMatrix", renderer.camera.viewMatrix)

        -- send the material shader
        self.material:send(shader)

        -- if there are instances render them, otherwise just draw the mesh
        if self.instancemesh then
            love.graphics.drawInstanced(self.mesh, self.instancemesh:getVertexCount())
        else
            love.graphics.draw(self.mesh)
        end
    end
end

return Object
