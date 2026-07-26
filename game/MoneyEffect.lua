local MoneyEffect = require('libraries.knife.base'):extend()

function MoneyEffect:constructor(x, y, amount)
    self.x = x
    self.y = y
    self.amount = amount
    self.timer = Timer(2.0, "start")
    self.rotation = lume.random(-3.14/6, 3.14/6)
end

SPEED = 10
function MoneyEffect:update(dt)
    self.timer:update(dt)
    if self.timer:done() then
        table.remove(game.money_effects, 1)
    end

    self.y = self.y - SPEED * dt - SPEED * self.timer:progress()
end

function MoneyEffect:draw()
    local w = game.shop.rect.w * 0.16
    local h = w
    local rect = Rect(self.x - 0.5 * w, self.y - 0.5 * h, w, h)
    draw_text_inside_rect("+" .. self.amount .. "$", rect, 'center', config.money_effect_color, self.rotation)
end

return MoneyEffect
