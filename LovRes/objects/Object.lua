local matrix = require "LovRes.utils.Matrix"
local parser = require "LovRes.utils.MeshParser"
local unlitMaterial = require "LovRes.objects.materials.UnlitMaterial"

local Object = {}
Object.__index = Object

Object.vertexFormat = {
    {"VertexPosition", "float", 3},
    {"VertexUV", "float", 2},
    {"VertexNormal", "float", 3}
}

Object.instanceFormat = {
    {"InstancePosition", "float", 3}
}

-- Creates a new object. A object is basically just a mesh with a position, rotation, scale and a material.
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

-- Internal function for parsing the mesh data and creating the mesh.
function Object:setupMesh(mesh)
    if type(mesh) == "string" then
        self.vertices, self.vertexMap = parser.parse(mesh)
        self.mesh = love.graphics.newMesh(self.vertexFormat, self.vertices, "triangles")
        self.mesh:setVertexMap(self.vertexMap)
    else
        self.mesh = mesh
    end
    self.instancemesh = love.graphics.newMesh(self.instanceFormat, {{nil, nil, nil}}, nil, "static")
    self.mesh:attachAttribute("InstancePosition", self.instancemesh, "perinstance")
end

-- Creates instances for the mesh. Format: {"InstancePosition", "float", 3}
function Object:setInstances(vertices)
    self.instancemesh = love.graphics.newMesh(self.instanceFormat, vertices, nil, "static")
    self.mesh:attachAttribute("InstancePosition", self.instancemesh, "perinstance")
end

-- Set the visibility of the object. If visible is set to false, it will be skipped during rendering.
function Object:setVisible(flag)
    self.visible = flag
end

-- Set the position, rotation and scale of the object.
function Object:setTransform(position, rotation, scale)
    self.position = position 
    self.rotation = rotation
    self.scale = scale

    self.transform:setTransform(self.position, self.rotation, self.scale)
end

-- Set the position of the object.
function Object:setPosition(x, y, z)
    self.position = {x, y, z}

    self.transform:setTransform(self.position, self.rotation, self.scale)
end

-- Set the rotation of the object in euler angles.
function Object:setRotation(x, y, z)
    self.rotation = {x, y, z}

    self.transform:setTransform(self.position, self.rotation, self.scale)
end

-- Set the scale of the object.
function Object:setScale(x, y, z)
    self.scale = {x, y, z}

    self.transform:setTransform(self.position, self.rotation, self.scale)
end

-- Update function. As of right now, it only updates the transform of the object.
function Object:update(dt)
    self.transform:setTransform(self.position, self.rotation, self.scale)
end

-- Set the material of the object.
function Object:setMaterial(material)
    self.material = material
end

-- Draws the object. It sends the matrices and other needed parameters to the vertex and fragment shader respectively.
function Object:draw(renderer, preparedLights)
    if self.visible then
        -- load the shader and store it if it doesnt already exist
        if not renderer.shaders[self.material.id] then
            renderer:loadShader(self.material)
        end
        local shader = renderer.shaders[self.material.id]

        love.graphics.setShader(shader)
        -- send the matrices
        shader:send("modelMatrix", self.transform)
        shader:send("projectionMatrix", renderer.camera.projectionMatrix)
        shader:send("viewMatrix", renderer.camera.viewMatrix)

        -- send the material shader (checks if it needs lighting or not)
        self.material:send(shader)

        -- send all lights
        if preparedLights then
            for i, lightArray in ipairs(preparedLights) do
                shader:send("lights["..i.."]", lightArray)
            end
        end

        -- if there are instances render them, otherwise just draw the mesh
        if self.instancemesh then
            love.graphics.drawInstanced(self.mesh, self.instancemesh:getVertexCount())
        else
            love.graphics.draw(self.mesh)
        end
    end
end

return Object
