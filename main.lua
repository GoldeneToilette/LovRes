function love.load()
    love.window.setMode(0, 0, {fullscreen = true})
    lovres = require("LovRes").new(4)

    cube = lovres:newObject("cube.obj", {5, 0, 5}, {0, 0, 0}, {0.5, 0.5, 0.5})
    cube.material:setUseTexture(false)
    cube.material.color = {1.0, 1.0, 1.0, 1.0}
    cube:setInstances({{1,0,1}, {2,0,2}})
end

function love.update(dt)
    lovres.camera:firstPersonKeyboard(dt, 10)
    lovres.camera:update(dt)
end

function love.draw()
    lovres:start()

    lovres:draw(cube)

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

