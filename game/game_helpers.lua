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
        print(name)
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

function draw_text_inside_rect(text, rect, align)
    align = align or 'left'

    local font_height = math.floor(rect.h / 2) * 2
    font_height = math.clamp(font_height, config.min_font_size, config.max_font_size)
    local large_enough_font = game.assets.fonts.shop[font_height]
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

function draw_text_centered(text, x, y, font)
    font = font or game.assets.fonts.shop[18]
    local text_width = font:getWidth(text)
    love.graphics.print(text, font, x - text_width * 0.5, y)
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
    local h = config.alarm.height + math.ceil(scale * (screen_height - canvas:getHeight()))
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

    local x = shop_rect.x + config.shop.margin_left
    local y = shop_rect.y + config.shop.margin_top
    for _, button in pairs(game.shop.buttons) do
        button:layout(shop_rect.w, config.shop.margin_left)
        button.position.x = x
        button.position.y = y + game.shop.scrollbar:pixel_scroll()
        y = y + button.hitbox.height + config.shop.button_spacing
    end

    game.shop.rect = shop_rect
    game.shop.content_height = y
end

function alarm_position(alarm)
    local x = config.alarm.shelf.margin_horizontal + alarm.x_position + alarm.x_offset
    local y = config.alarm.margin_top + (alarm.shelf - 1) * (config.alarm.shelf.spacing + config.alarm.shelf.height)
    local w, h = alarm.sprite:getDimensions()
    y = y - h
    y = y + game.alarm.scrollbar:pixel_scroll()
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
