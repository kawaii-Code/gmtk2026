local AlarmDisplay = require('libraries.knife.base'):extend()

OFFSETS = {
    ["clock_clock"] = { x = 15, y = 90, frame_count = 60 },
    ["aquarium_clock"] = { x = 71, y = 81, frame_count = 20 },
    ["countdown"] = { x = 46, y = 104, frame_count = 100 },
}

function AlarmDisplay:constructor(animation_name, animation_full_path)
    self.animation = game.animations[animation_name]:clone()
    self.animation_name = animation_name
    self.animation_full_path = animation_full_path
end

function AlarmDisplay:display_time(seconds_left)
    self.animation:gotoFrame(1 + seconds_left)
end

function AlarmDisplay:draw(x, y)
    local ox = x + OFFSETS[self.animation_name].x
    local oy = y + OFFSETS[self.animation_name].y
    self.animation:draw(game.assets.images[self.animation_full_path], ox, oy)
end

return AlarmDisplay
