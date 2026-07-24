local Rect = require('libraries.knife.base'):extend()

function Rect:constructor(x, y, w, h)
    self.x = x
    self.y = y
    self.w = w
    self.h = h
end

function Rect:left()
    return self.x
end

function Rect:right()
    return self.x + self.w
end

function Rect:top()
    return self.y
end

function Rect:bottom()
    return self.y + self.h
end

function Rect:center_x()
    return self.x + self.w / 2
end

function Rect:center_y()
    return self.y + self.h / 2
end

function Rect:intersect_point(px, py)
    return self:left() <= px and px < self:right() and
           self:top()  <= py and py < self:bottom()
end

function Rect:draw(color, mode)
    color = color or {0, 1, 0, 1}
    mode = mode or 'line'
    love.graphics.setColor(color)
    love.graphics.rectangle(mode, self.x, self.y, self.w, self.h)
    love.graphics.setColor({1, 1, 1, 1})
end

return Rect

