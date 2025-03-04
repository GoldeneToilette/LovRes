function love.load()
    love.window.setMode(0, 0, {fullscreen = true})
    lovres = require("LovRes").new()

    monkey = lovres:newObject("monkey.obj", {0,0,0}, {0,0,0}, {1,1,1})

    monkey2 = lovres:newObject("monkey.obj", {5,0,5}, {0,180,90}, {1,1,1})
end

function love.update(dt)
    lovres.camera:firstPersonKeyboard(dt, 10)
    lovres.camera:update(dt)
end

function love.draw()
    lovres:start()

    lovres:draw(monkey)
    lovres:draw(monkey2)

    lovres:stop()
end

function love.mousemoved(x, y, dx, dy)
    lovres.camera:firstPersonMouse(dx, dy, 0.3)
end

function love.keypressed(key, scancode, isrepeat)
    if key == "escape" then
       love.event.quit()
    end

    if key == "z" then
        monkey2.material:setUseTexture(not monkey2.material.useTexture)
    end
 end