local Hitbox = require('libraries.knife.base'):extend()

function Hitbox:constructor(offset_x, offset_y, width, height)
    self.offset_x = offset_x
    self.offset_y = offset_y
    self.width = width
    self.height = height
end

function Hitbox:to_rect(x, y)
    return Rect:new(x + self.offset_x, y + self.offset_y, self.width, self.height)
end

function Hitbox.rect_of(object)
    if (object.x == nil or object.y == nil) then
        error('mistake in hitbox argument: object.x and object.y are missing')
    end
    if (object.hitbox == nil) then
        error('mistake in hitbox argument: object.hitbox is missing')
    end
    if (object.hitbox.to_rect == nil) then
        error('mistake in hitbox argument: object.hitbox is not of class Hitbox')
    end
    return object.hitbox:to_rect(object.x, object.y)
end

return Hitbox
