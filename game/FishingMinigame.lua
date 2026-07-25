local FishingMinigame = require('libraries.knife.base'):extend()

-- Вызывается когда на нас кликают
function FishingMinigame:constructor(alarm)
    self.alarm = alarm
    self.completed = false

    self.window = game.animations["fishing_minigame_window_idle"]

    self.float = {
        x = 30, min_x = 13, max_x = 374-(21-10),
        y = 40, min_y = 30, max_y = 100,
        is_go_left = false, -- для движения
        speed_x = 345,
        status = 'wait',
            -- wait — двигается влево-вправо в ожидании клика
            -- attack — опускается вниз пока не достигнет дна или не коснется рыбы
            -- release — поднимается вверх после неудачной "атаки"
            -- win — застывает в победном положении
        sprite = game.animations["float_wait"],
        sprite_x = -10,
        sprite_y = -24,
    }
end

function FishingMinigame:on_done()
    self.alarm.timer:reset()
end

function FishingMinigame:float_update(dt)
    if self.float.status == 'wait' then

        if self.float.x >= self.float.max_x then
            self.float.is_go_left = true
        elseif self.float.x <= self.float.min_x then
            self.float.is_go_left = false
        end

        if self.float.is_go_left then
            self.float.x = self.float.x - self.float.speed_x * dt
        else
            self.float.x = self.float.x + self.float.speed_x * dt
        end
    end
end

function FishingMinigame:update(dt)
    self.window:update(dt)

    self:float_update(dt)

    return self.completed
end

function FishingMinigame:draw(screen_height, mouse)
    local X = 10
    local Y = 50

    local height = 100
    local rect = Rect(0, 0.5 * (screen_height - height), 200, height)

    if rect:intersect_point(mouse.x, mouse.y) then
        -- love.graphics.setColor({0, 1, 0, 1})
        if mouse.just_pressed then
            self.completed = true
        end
    end

    self.window:draw(game.assets.images.release_box_fishing_minigame,  X, Y)
    local float_x = self.float.x + self.float.sprite_x + X
    local float_y = self.float.y + self.float.sprite_y + Y
    self.float.sprite:draw(game.assets.images.release_float, float_x, float_y)

    -- love.graphics.rectangle('fill', rect.x, rect.y, rect.w, rect.h)
    -- love.graphics.setColor({0.5, 0.5, 0, 1})
end

return FishingMinigame
