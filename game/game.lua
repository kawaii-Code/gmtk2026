-- Независимость! 🗽

--
-- Все что не получится найти здесь, ищи в game_helpers.lua
--
game = {
    -- Все что является файлов в `assets/`
    -- попадает сюда по такому же пути.
    assets = {
        images = {},
        fonts = {},
        sounds = {},
    },

    animations = {},

    input = {
        keys = {},
        just_pressed = {},
        mouse = {},
    },

    alarm = {},
    shop = {},
}


function game.load()
    local function createGrid(frame_width, frame_height, spritesheet)
        return anim8.newGrid(frame_width, frame_height, spritesheet:getPixelWidth(), spritesheet:getPixelHeight())
    end

    game.assets.fonts.shop = load_font_with_different_sizes("assets/fonts/shop.otf")
    game.assets.sounds = load_sounds_from_directory("assets/sounds")
    game.assets.images = load_images_from_directory("assets/sprites")
    game.assets.images.grids = {
        basic_clock = createGrid(150, 150, game.assets.images.release_clock),
        digital_clock = createGrid(150, 150, game.assets.images.release_normis),
        aquarium = createGrid(150, 150, game.assets.images.release_aquarium),
        countdown = createGrid(33, 27, game.assets.images.release_countdown),
        aquarium_clock = createGrid(13, 13, game.assets.images["release_aquarium-clock"]),
        clock_clock = createGrid(43, 32, game.assets.images.release_clock_clock),
    }

    local grids = game.assets.images.grids
    game.animations["digital_press_in"] = anim8.newAnimation(grids.digital_clock('2-5', 1), 0.1)
    game.animations["digital_press_out"] = anim8.newAnimation(grids.digital_clock('6-8', 1), 0.1)
    game.animations["digital_idle"] = anim8.newAnimation(grids.digital_clock(1, 1), 1)

    game.animations["basic_clock_press_in"] = anim8.newAnimation(grids.basic_clock('2-5', 1), 0.1)
    game.animations["basic_clock_press_out"] = anim8.newAnimation(grids.basic_clock('6-8', 1), 0.1)
    game.animations["basic_clock_idle"] = anim8.newAnimation(grids.basic_clock(1, 1), 1)

    game.animations["aquarium_press_in"] = anim8.newAnimation(grids.aquarium('2-5', 1), 0.05)
    game.animations["aquarium_press_out"] = anim8.newAnimation(grids.aquarium('6-8', 1), 0.05)
    game.animations["aquarium_idle"] = anim8.newAnimation(grids.aquarium(1, 1), 1)

    game.animations["countdown"] = anim8.newAnimation(grids.countdown('1-100', 1), 1)
    game.animations["aquarium_clock"] = anim8.newAnimation(grids.aquarium_clock('1-20', 1), 1)
    game.animations["clock_clock"] = anim8.newAnimation(grids.clock_clock('1-60', 1), 1)

    -- Игровые объекты
    game.bank = Bank(config.starting_money)
    game.playtime = Stopwatch()

    love.mouse.setVisible(false)

    local first = true

    local desktop_width, desktop_height = love.window.getDesktopDimensions()
    -- Игровая зона
    game.alarm = {
        scrollbar = Scrollbar(),
        shelf_count = 20,
        content_height = 0,
        canvas = love.graphics.newCanvas(config.alarm.width, desktop_height),
    }

    game.shop = {
        buttons = {},
        scrollbar = Scrollbar(),
        content_height = 0,
    }
    for _, config in ipairs(config.alarms) do
        for i = 1, 3 do
            table.insert(game.shop.buttons, ShopButton(config))
        end
    end

    -- Будильники
    game.alarms = {}

    game.minigame = nil

    game.player = {
        mouse_just_pressed = false,
        can_click = false,
    }
end

function game.update(dt)
    lurker.update()
    if game.input.just_pressed["f11"] then
        local fullscreen = love.window.getFullscreen()
        love.window.setFullscreen(not fullscreen, "desktop")
    end

    game.player.mouse_just_pressed = game.input.mouse.just_pressed
    game.player.can_click = false

    layout_shop_screen()
    layout_alarm_screen()

    for _, alarm in ipairs(game.alarms) do
        alarm:update(dt)

        local mouse_x, mouse_y = translate_mouse_to_alarm_screen()
        local x, y = alarm_position(alarm)

        local alarm_rect = alarm.config.hitbox:to_rect(x, y)
        if alarm_rect:intersect_point(mouse_x, mouse_y) then
            game.player.can_click = true
            if alarm.timer:done() and game.input.mouse.just_pressed then
                game.minigame = alarm.config.Minigame(alarm)
                alarm:on_press()
            end
        end
    end

    --
    -- UI
    --
    local screen_width, screen_height = love.graphics.getDimensions()
    local mouse_x, mouse_y = game.input.mouse.x, game.input.mouse.y

    local cursor_in_shop = false
    if mouse_x >= game.shop.rect.x then
        cursor_in_shop = true
    end

    if cursor_in_shop then
        game.shop.scrollbar.scroll = game.shop.scrollbar.scroll - config.scroll_strength * game.input.mouse.scroll
        game.shop.scrollbar.scroll = math.clamp(game.shop.scrollbar.scroll, 0, 1)
    else
        game.alarm.scrollbar.scroll = game.alarm.scrollbar.scroll - config.scroll_strength * game.input.mouse.scroll
        game.alarm.scrollbar.scroll = math.clamp(game.alarm.scrollbar.scroll, 0, 1)
    end

    local shop_scrollbar_area = Rect(game.shop.rect.x + game.shop.rect.w, 0, config.scrollbar_width, screen_height)
    local alarm_area_scrollbar_area = Rect(game.alarm.full_rect.w - config.scrollbar_width, 0, config.scrollbar_width, screen_height)
    game.shop.scrollbar:update(shop_scrollbar_area, screen_height, game.shop.content_height)
    game.alarm.scrollbar:update(alarm_area_scrollbar_area, screen_height / game.alarm.scale, game.alarm.content_height)

    for _, button in ipairs(game.shop.buttons) do
        button:update(dt)

        local button_rect = button.hitbox:to_rect(button.position.x, button.position.y)
        if button_rect:intersect_point(mouse_x, mouse_y) then
            game.player.can_click = true
            button.hovered = true
            if game.input.mouse.just_pressed then
                if game.bank:can_buy(button.alarm) then
                    game.bank:buy(button.alarm)
                    button.bought = true
                    local alarm = Alarm(button.alarm)
                    table.insert(game.alarms, alarm)
                end
            end
        else
            button.hovered = false
        end
    end

    if game.minigame then
        if game.minigame:update(dt) then
            game.bank:earn(game.minigame.alarm.config.earn)
            game.minigame:on_done()
            game.minigame.alarm:on_minigame_done()
            game.minigame = nil
        end
    end
end

function game.draw()
    local screen_width, screen_height = love.graphics.getDimensions()

    local alarm_area_canvas = game.alarm.canvas

    love.graphics.clear({0.2, 0.2, 0.2, 1})
    love.graphics.setColor({0.3, 0.3, 0.3, 1})
    love.graphics.rectangle('fill', game.alarm.full_rect.x, game.alarm.full_rect.y, game.alarm.full_rect.w, game.alarm.full_rect.h)
    love.graphics.setColor({1, 1, 1, 1})

    love.graphics.setCanvas(alarm_area_canvas)
    game.draw_alarm_area()
    if game.minigame then
        local mouse_x, mouse_y = translate_mouse_to_alarm_screen()
        local mouse = {
            x = mouse_x,
            y = mouse_y,
            just_pressed = game.player.mouse_just_pressed,
            pressed = game.input.mouse.pressed,
        }
        print(game.alarm.rect.h)
        game.minigame:draw(game.alarm.rect.h, mouse)
    end
    love.graphics.setCanvas()

    local screen_width, screen_height = love.graphics.getDimensions()
    local alarm_area_scrollbar_area = Rect(game.alarm.full_rect.w - config.scrollbar_width, 0, config.scrollbar_width, screen_height)
    game.alarm.scrollbar:draw(alarm_area_scrollbar_area)

    love.graphics.draw(alarm_area_canvas, game.alarm.rect.x, game.alarm.rect.y, 0.0, game.alarm.scale)

    game.draw_shop_area()

    local cursor_sprite = game.assets.images["release_cursor-vector"]
    local cursor_offset = -6
    if game.player.can_click then
        cursor_offset = -20
        cursor_sprite = game.assets.images["release_finger-vector"]
    end
    local cursor_scale = config.cursor_size / cursor_sprite:getWidth()
    love.graphics.draw(cursor_sprite, game.input.mouse.x + cursor_offset, game.input.mouse.y, 0, cursor_scale)

    love.graphics.print(game.bank.money .. "$", game.assets.fonts.shop[18], 0, 0)
end

function game.draw_alarm_area()
    love.graphics.clear({0.3, 0.3, 0.3, 1})

    -- В прямоугольнике X это где нужно нарисовать канвас по x
    -- w и h это в 400x600+-(по высоте окна) координатах
    local rect = game.alarm.rect

    local mouse_x, mouse_y = translate_mouse_to_alarm_screen()

    local x = 0
    local y = config.alarm.margin_top + game.alarm.scrollbar:pixel_scroll()
    for _ = 1, game.alarm.shelf_count do
        love.graphics.setColor({0.8, 0.7, 0.7, 1})
        love.graphics.rectangle('fill', config.alarm.shelf.margin_horizontal, y, rect.w - 2 * config.alarm.shelf.margin_horizontal, config.alarm.shelf.height)
        love.graphics.setColor({1, 1, 1, 1})
        y = y + config.alarm.shelf.height + config.alarm.shelf.spacing
    end

    local over = false
    for _, alarm in ipairs(game.alarms) do
        local x, y = alarm_position(alarm)
        alarm.sprite:draw(alarm.spritesheet, x, y)
        alarm.display:draw(x, y)
        local rect = alarm.config.hitbox:to_rect(x, y)
        love.graphics.rectangle('line', rect.x, rect.y, rect.w, rect.h)
        if rect:intersect_point(mouse_x, mouse_y) then
            over = true
        end
    end

    if over then
        love.graphics.setColor({0, 1, 0, 1})
    else
        love.graphics.setColor({1, 0, 0, 1})
    end
    love.graphics.rectangle('fill', mouse_x, mouse_y, 10, 10)
    love.graphics.setColor({1, 1, 1, 1})
end

function game.draw_shop_area()
    local rect = game.shop.rect
    love.graphics.setColor({1.0, 0.0, 0.32, 1})
    love.graphics.rectangle('fill', rect.x, rect.y, rect.w, rect.h)
    love.graphics.setColor({1, 1, 1, 1})

    draw_text_centered("SHOP", rect.x + rect.w / 2, 0)

    for _, button in ipairs(game.shop.buttons) do
        local scale, offset_x = button:layout(rect.w, config.shop.margin_left)
        local x = button.position.x + offset_x
        local y = button.position.y

        local button_sprite = game.assets.images.button_off
        if game.bank:can_buy(button.alarm) then
            button_sprite = game.assets.images.button_on
        end
        love.graphics.draw(button_sprite, x, y, 0, scale)
        love.graphics.draw(game.assets.images.bonus_icons, x, y, 0, scale)
        love.graphics.draw(game.assets.images.icon, x, y, 0, scale)

        local text_1_rect = Rect(
            x + button.hitbox.width * 0.22,
            y + button.hitbox.height * 0.14,
            button.hitbox.width * 0.4,
            button.hitbox.height * 0.28
        )

        local text_2_rect = Rect(
            x + button.hitbox.width * 0.22,
            text_1_rect.y + button.hitbox.height * 0.38,
            button.hitbox.width * 0.4,
            button.hitbox.height * 0.28
        )

        local cost_text_rect = Rect(
            x + button.hitbox.width * 0.58,
            text_1_rect.y + button.hitbox.height * 0.38,
            button.hitbox.width * 0.4,
            button.hitbox.height * 0.28
        )

        local tip_x = x + button.hitbox.width * 0.24
        local y1 = y + button.hitbox.height * 0.17
        local y2 = y1 + button.hitbox.height * 0.39
        draw_text_inside_rect(button.alarm.time, text_1_rect)
        draw_text_inside_rect("+" .. button.alarm.earn, text_2_rect)
        draw_text_inside_rect(button.alarm.cost, cost_text_rect, 'center')
    end

    local screen_width, screen_height = love.graphics.getDimensions()
    local shop_scrollbar_area = Rect(screen_width - config.scrollbar_width, 0, config.scrollbar_width, screen_height)
    game.shop.scrollbar:draw(shop_scrollbar_area)
end

return game
