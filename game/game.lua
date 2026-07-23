local anim8 = require('libraries.anim8')
local lume = require('libraries.lume')
local lurker = require('libraries.lurker')

local Timer = require('game.Timer')
local Stopwatch = require('game.Stopwatch')
local gameplay = require('game.gameplay')


local game = {
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


local function load_images_from_directory(directory)
    local images = {}
    for _, item in ipairs(love.filesystem.getDirectoryItems(directory)) do
        local ext = item:match("%.([%w]+)$")
        local name = item:sub(1, #item - (#ext + 1))
        images[name] = love.graphics.newImage(directory .. "/" .. item)
    end
    return images
end

function game.register_timer(timer)
    table.insert(game.timers, timer)
    return timer
end

function game.load()
    local function createGrid(frame_width, frame_height, spritesheet)
        return anim8.newGrid(frame_width, frame_height, spritesheet:getPixelWidth(), spritesheet:getPixelHeight())
    end

    game.assets.fonts.shop = love.graphics.newFont("assets/fonts/shop.otf", 18)

    game.assets.images = load_images_from_directory("assets/sprites")
    game.assets.images.grids = {
        player = createGrid(64, 32, game.assets.images.player),
    }

    game.graphics.alarm_area_canvas = love.graphics.newCanvas(2 * config.actual_alarm_area_width, 2 * config.actual_alarm_area_height)

    gameplay.init(game)
end

function game.update(dt)
    lurker.update()

    for _, timer in ipairs(game.timers) do
        timer:update(dt)
    end

    gameplay.update(game, s, dt)
end

function game.calculate_alarm_area_parameters()
    alarm_area = {}

    local screen_width, screen_height = love.graphics.getDimensions()

    local alarm_area_canvas = game.graphics.alarm_area_canvas

    local shop_width = math.ceil(screen_width * config.shop_horizontal_screen_percentage)
    local alarm_area_width = screen_width - shop_width
    local alarm_area_height = screen_height

    alarm_area.scale = math.max(1.0, math.floor(alarm_area_width / config.actual_alarm_area_width))

    alarm_area.canvas_x = -0.5 * (alarm_area.scale * (alarm_area_canvas:getWidth() - config.actual_alarm_area_width) - (alarm_area_width - alarm_area.scale * config.actual_alarm_area_width))
    alarm_area.canvas_y = 0.0

    alarm_area.x = (alarm_area_canvas:getWidth() - config.actual_alarm_area_width) / 2.0
    alarm_area.y = 0
    alarm_area.width = config.actual_area_width
    alarm_area.height = screen_height

    return alarm_area
end

function game.draw()
    local screen_width, screen_height = love.graphics.getDimensions()

    local alarm_area_canvas = game.graphics.alarm_area_canvas

    local shop_width = math.ceil(screen_width * config.shop_horizontal_screen_percentage)
    local alarm_area_width = screen_width - shop_width
    local alarm_area_height = screen_height

    local scale = math.max(1.0, math.floor(alarm_area_width / config.actual_alarm_area_width))

    local canvas_x = -0.5 * (scale * (alarm_area_canvas:getWidth() - config.actual_alarm_area_width) - (alarm_area_width - scale * config.actual_alarm_area_width))
    local canvas_y = 0.0

    local offset_x = (alarm_area_canvas:getWidth() - config.actual_alarm_area_width) / 2.0
    local offset_y = 0

    local canvas_width = alarm_area_canvas:getWidth()
    local canvas_height = alarm_area_canvas:getHeight()
    love.graphics.setCanvas(alarm_area_canvas)
    gameplay.draw_alarm_area(game, offset_x, offset_y, config.actual_alarm_area_width, screen_height)
    love.graphics.setCanvas()

    love.graphics.draw(alarm_area_canvas, canvas_x, canvas_y, 0.0, scale)

    gameplay.draw_shop_area(game, screen_width - shop_width, 0, shop_width, screen_height)

    love.graphics.print("Hello! This is " .. game.obj.coin_count .. " Coins. :)", game.assets.fonts.shop, 0, 0)
end

function game.draw_text_centered(text, x, y, font)
    font = font or game.assets.fonts.shop

    local text_width = font:getWidth(text)
    love.graphics.print(text, font, x - text_width * 0.5, y)
end

function game.translate_mouse_screen_to_canvas_coords()
    alarm_area = game.calculate_alarm_area_parameters()

    local x = game.input.mouse.x
    local y = game.input.mouse.y

    x = x - alarm_area.canvas_x
    y = y - alarm_area.canvas_y
    x = x / alarm_area.scale
    y = y / alarm_area.scale

    return x, y
end

return game
