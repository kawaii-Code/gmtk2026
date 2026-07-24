local ShopButton = require('libraries.knife.base'):extend()

function ShopButton:constructor(alarm_config)
    self.position = { x = 0, y = 0 }
    self.alarm = alarm_config
    self.hitbox = Hitbox(0, 2, 600, 200)

    self.scale = 1
    self.hovered = false
    self.hover_scale_timer = Timer(0.07)
end

function ShopButton:on_buy()
    self.second_mode = true
    self.rpc = Rect(0, 0, 0, 0)
    self.rac = Rect(0, 0, 0, 0)
    self.rlc = Rect(0, 0, 0, 0)
end

function ShopButton:update(dt)
    if self.second_mode then
        return
    end

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

    self.hitbox.offset_x = offset_x

    if self.second_mode then
        return scale, 0
    end

    return self.scale * scale, offset_x
end

function ShopButton:draw(x, y, scale, offset_x)
    if self.second_mode then
        local margin = self.hitbox.width * 0.01
        x = game.shop.rect.x + margin
        self.hitbox.width = game.shop.rect.w - margin

        self.rpc = Rect(
            x,
            y,
            self.hitbox.width * 0.33,
            self.hitbox.height
        )

        self.rac = Rect(
            x + self.hitbox.width * 0.33,
            y,
            self.hitbox.width * 0.33,
            self.hitbox.height
        )

        self.rlc = Rect(
            x + self.hitbox.width * 0.66,
            y,
            self.hitbox.width * 0.33,
            self.hitbox.height
        )

        local avatar_rect = self.rpc:clone()
        local pad = self.rpc.w * 0.1
        avatar_rect.x = avatar_rect.x + pad
        avatar_rect.y = avatar_rect.y + pad
        avatar_rect.w = self.rpc.w * 0.5
        avatar_rect.h = avatar_rect.w

        local x1_text_rect = Rect(
            avatar_rect.x + avatar_rect.w,
            avatar_rect.y + avatar_rect.h * 0.5,
            avatar_rect.w * 0.5,
            avatar_rect.h * 0.5
        )

        local rpc_cost_text = self.rpc:clone()
        rpc_cost_text.h = 0.25 * self.hitbox.height
        rpc_cost_text.y = y + self.hitbox.height - rpc_cost_text.h
        local rac_cost_text = self.rac:clone()
        rac_cost_text.h = 0.25 * self.hitbox.height
        rac_cost_text.y = y + self.hitbox.height - rac_cost_text.h
        local rlc_cost_text = self.rlc:clone()
        rlc_cost_text.h = 0.25 * self.hitbox.height
        rlc_cost_text.y = y + self.hitbox.height - rlc_cost_text.h

        draw_rectangle(self.rpc)
        draw_rectangle(self.rac)
        draw_rectangle(self.rlc)

        draw_rectangle(avatar_rect)

        draw_text_inside_rect(10, rpc_cost_text, 'center')
        draw_text_inside_rect(10, rac_cost_text, 'center')
        draw_text_inside_rect(10, rlc_cost_text, 'center')
        draw_text_inside_rect("x" .. 1, x1_text_rect, 'center')

        return
    end

    local sprite = game.assets.images.button_off
    if game.bank:can_buy(self.alarm) then
        sprite = game.assets.images.button_on
    end
    love.graphics.draw(sprite, x, y, 0, scale)
    love.graphics.draw(game.assets.images.bonus_icons, x, y, 0, scale)
    love.graphics.draw(game.assets.images.icon, x, y, 0, scale)

    local text_1_rect = Rect(
        x + self.hitbox.width * 0.22,
        y + self.hitbox.height * 0.14,
        self.hitbox.width * 0.4,
        self.hitbox.height * 0.28
    )

    local text_2_rect = Rect(
        x + self.hitbox.width * 0.22,
        text_1_rect.y + self.hitbox.height * 0.38,
        self.hitbox.width * 0.4,
        self.hitbox.height * 0.28
    )

    local cost_text_rect = Rect(
        x + self.hitbox.width * 0.58,
        text_1_rect.y + self.hitbox.height * 0.38,
        self.hitbox.width * 0.4,
        self.hitbox.height * 0.28
    )

    local tip_x = x + self.hitbox.width * 0.24
    local y1 = y + self.hitbox.height * 0.17
    local y2 = y1 + self.hitbox.height * 0.39
    draw_text_inside_rect(self.alarm.time, text_1_rect)
    draw_text_inside_rect("+" .. self.alarm.earn, text_2_rect)
    draw_text_inside_rect(self.alarm.cost, cost_text_rect, 'center')
end

return ShopButton
