 anim8 = require('libraries.anim8')
local lume = require('libraries.lume')
local lurker = require('libraries.lurker')

local Vector = require('libraries.brinevector')
local Rect = require('game.Rect')
local Timer = require('game.Timer')
local Stopwatch = require('game.Stopwatch')
local ShopButton = require('game.ShopButton')


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

    game.assets.images = load_images_from_directory("assets/sprites")
    game.assets.images.grids = {
        player = createGrid(64, 32, game.assets.images.player),
    }

    game.graphics.alarm_area_canvas = love.graphics.newCanvas(2 * config.actual_alarm_area_width, 2 * config.actual_alarm_area_height)

    local images = game.assets.images
    local grids = game.assets.images.grids

    game.obj.time = Stopwatch()

    local first = true

    game.obj.shop = {
        buttons = {},
    }
    for key, config in pairs(config.alarms) do
        for i = 1, 3 do
            table.insert(game.obj.shop.buttons, ShopButton(config))
        end
    end

    game.obj.shelves = {}
    game.obj.coin_count = 0
    for i = 1, 10 do
        table.insert(game.obj.shelves, {
            alarms = {},
        })

        if not first then
            table.insert(game.obj.shelves[i].alarms, {
                type = 'basic',
                position = {},
                spritesheet = images.pigeon,
            })
        else
            table.insert(game.obj.shelves[i].alarms, {
                type = 'basic',
                position = {},
                spritesheet = images.aquarium,
            })
        end
        first = false
    end

    game.obj.shop_area_scroll = 0
    game.obj.shop_total_height = 0
    game.obj.alarm_area_scroll = 0
end

function game.update(dt)
    lurker.update()

    local input = game.input
    local obj = game.obj

    local mouse_x, mouse_y = game.input.mouse.x, game.input.mouse.y

    local shop_rect = get_shop_rect()
    local cursor_in_shop = false
    if shop_rect:intersect_point(mouse_x, mouse_y) then
        cursor_in_shop = true
    end

    if cursor_in_shop then
        obj.shop_area_scroll = obj.shop_area_scroll + -1 * config.shop_scroll_strength * input.mouse.scroll
        obj.shop_area_scroll = math.clamp(obj.shop_area_scroll, 0, 1)
    else
        obj.alarm_area_scroll = obj.alarm_area_scroll + input.mouse.scroll
        obj.alarm_area_scroll = math.clamp(obj.alarm_area_scroll, config.min_scroll, config.max_scroll)
    end

    obj.time:update(dt)

    if input.just_pressed["f11"] then
        local fullscreen = love.window.getFullscreen()
        love.window.setFullscreen(not fullscreen, "desktop")
    end

    game.layout_shop_buttons()

    for _, button in ipairs(obj.shop.buttons) do
        button:update(dt)

        local button_rect = button.hitbox:to_rect(button.position.x, button.position.y)

        if button_rect:intersect_point(mouse_x, mouse_y) then
            button.hovered = true
        else
            button.hovered = false
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
    love.graphics.setCanvas()

    love.graphics.draw(alarm_area_canvas, canvas_x, canvas_y, 0.0, scale)

    game.draw_shop_area(game, shop_rect.x, 0, shop_width, screen_height)

    love.graphics.print("Hello! This is " .. obj.coin_count .. " Coins. :)", game.assets.fonts.shop, 0, 0)
end

function game.draw_alarm_area(game, ox, oy, w, h)
    love.graphics.clear({0.2, 0.2, 0.2, 1})
    love.graphics.setColor({0.3, 0.3, 0.3, 1})
    love.graphics.rectangle('fill', ox, oy, config.actual_alarm_area_width, config.actual_alarm_area_height)
    love.graphics.setColor({1, 1, 1, 1})

    local x = 0
    local y = config.shelf.pad + game.obj.alarm_area_scroll

    local mouse_x, mouse_y = translate_mouse_screen_to_canvas_coords(game.input.mouse.x, game.input.mouse.y)

    local over = false
    for index, shelf in ipairs(game.obj.shelves) do
        love.graphics.setColor({0.8, 0.7, 0.7, 1})
        love.graphics.rectangle('fill', ox + config.shelf.x_pad + x, y, w - 2 * config.shelf.x_pad, config.shelf.height)
        love.graphics.setColor({1, 1, 1, 1})

        for _, alarm in ipairs(shelf.alarms) do
            alarm.position.x = ox + 20 + x
            alarm.position.y = oy + y - alarm.spritesheet:getHeight()
            draw_sprite(alarm)

            local alarm_rect = Rect(alarm.position.x, alarm.position.y, 40, 40)
            if alarm_rect:intersect_point(mouse_x, mouse_y) then
                over = true
            end
        end

        y = y + config.shelf.height + config.shelf.pad
    end

    if over then
        love.graphics.setColor({0, 1, 0, 1})
    else
        love.graphics.setColor({1, 0, 0, 1})
    end
    love.graphics.rectangle('fill', mouse_x, mouse_y, 40, 40)
    love.graphics.setColor({1, 1, 1, 1})
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
        love.graphics.draw(game.assets.images.button_off, x, y, 0, scale)
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
end

function game.layout_shop_buttons()
    local shop_rect = get_shop_rect()

    local x = shop_rect.x + config.shop.margin_left
    local y = shop_rect.y + config.shop.margin_top
    for _, button in pairs(game.obj.shop.buttons) do
        button:layout(shop_rect.w, config.shop.margin_left)
        button.position.x = x
        local scroll_amount = -1 * (game.obj.shop_total_height - shop_rect.h) * game.obj.shop_area_scroll
        button.position.y = y + scroll_amount -- game.obj.shop_area_scroll
        y = y + button.hitbox.height + config.shop.button_pad_y
    end

    local button = game.obj.shop.buttons[1] -- Костыль, но как бы и нет?
                                            -- Программисты все называют костылями...
                                            -- Даже когда это не так.
    game.obj.shop_total_height = y
end


return game
