local FishingMinigame = require('libraries.knife.base'):extend()

-- Вызывается когда на нас кликают
function FishingMinigame:constructor(alarm)
    self.alarm = alarm
    self.completed = false

    self.window = game.animations["fishing_minigame_window_idle"]
end

function FishingMinigame:on_done()
    self.alarm.timer:reset()
end

function FishingMinigame:update(dt)
    self.window:update(dt)
    return self.completed
end

function FishingMinigame:draw(screen_height, mouse)

    local height = 100
    local rect = Rect(0, 0.5 * (screen_height - height), 200, height)

    if rect:intersect_point(mouse.x, mouse.y) then
        -- love.graphics.setColor({0, 1, 0, 1})
        if mouse.just_pressed then
            self.completed = true
        end
    end

    self.window:draw(game.assets.images.release_box_fishing_minigame,  100, 100)

    -- love.graphics.rectangle('fill', rect.x, rect.y, rect.w, rect.h)
    -- love.graphics.setColor({0.5, 0.5, 0, 1})
end

return FishingMinigame
