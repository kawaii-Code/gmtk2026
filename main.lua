lurker = require('libraries.lurker')

function love.load()
    love.graphics.setDefaultFilter("nearest", "nearest")
    game.input.mouse = {
        x = 0,
        y = 0,
        scroll = 0,
    }
    game.load()
    print(config.time_scale)
end

function love.update()
    local deltaTime = love.timer.getDelta()

    game.update(deltaTime)

    for k, _ in pairs(game.input.just_pressed) do
        game.input.just_pressed[k] = false
    end
    game.input.mouse.just_pressed = false
    game.input.mouse.scroll = 0
end

function love.draw()
    game.draw()
end

function love.restart(restartarg)
    config.time_scale = restartarg or 1.1
end

function love.keypressed(key, scancode, isrepeat)
    game.input.keys[key] = true
    game.input.just_pressed[key] = true
end

function love.keyreleased(key, scancode)
    game.input.keys[key] = false
end

function love.wheelmoved(x, y)
    game.input.mouse.scroll = config.mouse_scroll_strength * y
end

function love.mousemoved(x, y, dx, dy, istouch)
    game.input.mouse.x = x
    game.input.mouse.y = y
end

function love.mousepressed(x, y, button, istouch, presses)
    game.input.mouse.x = x
    game.input.mouse.y = y
    game.input.mouse.button = button
    game.input.mouse.pressed = true
    game.input.mouse.just_pressed = true
end

function love.mousereleased(x, y, button, istouch, presses)
    game.input.mouse.pressed = false
end
