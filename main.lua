function love.load()
    love.window.setMode(0, 0, {fullscreen = true})
    lovres = require("LovRes").new()

    monkey = lovres:newObject("monkey.obj", {0,0,0}, {0,0,0}, {1,1,1})
end

function love.update(dt)
    lovres.camera:update(dt)
end

function love.draw()
    lovres:start()

    lovres:draw(monkey)

    lovres:stop()
end

function love.mousemoved(x, y, dx, dy)
    lovres.camera:firstPersonMouse(dx, dy, 0.3)
end