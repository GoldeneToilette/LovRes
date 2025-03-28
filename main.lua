local skybox = require "LovRes.objects.Skybox"

function love.load()
    love.window.setMode(0, 0, {fullscreen = true})
    lovres = require("LovRes").new()

    cube = lovres:newObject("LovRes/meshes/cube.obj", {5, 0, 5}, {0, 0, 0}, {0.5, 0.5, 0.5})
    cube.material.texture = love.graphics.newImage("DIRT.png")
    cube.material.texture:setFilter("nearest", "nearest")

    -- generates a simple plane
    local gridSize = 100
    local instancePositions = {}
    for x = 0, gridSize - 1 do
        for z = 0, gridSize - 1 do
            table.insert(instancePositions, {x, 0, z})
        end
    end

    cube:setInstances(instancePositions)

    scene = lovres.newScene()
    scene:addObject(cube)
    scene.skybox.material.texture = love.graphics.newImage("sky.png")
end

function love.update(dt)
    lovres.camera:firstPersonKeyboard(dt, 10)
    lovres.camera:update(dt)
end

function love.draw()
    lovres:start()

    lovres:draw(scene)

    lovres:stop()
end

function love.mousemoved(x, y, dx, dy)
    lovres.camera:firstPersonMouse(dx, dy, 0.3)
end

function love.keypressed(key, scancode, isrepeat)
    if key == "escape" then
        love.event.quit()
    end
end

