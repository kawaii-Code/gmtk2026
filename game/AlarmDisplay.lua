local AlarmDisplay = require('libraries.knife.base'):extend()

OFFSETS = {
    ["release_clock_clock"] = { x = 15, y = 90, frame_count = 60 },
    ["release_aquarium-clock"] = { x = 71, y = 81, frame_count = 20 },
    ["release_countdown"] = { x = 46, y = 104, frame_count = 100 },
    ["release_countdown_crab"] = { x = 26, y = 106, frame_count = 100 },
    ["release_old_fashion_clock"] = { x = 38, y = 90, frame_count = 60 },
    ["release_crocodile_clock"] = { x = 8, y = 100, frame_count = 100 },
    ["release_shooting_range_clock"] = { x = 50, y = 106, frame_count = 100 },
    ["release_bear_clock"] = { x = 23, y = 84, frame_count = 60 },
    ["release_bomb"] = { x = 45, y = 106, frame_count = 100 },
}

function AlarmDisplay:constructor(animation_full_path)
    self.animation = game.animations[animation_full_path]:clone()
    self.animation_full_path = animation_full_path

    self.time = 0.0
    self.last_time = 0.0
    self.offset_y = 0.0
end

function AlarmDisplay:display_time(seconds_left)
    local frame = 1 + (seconds_left % OFFSETS[self.animation_full_path].frame_count)
    self.animation:gotoFrame(frame)
end

function AlarmDisplay:reset_animation()
    self.time = 0.1
    self.last_time = -1
end

function AlarmDisplay:update(dt)
    if self.press_in_animation then
        self.time = self.time + dt
        if self.time - self.last_time >= 0.1 then
            self.offset_y = self.offset_y + 1
            self.last_time = self.time
        end

        if self.time >= 0.3 then
            self:reset_animation()
            self.offset_y = 3
            self.press_in_animation = false
        end
    end

    if self.press_out_animation then
        self.time = self.time + dt
        if self.time - self.last_time >= 0.1 then
            self.offset_y = self.offset_y - 1
            self.last_time = self.time
        end

        if self.time >= 0.3 then
            self:reset_animation()
            self.offset_y = 0
            self.press_out_animation = false
        end
    end
end

function AlarmDisplay:draw(x, y)
    local ox = x + OFFSETS[self.animation_full_path].x
    local oy = self.offset_y + y + OFFSETS[self.animation_full_path].y
    self.animation:draw(game.assets.images[self.animation_full_path], ox, oy)
end

return AlarmDisplay
