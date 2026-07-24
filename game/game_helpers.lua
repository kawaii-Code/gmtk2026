local Rect = require('game.Rect')

function load_images_from_directory(directory)
    local images = {}
    for _, item in ipairs(love.filesystem.getDirectoryItems(directory)) do
        local ext = item:match("%.([%w]+)$")
        local name = item:sub(1, #item - (#ext + 1))
        images[name] = love.graphics.newImage(directory .. "/" .. item)
    end
    return images
end

function register_timer(timer)
    table.insert(game.timers, timer)
    return timer
end

function square_lerp(from, to, t)
    return from + (to - from) * (t*t)
end

function draw_sprite(e)
    if e.animation then
        e.animations[e.animation]:draw(e.spritesheet, e.position.x + e.offset_x, e.position.y + e.offset_y)
    else
        local offset_x = e.offset_x or 0
        local offset_y = e.offset_y or 0
        love.graphics.draw(e.spritesheet, e.position.x + offset_x, e.position.y + offset_y)
    end
end

function draw_text_inside_rect(text, rect, align)
    align = align or 'left'

    local font_height = math.floor(rect.h / 2) * 2
    font_height = math.clamp(font_height, config.min_font_size, config.max_font_size)
    local large_enough_font = game.assets.fonts.shop_size[font_height]
    if align == 'left' then
        love.graphics.print(text, large_enough_font, rect.x, rect.y)
    elseif align == 'center' then
        local text_width = large_enough_font:getWidth(text)
        local rect_center = rect.x + 0.5 * rect.w
        love.graphics.print(text, large_enough_font, rect_center - text_width * 0.5, rect.y)
    else
        error('align')
    end
end

function calculate_alarm_area_parameters()
    alarm_area = {}

    local screen_width, screen_height = love.graphics.getDimensions()

    local alarm_area_canvas = game.graphics.alarm_area_canvas

    local shop_rect = get_shop_rect()
    local shop_width = shop_rect.w
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

function get_shop_rect()
    local screen_width, screen_height = love.graphics.getDimensions()
    local shop_width = math.ceil(screen_width * config.shop_horizontal_screen_percentage)
    local result = Rect(screen_width - shop_width, 0, shop_width, screen_height)
    result.w = result.w - 30
    return result
end

function draw_text_centered(text, x, y, font)
    font = font or game.assets.fonts.shop

    local text_width = font:getWidth(text)
    love.graphics.print(text, font, x - text_width * 0.5, y)
end

function translate_mouse_screen_to_canvas_coords(mouse_x, mouse_y)
    alarm_area = calculate_alarm_area_parameters()

    local x = mouse_x
    local y = mouse_y

    x = x - alarm_area.canvas_x
    y = y - alarm_area.canvas_y
    x = x / alarm_area.scale
    y = y / alarm_area.scale

    return x, y
end

function updateAnimation(e, deltaTime)
    e.animations[e.animation]:update(deltaTime)
end

function distance(a, b)
    local dx = (a.x - b.x)
    local dy = (a.y - b.y)
    return math.sqrt(dx*dx + dy*dy)
end

function moveToward(a, b, d)
    local direction = b - a
    return a + direction.normalized * d
end
