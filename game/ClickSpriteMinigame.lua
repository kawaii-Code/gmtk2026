local ClickSpriteMinigame = require('libraries.knife.base'):extend()

function ClickSpriteMinigame:constructor(alarm)
    self.alarm = alarm
    self.x = lume.random(50, 240)
    self.y = lume.random(50, 240)
    self.offset_x = 0
    self.offset_y = 0
    self.sprite = game.assets.images.release_paw
    self.completed = false

    self.time = 0
    self.timer = Timer(0.05, "start")
    self.last_time = 0
end

function ClickSpriteMinigame:update(dt)
    self.timer:update(dt)
    self.time = self.time + dt
    if self.time - self.last_time > 0.03 then
        self.offset_x = lume.random(-3, 3)
        self.offset_y = lume.random(-3, 3)
        self.last_time = self.time
    end
    return self.completed
end

function ClickSpriteMinigame:draw(screen_height, mouse)
    love.graphics.draw(self.sprite, self.x + self.offset_x, self.y  + self.offset_y)
    local rect = Rect(self.x + self.offset_x, self.y + self.offset_y, self.sprite:getWidth(), self.sprite:getHeight())
    if rect:intersect_point(mouse.x, mouse.y) then
        if self.timer:done() and mouse.just_pressed then
            self.completed = true
        end
    end
end

return ClickSpriteMinigame
