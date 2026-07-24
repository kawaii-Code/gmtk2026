local Rect = require('game.Rect')
local SimpleClickMinigame = require('libraries.knife.base'):extend()

-- Вызывается когда на нас кликают
function SimpleClickMinigame:constructor(alarm)
    self.alarm = alarm
    self.completed = false
end

function SimpleClickMinigame:on_done()
    self.alarm.timer:reset()
end

function SimpleClickMinigame:update(dt)
    return self.completed
end

function SimpleClickMinigame:draw(screen_height, mouse)
    local height = 100
    local rect = Rect(0, 0.5 * (screen_height - height), 200, height)
    print(rect.x, rect.y, rect.w, rect.h)

    if rect:intersect_point(mouse.x, mouse.y) then
        love.graphics.setColor({0, 1, 0, 1})
        if mouse.just_pressed then
            self.completed = true
        end
    end
    love.graphics.rectangle('fill', rect.x, rect.y, rect.w, rect.h)
    love.graphics.setColor({1, 1, 1, 1})
end

return SimpleClickMinigame
