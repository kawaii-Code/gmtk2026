local ShopButton = require('libraries.knife.base'):extend()

function ShopButton:constructor(alarm_config)
    self.position = { x = 0, y = 0 }
    self.alarm = alarm_config
    self.hitbox = Hitbox(0, 2, 600, 200)

    self.scale = 1
    self.hovered = false
    self.hovered_last_frame = false
    self.hover_scale_timer = Timer(0.07)
end

function ShopButton:on_buy()
    self.second_mode = true
    self.rpc = Rect(0, 0, 0, 0)
    self.rac = Rect(0, 0, 0, 0)
    self.rlc = Rect(0, 0, 0, 0)
end

function ShopButton:update(dt)
    if self.hovered and not self.hovered_last_frame then
        game.assets.sounds.click:play()
    end
    self.hovered_last_frame = self.hovered
end

function ShopButton:layout(width, mx)
    local scale = ((width - 2 * mx) / game.assets.images.UI_big_available:getWidth())

    self.hitbox.width = scale * game.assets.images.UI_big_available:getWidth()
    self.hitbox.height = scale * game.assets.images.UI_big_available:getHeight()

    local offset_x = -0.5 * (self.scale - 1.0) * self.hitbox.width
    self.hitbox.width = self.hitbox.width * self.scale
    self.hitbox.height = self.hitbox.height * self.scale

    self.hitbox.offset_x = offset_x

    if self.second_mode then
        return scale, 0
    end

    return self.scale * scale, offset_x
end

function ShopButton:draw_block(rect, upgrade, minus, maxed_out)
    local sprite = game.assets.images.UI_block_blocked
    if not maxed_out and game.bank:has(upgrade.cost) then
        sprite = game.assets.images.UI_block_available
        if rect:intersect_point(game.input.mouse.x, game.input.mouse.y) then
            sprite = game.assets.images.UI_block_selected
        end
    end

    draw_sprite_inside_rect(sprite, rect)

    local cost_text = rect:clone()
    cost_text.x = cost_text.x + cost_text.w * 0.1
    cost_text.w = cost_text.w * 0.8
    cost_text.h = 0.25 * self.hitbox.height
    cost_text.y = rect.y + self.hitbox.height - 1.32 * cost_text.h
    local plus = minus and "-" or "+"
    game.bold = true
    if maxed_out then
        draw_text_inside_rect("MAX", cost_text, 'center')
    else
        draw_text_inside_rect(upgrade.cost .. "$ (" .. plus .. upgrade.bonus .. ")", cost_text, 'center')
    end
    game.bold = false
end

function ShopButton:draw(x, y, scale, offset_x)
    if self.second_mode then
        local margin = self.hitbox.width * 0.01
        x = game.shop.rect.x + margin
        self.hitbox.width = game.shop.rect.w - margin

        local total_rect = Rect(
            x, y,
            self.hitbox.width,
            self.hitbox.height
        )

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

        local icon_rect = self.rpc:clone()
        local pad = self.rpc.w * 0.065
        icon_rect.x = icon_rect.x + pad
        icon_rect.y = icon_rect.y + pad
        icon_rect.w = self.rpc.w * 0.5
        icon_rect.h = icon_rect.w

        game.bold = false

        self:draw_block(self.rpc, {cost = count_cost(self.alarm), bonus = 1})
        draw_sprite_inside_rect(game.assets.images.UI_icon, icon_rect)
        local count_rect = icon_rect:clone()
        count_rect.x = count_rect.x + self.rpc.w * 0.53
        count_rect.w = count_rect.w * 0.75
        count_rect.h = count_rect.h * 0.5
        count_rect.y = count_rect.y + self.rpc.h * 0.12
        draw_text_inside_rect("x" .. game.alarm_stats[self.alarm.name].count, count_rect)
        draw_sprite_inside_rect(game.assets.images["icons_" .. self.alarm.sprite_name_mini], icon_rect)

        self:draw_block(self.rac, self.alarm.upgrades["time"][game.alarm_stats[self.alarm.name].time_upgrade_level], true, is_time_maxed_out(self.alarm))
        local time_rect = count_rect:clone()
        time_rect.x = self.rac.x
        time_rect.w = self.rac.w
        time_rect.y = time_rect.y - self.rac.h * 0.18
        if is_time_pre_maxed_out(self.alarm) or is_time_maxed_out(self.alarm) then
            time_rect.x = time_rect.x + self.rac.w * 0.1
            time_rect.w = time_rect.w * 0.8
            draw_text_inside_rect("autoclick", time_rect, 'center')
            time_rect.y = time_rect.y + self.rac.h * 0.3
            draw_text_inside_rect(game.alarm_stats[self.alarm.name].time .. "s", time_rect, 'center')
        else
            draw_text_inside_rect("period", time_rect, 'center')
            time_rect.y = time_rect.y + self.rac.h * 0.3
            draw_text_inside_rect(game.alarm_stats[self.alarm.name].time .. "s", time_rect, 'center')
        end

        self:draw_block(self.rlc, self.alarm.upgrades["earn"][game.alarm_stats[self.alarm.name].earn_upgrade_level], false, is_earn_maxed_out(self.alarm))
        local earn_rect = count_rect:clone()
        earn_rect.x = self.rlc.x
        earn_rect.w = self.rlc.w
        earn_rect.y = earn_rect.y - self.rlc.h * 0.18
        draw_text_inside_rect("income", earn_rect, 'center')
        earn_rect.y = earn_rect.y + self.rlc.h * 0.3
        draw_text_inside_rect(game.alarm_stats[self.alarm.name].earn .. "$", earn_rect, 'center')

        game.bold = false

        return
    end

    local sprite = game.assets.images.UI_big_blocked
    if game.bank:can_buy(self.alarm) then
        sprite = game.assets.images.UI_big_available
        if self.hovered then
            sprite = game.assets.images.UI_big_selected
        end
    end

    love.graphics.draw(sprite, x, y, 0, scale)

    local icon_rect = Rect(
        x + self.hitbox.width * 0.01, y + self.hitbox.height * 0.05,
        self.hitbox.width * 0.3,
        self.hitbox.height * 0.9
    )

    local text_1_rect = Rect(
        x + self.hitbox.width * 0.33,
        y + self.hitbox.height * 0.2,
        self.hitbox.width * 0.36,
        self.hitbox.height * 0.21
    )

    local text_2_rect = Rect(
        x + self.hitbox.width * 0.33,
        text_1_rect.y + self.hitbox.height * 0.3,
        self.hitbox.width * 0.36,
        self.hitbox.height * 0.21
    )

    local cost_text_rect = Rect(
        x + self.hitbox.width * 0.75,
        y + self.hitbox.height * 0.05,
        self.hitbox.width * 0.2,
        self.hitbox.height * 0.9
    )

    draw_sprite_inside_rect_min(game.assets.images["UI_icon"], icon_rect)
    draw_sprite_inside_rect_min(game.assets.images["icons_" .. self.alarm.sprite_name_mini], icon_rect)
    draw_rectangle(icon_rect)

    draw_text_inside_rect("income " .. self.alarm.upgrades["buy"].earn .. "$", text_1_rect)

    draw_text_inside_rect("period " .. self.alarm.upgrades["buy"].earn .. "s", text_2_rect)

    local tip_x = x + self.hitbox.width * 0.24
    local y1 = y + self.hitbox.height * 0.17
    local y2 = y1 + self.hitbox.height * 0.39
    game.bold = true
    draw_text_inside_rect(self.alarm.upgrades["buy"].cost .. "$", cost_text_rect, 'center')
    game.bold = false
end

return ShopButton
