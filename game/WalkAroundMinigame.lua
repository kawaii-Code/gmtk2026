local WalkAroundMinigame = require('libraries.knife.base'):extend()

function WalkAroundMinigame:constructor(alarm)
    self.alarm = alarm
    self.target = math.random(20, 300)
    self.speed = 300
    self.original = alarm.x_offset
    self.timer = Timer(0.25, "start")

    self.catch_me_png = game.assets.images.catch_me

    self.e = false

    game.assets.sounds.crab_small_snap:play()
end

function WalkAroundMinigame:update(dt)
    self.timer:update(dt)
    local alarm_x = self.alarm.x_position + self.alarm.x_offset
    self.alarm.x_offset = self.alarm.x_offset + self.speed * math.sign(self.target - alarm_x) * dt

    if math.abs(self.target - alarm_x) < 5 then
        -- if self.e then
        --     return true
        -- else
        self.target = math.random(20, 300)
        -- end
    end

    if self.e then
        self.alarm.x_offset = self.original
    end
    return self.e
end

function WalkAroundMinigame:draw(screen_height, mouse)
    local x, y = alarm_position(self.alarm)
    local rect = self.alarm.config.hitbox:to_rect(x, y)

    rect.y = rect.y - 40
    game.bold = true
    -- draw_text_inside_rect("CATCH ME!", rect, 'center')

    love.graphics.draw(self.catch_me_png, rect.x, rect.y+12)

    game.bold = false
    rect.y = rect.y + 40

    if rect:intersect_point(mouse.x, mouse.y) then
        if not self.e and self.timer:done() and mouse.just_pressed then
            game.assets.sounds.crab_snap:play()
            self.target = self.original
            self.e = true
            self.speed = 400
        end
    end
end

return WalkAroundMinigame
