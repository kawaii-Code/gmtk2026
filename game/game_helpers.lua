-----------------------------------------------------
-- Загрузка ассетов
function get_all_files_in_directory(directory)
    local files = {}
    get_all_files_in_directory_recursive(directory, files)
    return files
end

function get_all_files_in_directory_recursive(directory, files)
    for _, item in ipairs(love.filesystem.getDirectoryItems(directory)) do
        local file = directory .. "/" .. item
        local info = love.filesystem.getInfo(file)
        if info then
            if info.type == "file" then
                table.insert(files, file)
            elseif info.type == "directory" then
                get_all_files_in_directory_recursive(file, files)
            end
        end
    end
end

function load_font_with_different_sizes(filepath)
    fonts = {}
    do
        local i = config.min_font_size
        while i <= config.max_font_size do
            fonts[i] = love.graphics.newFont(filepath, i)
            i = i + 2
        end
    end
    return fonts
end

function load_images_from_directory(directory)
    local files = get_all_files_in_directory(directory)
    local images = {}
    for _, item in ipairs(files) do
        local ext = item:match("%.([%w]+)$")
        if ext and ext == "png" then
            local name = item:sub(16, #item - (#ext + 1))
            name = name:gsub("/", "_")
            images[name] = love.graphics.newImage(item)
        end
    end
    return images
end


function load_sounds_from_directory(directory)
    local files = get_all_files_in_directory(directory)
    local sounds = {}
    for _, item in ipairs(files) do
        local ext = item:match("%.([%w]+)$")
        local name = item:sub(15, #item - (#ext + 1))
        name = name:gsub("/", "_")
        sounds[name] = love.audio.newSource(item, "static")
    end
    return sounds
end




-----------------------------------------------------
-- Хелперы для отрисовки
function draw_sprite(e)
    if e.animation then
        e.animations[e.animation]:draw(e.spritesheet, e.position.x + e.offset_x, e.position.y + e.offset_y)
    else
        local offset_x = e.offset_x or 0
        local offset_y = e.offset_y or 0
        love.graphics.draw(e.spritesheet, e.position.x + offset_x, e.position.y + offset_y)
    end
end

function draw_text_inside_rect(text, rect, align, color, r)
    align = align or 'left'
    color = color or config.font_color

    local font_height = math.floor(rect.h / 2) * 2
    font_height = math.clamp(font_height, config.min_font_size, config.max_font_size)

    local fonts = game.assets.fonts.shop
    if game.bold then
        fonts = game.assets.fonts.shop_bold
    end

    local large_enough_font = fonts[font_height]
    local text_width = large_enough_font:getWidth(text)
    if text_width > rect.w then
        local i = config.min_font_size
        while i < config.max_font_size do
            local w = fonts[i]:getWidth(text)
            if w >= rect.w then
                break
            end
            i = i + 2
        end

        large_enough_font = fonts[i]
        font_height = i
    end

    love.graphics.setColor(color)
    if align == 'left' then
        love.graphics.print(text, large_enough_font, rect.x, rect.y + 0.5 * (rect.h - font_height), r)
    elseif align == 'center' then
        local text_width = large_enough_font:getWidth(text)
        love.graphics.print(text, large_enough_font, rect.x + 0.5 * (rect.w - text_width), rect.y + 0.5 * (rect.h - large_enough_font:getHeight()), r)
    else
        error('align')
    end
    love.graphics.setColor({1, 1, 1, 1})
end

function draw_sprite_inside_rect(sprite, rect)
    local scale = math.max(rect.w / sprite:getWidth(), rect.h / sprite:getHeight())
    love.graphics.draw(sprite, rect.x, rect.y, 0, scale)
end

function draw_sprite_inside_rect_min(sprite, rect)
    local scale = math.min(rect.w / sprite:getWidth(), rect.h / sprite:getHeight())
    local sw = scale * sprite:getWidth()
    local sh = scale * sprite:getHeight()
    love.graphics.draw(sprite, rect.x + 0.5 * (rect.w - sw), rect.y + 0.5 * (rect.h - sh), 0, scale)
end


function draw_text_centered(text, x, y, font)
    font = font or game.assets.fonts.shop[18]
    if game.bold then
        font = game.assets.fonts.shop_bold[18]
    end

    local text_width = font:getWidth(text)
    love.graphics.setColor(config.font_color)
    love.graphics.print(text, font, x - text_width * 0.5, y)
    love.graphics.setColor({1, 1, 1, 1})
end

function draw_rectangle(r, mode)
    mode = mode or 'line'
    love.graphics.rectangle(mode, r.x, r.y, r.w, r.h)
end



-----------------------------------------------------
-- UI
function layout_alarm_screen()
    local screen_width, screen_height = love.graphics.getDimensions()
    local canvas = game.alarm.canvas

    local alarm_full_rect = Rect(0, 0, game.shop.rect.x, screen_height)

    local scale = math.max(1.0, math.floor(alarm_full_rect.w / canvas:getWidth()))

    local x = 0.5 * (alarm_full_rect.w - scale * canvas:getWidth())
    local y = 0
    local w = canvas:getWidth()
    local h = config.alarm.height + math.ceil(screen_height / scale - config.alarm.height)
    if not game.alarm.scrollbar:is_hidden() then
        w = w - config.scrollbar_width
    end

    local shelf_y = config.alarm.margin_top
    for i = 1, game.alarm.shelf_count do
        shelf_y = shelf_y + config.alarm.shelf.height + config.alarm.shelf.spacing
    end

    game.alarm.content_height = shelf_y
    game.alarm.rect = Rect(x, y, w, h)
    game.alarm.scale = scale
    game.alarm.full_rect = alarm_full_rect
end

function layout_shop_screen()
    local screen_width, screen_height = love.graphics.getDimensions()
    local shop_width = math.ceil(screen_width * config.shop_horizontal_screen_percentage)
    local shop_rect = Rect(screen_width - shop_width, 0, shop_width, screen_height)
    if not game.shop.scrollbar:is_hidden() then
        shop_rect.w = shop_rect.w - config.scrollbar_width
    end

    local scrollbar_fix = shop_width - config.scrollbar_width
    local margin_left = scrollbar_fix * config.shop.margin_left
    local spacing = shop_rect.h * 0.03
    local x = shop_rect.x + margin_left
    local y = shop_rect.y + shop_rect.h * 0.07
    for _, button in pairs(game.shop.buttons) do
        button:layout(scrollbar_fix, margin_left)
        button.position.x = x
        button.position.y = y + game.shop.scrollbar:pixel_scroll()
        y = y + button.hitbox.height + spacing
    end

    game.shop.rect = shop_rect
    game.shop.content_height = y
end

function count_cost(alarm_config)
    local n = game.alarm_stats[alarm_config.name].count
    return alarm_config.upgrades["buy"].cost * math.pow(2, n)
end

function is_time_maxed_out(alarm_config)
    return game.alarm_stats[alarm_config.name].time_upgrade_level == 1 + #alarm_config.upgrades["time"]
end

function is_time_pre_maxed_out(alarm_config)
    return game.alarm_stats[alarm_config.name].time_upgrade_level == #alarm_config.upgrades["time"]
end

function is_earn_maxed_out(alarm_config)
    return game.alarm_stats[alarm_config.name].earn_upgrade_level == 1 + #alarm_config.upgrades["earn"]
end

function alarm_position(alarm)
    local x = config.alarm.shelf.margin_horizontal + alarm.x_position + alarm.x_offset
    local y = config.alarm.margin_top + (alarm.shelf - 1) * (config.alarm.shelf.spacing + config.alarm.shelf.height)
    local w, h = alarm.sprite:getDimensions()
    y = y - h
    y = y + game.alarm.scrollbar:pixel_scroll()
    y = y + 5
    y = y + alarm.y_offset
    return x, y
end

function translate_mouse_to_alarm_screen()
    local x = game.input.mouse.x
    local y = game.input.mouse.y

    x = x - game.alarm.rect.x
    y = y - game.alarm.rect.y
    x = x / game.alarm.scale
    y = y / game.alarm.scale

    return x, y
end

-----------------------------------------------------
-- Рандомные функции
function register_timer(timer)
    table.insert(game.timers, timer)
    return timer
end

function square_lerp(from, to, t)
    return from + (to - from) * (t*t)
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
