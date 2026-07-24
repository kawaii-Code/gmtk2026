local Hitbox = require('game.hitbox')
local Timer = require('game.Timer')

local ShopButton = require('libraries.knife.base'):extend()

BUTTON_SPRITE_OFFSET_X = 0

function ShopButton:constructor(alarm_config)
    self.position = { x = 0, y = 0 }
    self.alarm = alarm_config
    self.hitbox = Hitbox(BUTTON_SPRITE_OFFSET_X, 2, 600, 200)

    self.bought = false

    self.scale = 1
    self.hovered = false
    self.hover_scale_timer = Timer(0.07)
end

function ShopButton:update(dt)
    if self.hovered then
        if self.hover_scale_timer:done() then
            if self.scale < config.shop_button_hover_scale then
                self.hover_scale_timer:reset()
                game.assets.sounds["click"]:play()
            end
        else
            self.hover_scale_timer:update(dt)
            self.scale = square_lerp(1, config.shop_button_hover_scale, self.hover_scale_timer:progress())
            if self.hover_scale_timer:done() then
                self.scale = config.shop_button_hover_scale
            end
        end
    else
        if self.hover_scale_timer:done() then
            if self.scale > 1 then
                self.hover_scale_timer:reset()
            end
        else
            self.hover_scale_timer:update(dt)
            if self.hover_scale_timer:done() then
                self.scale = 1
            end
            self.scale = square_lerp(config.shop_button_hover_scale, 1, self.hover_scale_timer:progress())
        end
    end
end

function ShopButton:layout(width, mx)
    local scale = ((width - 2 * mx) / game.assets.images.button_off:getWidth())

    self.hitbox.width = scale * game.assets.images.button_off:getWidth()
    self.hitbox.height = scale * game.assets.images.button_off:getHeight()

    local offset_x = -0.5 * (self.scale - 1.0) * self.hitbox.width
    self.hitbox.width = self.hitbox.width * self.scale
    self.hitbox.height = self.hitbox.height * self.scale

    self.hitbox.offset_x = BUTTON_SPRITE_OFFSET_X + offset_x

    return self.scale * scale, offset_x
end

return ShopButton
