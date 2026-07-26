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

    game.assets.fonts.shop = load_font_with_different_sizes("assets/fonts/shop.ttf")
    game.assets.fonts.shop_bold = load_font_with_different_sizes("assets/fonts/shop_bold.ttf")
    game.assets.music = love.audio.newSource("assets/music/music.mp3", 'static')
    game.assets.music_loop = love.audio.newSource("assets/music/loop.mp3", 'static')
    game.assets.sounds = load_sounds_from_directory("assets/sounds")
    game.assets.images = load_images_from_directory("assets/sprites")
    game.assets.images.grids = {
        countdown = createGrid(33, 27, game.assets.images.release_countdown),
        aquarium_clock = createGrid(13, 13, game.assets.images["release_aquarium-clock"]),
        fishing_minigame_window = createGrid(374, 185, game.assets.images.release_box_fishing_minigame),
        float = createGrid(19, 25, game.assets.images.release_float),
        fishing_line = createGrid(4, 1, game.assets.images.release_fishing_line),
        fish = createGrid(43, 43, game.assets.images.release_fish),
        clock_clock = createGrid(43, 43, game.assets.images.release_clock_clock),
    }

    local grids = game.assets.images.grids
    for _, config in ipairs(config.alarms) do
        local name = config.sprite_name_mini
        grids[name] = createGrid(150, 150, game.assets.images["alarm_" .. name .. "_0"])
    end

    game.assets.sounds["crocodile_alarm"] = game.assets.sounds["aquarium_alarm"]:clone()
    game.assets.sounds["old_fashion_alarm"] = game.assets.sounds["aquarium_alarm"]:clone()
    game.assets.sounds["bear_alarm"] = game.assets.sounds["aquarium_alarm"]:clone()
    game.assets.sounds["shooting_range_alarm"] = game.assets.sounds["aquarium_alarm"]:clone()

    -- на подумать: ускорить секунды
    game.animations["release_countdown"] = anim8.newAnimation(grids.countdown('1-100', 1), 1)
    game.animations["release_aquarium-clock"] = anim8.newAnimation(grids.aquarium_clock('1-20', 1), 1)
    game.animations["release_clock_clock"] = anim8.newAnimation(grids.clock_clock('1-60', 1), 1)
    game.animations["release_countdown_crab"] = anim8.newAnimation(grids.countdown('1-100', 1), 1)
    game.animations["release_old_fashion_clock"] = game.animations["release_clock_clock"]:clone()
    game.animations["release_bear_clock"] = game.animations["release_clock_clock"]:clone()
    game.animations["release_crocodile_clock"] = game.animations["release_countdown"]:clone()
    game.animations["release_shooting_range_clock"] = game.animations["release_countdown"]:clone()

    game.skins = {}
    for _, config in ipairs(config.alarms) do
        local name = config.sprite_name_mini
        grids[name] = createGrid(150, 150, game.assets.images["alarm_" .. name .. "_0"])
        for skin = 0, config.skin_count - 1 do
            game.animations[name .. "_" .. skin .. "_press_in"] = anim8.newAnimation(grids[name]('2-5', 1), 0.1)
            game.animations[name .. "_" .. skin .. "_press_out"] = anim8.newAnimation(grids[name]('6-8', 1), 0.1)
            game.animations[name .. "_" .. skin .. "_idle"] = anim8.newAnimation(grids[name](1, 1), 1)
        end
        game.skins[config.name] = 0
    end

    -- волны в аквариуме 🫠
    game.animations["fishing_minigame_window_idle"] = anim8.newAnimation(grids.fishing_minigame_window('1-2', 1), 0.8)
    game.animations["float"] = anim8.newAnimation(grids.float(1, 1), 1)
    game.animations["float_win"] = anim8.newAnimation(grids.float(2, 1), 1)
    game.animations["fish_right"] = anim8.newAnimation(grids.fish(1, 1), 1)
    game.animations["fish_left"] = anim8.newAnimation(grids.fish(2, 1), 1)
    game.animations["fish_win"] = anim8.newAnimation(grids.fish(3, 1), 1)
    game.animations["fishing_line"] = anim8.newAnimation(grids.fishing_line(1, 1), 1)

    -- Игровые объекты
    game.bank = Bank(config.starting_money)
    game.playtime = Stopwatch()

    love.mouse.setVisible(false)

    local first = true

    local desktop_width, desktop_height = love.window.getDesktopDimensions()
    -- Игровая зона
    game.alarm = {
        scrollbar = Scrollbar(),
        shelf_count = 1,
        spot = 0,
        content_height = 0,
        canvas = love.graphics.newCanvas(config.alarm.width, desktop_height),
    }

    game.shop = {
        buttons = {},
        scrollbar = Scrollbar(),
        content_height = 0,
    }
    for _, config in ipairs(config.alarms) do
        table.insert(game.shop.buttons, ShopButton(config))
    end

    -- Будильники
    game.alarms = {}
    game.alarm_stats = {}

    game.minigame = nil

    game.money_effects = {}

    game.player = {
        mouse_just_pressed = false,
        can_click = false,
    }

    love.audio.setVolume(0.1)
    game.assets.music:play()
    game.assets.music_loop:setLooping(true)
end

function game.update(dt)
    lurker.update()

    if not game.assets.music:isPlaying() and not game.assets.music_loop:isPlaying() then
        game.assets.music_loop:play()
    end

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
        if not game.minigame and alarm_rect:intersect_point(mouse_x, mouse_y) then
            game.player.can_click = true
            if is_time_maxed_out(alarm.config) then
                game.player.can_click = false
            end
            if game.input.mouse.just_pressed then
                if not is_time_maxed_out(alarm.config) then
                    if alarm.timer:done() then
                        game.minigame = alarm.config.Minigame(alarm)
                        alarm:on_press()
                    else
                        game.assets.sounds.error:play()
                        game.player.can_click = false
                    end
                else
                    game.assets.sounds.error:play()
                end
            end
        end
    end

    for _, m in ipairs(game.money_effects) do
        m:update(dt)
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

        if button.second_mode then
            if button.rpc:intersect_point(mouse_x, mouse_y) then
                game.player.can_click = true
                if game.input.mouse.just_pressed then
                    local upgrade_cost = count_cost(button.alarm)
                    if game.bank:has(upgrade_cost) then
                        game.bank:spend(upgrade_cost)
                        game.add_alarm(button.alarm)
                        game.alarm_stats.next_count_upgrade_cost = 2 * upgrade_cost
                    end
                end
            elseif button.rac:intersect_point(mouse_x, mouse_y) then
                game.player.can_click = true
                if game.input.mouse.just_pressed and not is_time_maxed_out(button.alarm) then
                    local upgrade = button.alarm.upgrades["time"][game.alarm_stats[button.alarm.name].time_upgrade_level]
                    local upgrade_cost = upgrade.cost
                    if game.bank:has(upgrade_cost) then
                        game.bank:spend(upgrade_cost)
                        game.alarm_stats[button.alarm.name].time = game.alarm_stats[button.alarm.name].time - upgrade.bonus
                        game.alarm_stats[button.alarm.name].time_upgrade_level = game.alarm_stats[button.alarm.name].time_upgrade_level + 1
                    end
                end
            elseif button.rlc:intersect_point(mouse_x, mouse_y) then
                game.player.can_click = true
                if game.input.mouse.just_pressed and not is_earn_maxed_out(button.alarm) then
                    local upgrade = button.alarm.upgrades["earn"][game.alarm_stats[button.alarm.name].earn_upgrade_level]
                    local upgrade_cost = upgrade.cost
                    if game.bank:has(upgrade_cost) then
                        game.bank:spend(upgrade_cost)
                        game.alarm_stats[button.alarm.name].earn = game.alarm_stats[button.alarm.name].earn + upgrade.bonus
                        game.alarm_stats[button.alarm.name].earn_upgrade_level = game.alarm_stats[button.alarm.name].earn_upgrade_level + 1
                    end
                end
            end
        else
            local button_rect = button.hitbox:to_rect(button.position.x, button.position.y)
            if button_rect:intersect_point(mouse_x, mouse_y) then
                game.player.can_click = true
                button.hovered = true
                if game.input.mouse.just_pressed then
                    if not button.second_mode and game.bank:can_buy(button.alarm) then
                        game.bank:buy(button.alarm)
                        button:on_buy()
                        button.bought = true

                        game.alarm_stats[button.alarm.name] = {
                            time = button.alarm.upgrades["buy"].time,
                            earn = button.alarm.upgrades["buy"].earn,
                            count = 0,
                            time_upgrade_level = 1,
                            earn_upgrade_level = 1,
                            next_count_upgrade_cost = 20,
                        }

                        game.add_alarm(button.alarm)
                    else
                        game.assets.sounds.error:play()
                    end
                end
            else
                button.hovered = false
            end
        end
    end

    if game.input.mouse.just_pressed then
        game.assets.sounds.click:play()
    end

    if game.minigame then
        if game.minigame:update(dt) then
            local earn = game.alarm_stats[game.minigame.alarm.config.name].earn
            game.bank:earn(earn)
            local money_effect = MoneyEffect(game.input.mouse.x, game.input.mouse.y, earn)
            table.insert(game.money_effects, money_effect)
            game.minigame.alarm.timer:reset_with_new_duration(game.alarm_stats[game.minigame.alarm.config.name].time)
            game.minigame.alarm:on_minigame_done()
            game.minigame = nil
        end
    end
end

function game.draw()
    local screen_width, screen_height = love.graphics.getDimensions()

    local alarm_area_canvas = game.alarm.canvas

    love.graphics.clear(config.bg_color)

    love.graphics.setCanvas(alarm_area_canvas)
    love.graphics.clear(config.bg_color)
    game.draw_alarm_area()
    if game.minigame then
        local mouse_x, mouse_y = translate_mouse_to_alarm_screen()
        local mouse = {
            x = mouse_x,
            y = mouse_y,
            just_pressed = game.player.mouse_just_pressed,
            pressed = game.input.mouse.pressed,
        }
        game.minigame:draw(game.alarm.rect.h, mouse)
    end
    love.graphics.setCanvas()

    local screen_width, screen_height = love.graphics.getDimensions()
    local alarm_area_scrollbar_area = Rect(game.alarm.full_rect.w - config.scrollbar_width, 0, config.scrollbar_width, screen_height)
    game.alarm.scrollbar:draw(alarm_area_scrollbar_area)

    love.graphics.draw(alarm_area_canvas, game.alarm.rect.x, game.alarm.rect.y, 0.0, game.alarm.scale)

    game.draw_shop_area()

    local money_area_width = game.shop.rect.w * 0.25
    local money_area_rect = Rect(0, 0, money_area_width, money_area_width)
    draw_sprite_inside_rect(game.assets.images.UI_icon, money_area_rect)
    local tr = money_area_rect:clone()
    tr.x = tr.x + tr.w * 0.07
    tr.w = tr.w * 0.86
    draw_text_inside_rect(game.bank.money .. "$", tr, 'center')

    for _, m in ipairs(game.money_effects) do
        m:draw()
    end

    local cursor_sprite = game.assets.images["release_cursor-vector"]
    local cursor_offset = -6
    if game.player.can_click then
        cursor_offset = -20
        cursor_sprite = game.assets.images["release_finger-vector"]
    end
    local cursor_scale = (game.shop.rect.w * config.cursor_size) / cursor_sprite:getWidth()
    love.graphics.draw(cursor_sprite, game.input.mouse.x + cursor_offset, game.input.mouse.y, 0, cursor_scale)
end

function game.draw_alarm_area()
    love.graphics.draw(game.assets.images.release_wallpaper, 0, 0)
    -- В прямоугольнике X это где нужно нарисовать канвас по x
    -- w и h это в 400x600+-(по высоте окна) координатах
    local rect = game.alarm.rect

    local mouse_x, mouse_y = translate_mouse_to_alarm_screen()

    local x = config.alarm.shelf.margin_horizontal
    local y = config.alarm.margin_top + game.alarm.scrollbar:pixel_scroll()
    for _ = 1, game.alarm.shelf_count do
        love.graphics.draw(game.assets.images.release_shelf, x, y)
        y = y + config.alarm.shelf.height + config.alarm.shelf.spacing
    end

    for _, alarm in ipairs(game.alarms) do
        local x, y = alarm_position(alarm)
        alarm.sprite:draw(alarm.spritesheet, x, y)
        alarm.display:draw(x, y)
        local rect = alarm.config.hitbox:to_rect(x, y)
        if is_time_maxed_out(alarm.config) then
            local sprite = game.assets.images.autoclick_idle
            if alarm.pressed and alarm.pressed_stopwatch.time < 0.5 then
                sprite = game.assets.images.autoclick_press
            end
            love.graphics.draw(sprite, rect.x + 0.5 * (rect.w - sprite:getWidth()), rect.y + 0.5 * (rect.h - sprite:getHeight()))
        end
        -- love.graphics.rectangle('line', rect.x, rect.y, rect.w, rect.h)
    end
end

function game.draw_shop_area()
    local rect = game.shop.rect
    love.graphics.setColor(config.shop_bg_color)
    love.graphics.rectangle('fill', rect.x, rect.y, rect.w, rect.h)
    love.graphics.setColor({1, 1, 1, 1})

    local shop_text_rect = Rect(rect.x, rect.y, rect.w, rect.h * 0.05)
    draw_text_inside_rect("SHOP", shop_text_rect, 'center')

    local margin_left = rect.w * config.shop.margin_left
    for _, button in ipairs(game.shop.buttons) do
        local scale, offset_x = button:layout(rect.w, margin_left)
        local x = button.position.x + offset_x
        local y = button.position.y
        button:draw(x, y, scale, offset_x)
    end

    local screen_width, screen_height = love.graphics.getDimensions()
    local shop_scrollbar_area = Rect(screen_width - config.scrollbar_width, 0, config.scrollbar_width, screen_height)
    game.shop.scrollbar:draw(shop_scrollbar_area)
end

function game.add_alarm(config)
    local shelf = 1 + math.floor(game.alarm.spot / 3)
    if shelf > game.alarm.shelf_count then
        game.alarm.shelf_count = game.alarm.shelf_count + 1
    end
    local alarm = Alarm(config, shelf, 120 * (game.alarm.spot % 3), game.skins[config.name])
    game.alarm.spot = game.alarm.spot + 1
    game.skins[config.name] = (game.skins[config.name] + 1) % config.skin_count
    game.alarm_stats[config.name].count = game.alarm_stats[config.name].count + 1
    table.insert(game.alarms, alarm)
end

return game
