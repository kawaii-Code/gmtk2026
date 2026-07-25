local FishingMinigame = require('libraries.knife.base'):extend()

-- Вызывается когда на нас кликают
function FishingMinigame:constructor(alarm)
    self.alarm = alarm
    self.completed = false

    self.window = game.animations["fishing_minigame_window_idle"]

    self.float = {
        x = 30, min_x = 13+2, max_x = 374-(21-10)-4,
        y = 40, min_y = 40, max_y = 149,
        is_go_left = false, -- для движения
        speed_x = 200,
        speed_y = 200,
        status = 'preview',
            -- wait — двигается влево-вправо в ожидании клика
            -- attack — опускается вниз пока не достигнет дна или не коснется рыбы
            -- release — поднимается вверх после неудачной "атаки"
            -- win — застывает в победном положении
            -- preview — вступительная анимация
        sprite = game.animations["float"],
        sprite_x = -10,
        sprite_y = -24,
    }

    self.fishing_line = {
        -- просто картинка размером 4x1 пикселей, из которой состоит вертикальная линия
        sprite = game.animations["fishing_line"],
    }

    self.fish = {
        sprite = game.animations["fish_right"],
        width = 40,
        height = 20,
        x = 40, min_x = 20, max_x = 310,
        is_go_left = false,
        y = 120,
        speed = 200,
        status = 'swim',
            -- swim — двигается влево-вправо
            -- win — застывает в победном положении
    }

    self.X = 10
    self.Y = 50

    self.status = 'game'
        -- 'win'
end

function FishingMinigame:draw_fishing_line(x, y1, y2)
    for y = y1, y2 - 1 do
        self.fishing_line.sprite:draw(game.assets.images.release_fishing_line, x, y)
    end
end

function FishingMinigame:float_update(dt)
    local mouse = game.input.mouse
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

        if mouse.just_pressed then
            self.float.status = 'attack'
        end

    elseif self.float.status == 'attack' then

        self.float.y = self.float.y + self.float.speed_y * dt
        if self.float.y >= self.float.max_y then
            self.float.status = 'release'
        end

    elseif self.float.status == 'release' then

        self.float.y = self.float.y - self.float.speed_y * dt
        if self.float.y <= self.float.min_y then
            self.float.status = 'wait'
        end

    elseif self.float.status == 'preview' then
        self.float.status = 'wait'
    end
end

function FishingMinigame:fish_update(dt)
    if self.fish.status == 'swim' then
        if self.fish.x >= self.fish.max_x then
            self.fish.is_go_left = true
            self.fish.sprite = game.animations["fish_left"]
        elseif self.fish.x <= self.fish.min_x then
            self.fish.is_go_left = false
            self.fish.sprite = game.animations["fish_right"]
        end

        if self.fish.is_go_left then
            self.fish.x = self.fish.x - self.fish.speed * dt
        else
            self.fish.x = self.fish.x + self.fish.speed * dt
        end
    end
end

function FishingMinigame:set_win_status()
    self.status = 'win'
    self.float.status = 'win'
    self.float.sprite = game.animations["float_win"]
    self.fish.status = 'win'
    self.fish.sprite = game.animations["fish_win"]

    local mid = (self.float.max_y + self.float.min_y) * 2/3
    self.float.y = mid

    self.fish.x = self.float.x - 14
    self.fish.y = mid - 1
end

function FishingMinigame:update(dt)
    self.window:update(dt)

    self:float_update(dt)
    self:fish_update(dt)

    local fish = self.fish
    local X = self.X
    local Y = self.Y
    local rect = Rect(fish.x+1, fish.y+4, fish.width, fish.height)

    if rect:intersect_point(self.float.x, self.float.y) then
        self:set_win_status()
    end

    if self.status == 'win' and game.input.mouse.just_pressed then
        return true
    end

    return self.completed
end

function FishingMinigame:draw(screen_height, mouse)
    local X = self.X
    local Y = self.Y

    -- local height = 100
    -- local rect = Rect(0, 0.5 * (screen_height - height), 200, height)

    -- if rect:intersect_point(mouse.x, mouse.y) then
    --     -- love.graphics.setColor({0, 1, 0, 1})
    --     if mouse.just_pressed then
    --         self.completed = true
    --     end
    -- end

    self.window:draw(game.assets.images.release_box_fishing_minigame,  X, Y)

    local float_x = self.float.x + self.float.sprite_x + X
    local float_y = self.float.y + self.float.sprite_y + Y

    self:draw_fishing_line(float_x+7, Y+3, float_y+3)

    self.fish.sprite:draw(game.assets.images.release_fish, self.fish.x+X, self.fish.y+Y)
    self.float.sprite:draw(game.assets.images.release_float, float_x, float_y)

    -- local fish = self.fish
    -- local rect = Rect(fish.x+X+1, fish.y+Y+4, fish.width, fish.height)

    -- love.graphics.rectangle('fill', rect.x, rect.y, rect.w, rect.h)
    -- love.graphics.setColor({0.5, 0.5, 0, 1})
end

return FishingMinigame
