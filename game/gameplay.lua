local Base = require('libraries.knife.base')
local Vector = require('libraries.brinevector')
local anim8 = require('libraries.anim8')
local lume = require('libraries.lume')

local Rect = require('game.Rect')
local Timer = require('game.Timer')
local Stopwatch = require('game.Stopwatch')


local gameplay = {}


local function draw_sprite(e)
    if e.animation then
        e.animations[e.animation]:draw(e.spritesheet, e.position.x + e.offset_x, e.position.y + e.offset_y)
    else
        local offset_x = e.offset_x or 0
        local offset_y = e.offset_y or 0
        love.graphics.draw(e.spritesheet, e.position.x + offset_x, e.position.y + offset_y)
    end
end

local function updateAnimation(e, deltaTime)
    e.animations[e.animation]:update(deltaTime)
end

local function distance(a, b)
    local dx = (a.x - b.x)
    local dy = (a.y - b.y)
    return math.sqrt(dx*dx + dy*dy)
end

local function moveToward(a, b, d)
    local direction = b - a
    return a + direction.normalized * d
end

function gameplay.init(game)
    local images = game.assets.images
    local grids = game.assets.images.grids

    game.time = Stopwatch()

    local first = true

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

    game.obj.scroll = 0
end

function gameplay.update(game, s, dt)
    game.obj.scroll = game.obj.scroll + game.input.mouse.scroll
    game.obj.scroll = math.clamp(game.obj.scroll, config.min_scroll, config.max_scroll)

    local player = game.player
    local input = game.input

    game.time:update(dt)

    if input.just_pressed["f11"] then
        local fullscreen = love.window.getFullscreen()
        love.window.setFullscreen(not fullscreen, "desktop")
    end

    if input.just_pressed["q"] then
        lume.trace(Game.player.position)
    end

    if input.just_pressed["f"] then
        game.debug.fly = not Debug.fly
    end

    local speed = config.player.speed
    if input.keys["lshift"] then
        speed = config.player.run_speed
    end
end

function gameplay.draw(game)
    drawSprite(game.cliff)
    for _, goblin in ipairs(game.goblins) do
        drawSprite(goblin)
    end
    drawSprite(game.player)
end

function gameplay.draw_alarm_area(game, ox, oy, w, h)
    love.graphics.clear({0.2, 0.2, 0.2, 1})
    love.graphics.setColor({0.3, 0.3, 0.3, 1})
    love.graphics.rectangle('fill', ox, oy, config.actual_alarm_area_width, config.actual_alarm_area_height)
    love.graphics.setColor({1, 1, 1, 1})

    local x = 0
    local y = config.shelf.pad + game.obj.scroll

    local mouse_x, mouse_y = game.translate_mouse_screen_to_canvas_coords()

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

function gameplay.draw_shop_area(game, ox, oy, w, h)
    love.graphics.setColor({0.6, 0.8, 0.8, 1})
    love.graphics.rectangle('fill', ox, oy, w, h)
    love.graphics.setColor({1, 1, 1, 1})

    game.draw_text_centered("SHOP", ox + w / 2, 0)
end

return gameplay
