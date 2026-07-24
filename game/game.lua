--
-- Все что не получится найти здесь, ищи в game_helpers.lua
--
local anim8 = require('libraries.anim8')
local lume = require('libraries.lume')
local lurker = require('libraries.lurker')

local Alarm = require('game.Alarm')
local Rect = require('game.Rect')
local Timer = require('game.Timer')
local Stopwatch = require('game.Stopwatch')
local ShopButton = require('game.ShopButton')
local Scrollbar = require('game.Scrollbar')
local Bank = require('game.Bank')


game = {
    -- Все что является файлов в `assets/`
    -- попадает сюда по такому же пути.
    assets = {
        images = {},
        fonts = {},
    },

    graphics = {}, -- Душные графические канвасы
    obj = {},      -- Игровые объекты
    input = {
        keys = {},
        just_pressed = {},
        mouse = {},
    },
    timers = {},
    debug = {},
}

require('game.game_helpers')


function game.load()
    local function createGrid(frame_width, frame_height, spritesheet)
        return anim8.newGrid(frame_width, frame_height, spritesheet:getPixelWidth(), spritesheet:getPixelHeight())
    end

    game.assets.fonts.shop = love.graphics.newFont("assets/fonts/shop.otf", 18)
    do
        game.assets.fonts.shop_size = {}
        local i = config.min_font_size
        while i <= config.max_font_size do
            game.assets.fonts.shop_size[i] = love.graphics.newFont("assets/fonts/shop.otf", i)
            i = i + 2
        end
    end

    game.assets.sounds = load_sounds_from_directory("assets/sounds")
    game.assets.images = load_images_from_directory("assets/sprites")
    game.assets.images.grids = {
        player = createGrid(64, 32, game.assets.images.player),
    }

    game.graphics.alarm_area_canvas = love.graphics.newCanvas(2 * config.actual_alarm_area_width, 2 * config.actual_alarm_area_height)

    game.bank = Bank(config.starting_money)

    local images = game.assets.images
    local grids = game.assets.images.grids

    game.obj.time = Stopwatch()

    local first = true

    game.obj.alarm_area = {
        scrollbar = Scrollbar(),
    }

    game.obj.shop = {
        buttons = {},
        scrollbar = Scrollbar(),
    }

    for _, config in ipairs(config.alarms) do
        table.insert(game.obj.shop.buttons, ShopButton(config))
    end

    game.obj.alarms = {}

    game.obj.shelf_count = 5

    game.obj.coin_count = 0

    game.obj.shop_total_height = 0
    game.obj.alarm_area_total_height = 0

    game.current_minigame = nil
end

function game.update(dt)
    lurker.update()

    local screen_width, screen_height = love.graphics.getDimensions()

    local input = game.input
    local obj = game.obj

    local mouse_x, mouse_y = game.input.mouse.x, game.input.mouse.y

    obj.time:update(dt)

    if input.just_pressed["f11"] then
        local fullscreen = love.window.getFullscreen()
        love.window.setFullscreen(not fullscreen, "desktop")
    end

    for _, alarm in ipairs(game.obj.alarms) do
        alarm:update(dt)

        local ox = (game.graphics.alarm_area_canvas:getWidth() - config.actual_alarm_area_width) / 2.0
        local x = ox + config.shelf.x_pad
        local y = config.shelf.pad + -1 * (game.obj.alarm_area_total_height - screen_height) * game.obj.alarm_area.scrollbar.scroll
        y = y + (alarm.shelf - 1) * (config.shelf.height + config.shelf.pad)
        y = y - game.assets.images.aquarium:getHeight()

        local alarm_rect = alarm.config.hitbox:to_rect(x, y)
        if alarm_rect:intersect_point(mouse_x, mouse_y) then
            if alarm.timer:done() and game.input.mouse.just_pressed then
                game.current_minigame = alarm.config.Minigame(alarm)
            end
        end
    end

    --
    -- UI
    --
    local shop_area_total_height = game.layout_shop_buttons_and_calculate_total_height()
    local alarm_area_total_height = game.calculate_alarm_area_height()

    local shop_rect = get_shop_rect()
    local cursor_in_shop = false
    if shop_rect:intersect_point(mouse_x, mouse_y) then
        cursor_in_shop = true
    end

    if cursor_in_shop then
        obj.shop.scrollbar.scroll = obj.shop.scrollbar.scroll - config.scroll_strength * input.mouse.scroll
        obj.shop.scrollbar.scroll = math.clamp(obj.shop.scrollbar.scroll, 0, 1)
    else
        obj.alarm_area.scrollbar.scroll = obj.alarm_area.scrollbar.scroll - config.scroll_strength * input.mouse.scroll
        obj.alarm_area.scrollbar.scroll = math.clamp(obj.alarm_area.scrollbar.scroll, 0, 1)
    end
    local screen_width, screen_height = love.graphics.getDimensions()
    local shop_scrollbar_area = Rect(screen_width - config.scrollbar_width, 0, config.scrollbar_width, screen_height)
    local alarm_area_scrollbar_area = Rect(shop_rect.x - config.scrollbar_width, 0, config.scrollbar_width, screen_height)
    game.obj.shop.scrollbar:update(shop_scrollbar_area, screen_height, shop_area_total_height)
    game.obj.alarm_area.scrollbar:update(alarm_area_scrollbar_area, screen_height, alarm_area_total_height)

    for _, button in ipairs(obj.shop.buttons) do
        button:update(dt)

        local button_rect = button.hitbox:to_rect(button.position.x, button.position.y)

        if button_rect:intersect_point(mouse_x, mouse_y) then
            button.hovered = true
            if game.input.mouse.just_pressed then
                if game.bank:can_buy(button.alarm) then
                    game.bank:buy(button.alarm)
                    button.bought = true
                    local shelf = math.random(1, 5)
                    local alarm = Alarm(button.alarm, shelf)
                    table.insert(game.obj.alarms, alarm)
                end
            end
        else
            button.hovered = false
        end
    end

    if game.current_minigame then
        if game.current_minigame:update(dt) then
            game.bank:earn(game.current_minigame.alarm.config.earn)
            game.current_minigame:on_done()
            game.current_minigame = nil
        end
    end
end

function game.draw()
    local obj = game.obj

    local screen_width, screen_height = love.graphics.getDimensions()

    local alarm_area_canvas = game.graphics.alarm_area_canvas

    local shop_rect = get_shop_rect()
    local shop_width = shop_rect.w
    local alarm_area_width = shop_rect.x
    local alarm_area_height = screen_height

    local scale = math.max(1.0, math.floor(alarm_area_width / config.actual_alarm_area_width))

    local canvas_x = -0.5 * (scale * (alarm_area_canvas:getWidth() - config.actual_alarm_area_width) - (alarm_area_width - scale * config.actual_alarm_area_width))
    local canvas_y = 0.0

    local offset_x = (alarm_area_canvas:getWidth() - config.actual_alarm_area_width) / 2.0
    local offset_y = 0

    local canvas_width = alarm_area_canvas:getWidth()
    local canvas_height = alarm_area_canvas:getHeight()
    love.graphics.setCanvas(alarm_area_canvas)
    game.draw_alarm_area(game, offset_x, offset_y, config.actual_alarm_area_width, screen_height)
    if game.current_minigame then
        game.current_minigame:draw(Rect(offset_x, offset_y, config.actual_alarm_area_width, screen_height))
    end
    love.graphics.setCanvas()

    love.graphics.draw(alarm_area_canvas, canvas_x, canvas_y, 0.0, scale)

    game.draw_shop_area(game, shop_rect.x, 0, shop_width, screen_height)

    love.graphics.print(game.bank.money .. "$", game.assets.fonts.shop, 0, 0)
end

function game.draw_alarm_area(game, ox, oy, w, h)
    love.graphics.clear({0.2, 0.2, 0.2, 1})
    love.graphics.setColor({0.3, 0.3, 0.3, 1})
    love.graphics.rectangle('fill', ox, oy, config.actual_alarm_area_width, config.actual_alarm_area_height)
    love.graphics.setColor({1, 1, 1, 1})

    local mouse_x, mouse_y = translate_mouse_screen_to_canvas_coords(game.input.mouse.x, game.input.mouse.y)

    local x = 0
    local y = config.shelf.pad + -1 * (game.obj.alarm_area_total_height - h) * game.obj.alarm_area.scrollbar.scroll
    for _ = 1, game.obj.shelf_count do
        love.graphics.setColor({0.8, 0.7, 0.7, 1})
        love.graphics.rectangle('fill', ox + config.shelf.x_pad + x, y, w - 2 * config.shelf.x_pad, config.shelf.height)
        love.graphics.setColor({1, 1, 1, 1})
        y = y + config.shelf.height + config.shelf.pad
    end

    local over = false
    for _, alarm in ipairs(game.obj.alarms) do
        local x = ox + config.shelf.x_pad + alarm.x_position + alarm.offset_x
        local y = config.shelf.pad + -1 * (game.obj.alarm_area_total_height - h) * game.obj.alarm_area.scrollbar.scroll
        y = y + (alarm.shelf - 1) * (config.shelf.height + config.shelf.pad)
        y = y - game.assets.images.aquarium:getHeight()

        local rect = alarm.config.hitbox:to_rect(x, y)

        love.graphics.draw(game.assets.images.aquarium, rect.x, rect.y)

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

    local screen_width, screen_height = love.graphics.getDimensions()
    local alarm_area_scrollbar_area = Rect(screen_width - 224 - config.scrollbar_width, 0, config.scrollbar_width, screen_height)
    game.obj.alarm_area.scrollbar:draw(alarm_area_scrollbar_area)
end

function game.draw_shop_area(game, ox, oy, w, h)
    love.graphics.setColor({1.0, 0.0, 0.32, 1})
    love.graphics.rectangle('fill', ox, oy, w, h)
    love.graphics.setColor({1, 1, 1, 1})

    draw_text_centered("SHOP", ox + w / 2, 0)

    for _, button in ipairs(game.obj.shop.buttons) do
        local scale, offset_x = button:layout(w, config.shop.margin_left)
        local rect = button.hitbox:to_rect(button.position.x, button.position.y)
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
    game.obj.shop.scrollbar:draw(shop_scrollbar_area)
end

function game.calculate_alarm_area_height()
    local y = config.shelf.pad

    for i = 1, game.obj.shelf_count do
        y = y + config.shelf.height + config.shelf.pad
    end
    game.obj.alarm_area_total_height = y
    return y
end

function game.layout_shop_buttons_and_calculate_total_height()
    local shop_rect = get_shop_rect()

    local x = shop_rect.x + config.shop.margin_left
    local y = shop_rect.y + config.shop.margin_top
    for _, button in pairs(game.obj.shop.buttons) do
        button:layout(shop_rect.w, config.shop.margin_left)
        button.position.x = x
        local scroll_amount = -1 * (game.obj.shop_total_height - shop_rect.h) * game.obj.shop.scrollbar.scroll
        button.position.y = y + scroll_amount
        y = y + button.hitbox.height + config.shop.button_pad_y
    end

    game.obj.shop_total_height = y
    return y
end


return game
