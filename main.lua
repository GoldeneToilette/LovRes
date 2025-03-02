function love.load()
    love.window.setMode(0, 0, {fullscreen = true})
    lovres = require("LovRes").new(3)

    monkey = lovres:newObject("monkey.obj", {0,0,0}, {0,0,0}, {1,1,1})

    monkey2 = lovres:newObject("monkey.obj", {5,0,5}, {0,0,0}, {1,1,1})
    monkey2.material.texture = love.graphics.newImage("flesh.png")
end

function love.update(dt)
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