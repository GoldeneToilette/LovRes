local object = require "LovRes.objects.Object"

local Skybox = {}
Skybox.__index = Skybox
setmetatable(Skybox, { __index = object })

-- renders a skybox around the camera. Basically just a cube object thats rendered around a camera
-- also different winding order so you can see it from inside
function Skybox.new()
    local self = setmetatable(object.new("LovRes/meshes/cube.obj", {1,1,1}, {0,0,0}, {1,1,1}), Skybox)

    return self
end

-- draws the skybox. It sends the matrices and other needed parameters to the vertex and fragment shader respectively.
function Skybox:draw(renderer)
        -- load the shader and store it if it doesnt already exist
        if not renderer.shaders[self.material.id] then
            renderer:loadShader(self.material)
        end
        local shader = renderer.shaders[self.material.id]

        love.graphics.setShader(shader)
        -- send the matrices (center the cube around the camera first)
        local camPos = renderer.camera.position
        self.transform:setTransform({camPos[1], camPos[2], camPos[3]}, self.rotation, self.scale)

        shader:send("modelMatrix", self.transform)
        shader:send("projectionMatrix", renderer.camera.projectionMatrix)
        shader:send("viewMatrix", renderer.camera.viewMatrix)

        -- send the material shader (checks if it needs lighting or not)
        self.material:send(shader)

        love.graphics.setMeshCullMode("front")
        love.graphics.setDepthMode("lequal", false)

        love.graphics.draw(self.mesh)

        love.graphics.setDepthMode("lequal", true)
        love.graphics.setMeshCullMode("back")
end

return Skybox
