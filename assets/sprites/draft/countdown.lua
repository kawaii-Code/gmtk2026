-- countdown.lua
-- Скрипт генерации анимации обратного отсчета для Aseprite
-- Совместимость: v1.3.18-beta3 и выше

-- Встроенный 3x5 матричный шрифт для цифр от 0 до 9
local font_data = {
    ["0"] = {1,1,1, 1,0,1, 1,0,1, 1,0,1, 1,1,1},
    ["1"] = {0,1,0, 1,1,0, 0,1,0, 0,1,0, 1,1,1},
    ["2"] = {1,1,1, 0,0,1, 1,1,1, 1,0,0, 1,1,1},
    ["3"] = {1,1,1, 0,0,1, 1,1,1, 0,0,1, 1,1,1},
    ["4"] = {1,0,1, 1,0,1, 1,1,1, 0,0,1, 0,0,1},
    ["5"] = {1,1,1, 1,0,0, 1,1,1, 0,0,1, 1,1,1},
    ["6"] = {1,1,1, 1,0,0, 1,1,1, 1,0,1, 1,1,1},
    ["7"] = {1,1,1, 0,0,1, 0,0,1, 0,0,1, 0,0,1},
    ["8"] = {1,1,1, 1,0,1, 1,1,1, 1,0,1, 1,1,1},
    ["9"] = {1,1,1, 1,0,1, 1,1,1, 0,0,1, 1,1,1}
}

-- Функция отрисовки строки в объект Image с учетом масштаба
local function drawString(text, scale, colorInt)
    -- Базовые размеры: символ 3x5, отступ между символами - 1 пиксель
    local char_w = 3 * scale
    local char_h = 5 * scale
    local spacing = 1 * scale
    
    local text_w = #text * char_w + (#text - 1) * spacing
    local text_h = char_h

    -- Создаем прозрачное изображение под размер текста
    local img = Image(text_w, text_h, ColorMode.RGBA)

    for i = 1, #text do
        local char = text:sub(i, i)
        local glyph = font_data[char]
        
        if glyph then
            local offset_x = (i - 1) * (char_w + spacing)
            -- Перебираем сетку символа 3x5
            for gy = 0, 4 do
                for gx = 0, 2 do
                    local pixel = glyph[gy * 3 + gx + 1]
                    if pixel == 1 then
                        -- Отрисовка "суперпикселя" с учетом масштаба (Nearest-neighbor)
                        for sy = 0, scale - 1 do
                            for sx = 0, scale - 1 do
                                img:drawPixel(offset_x + gx * scale + sx, gy * scale + sy, colorInt)
                            end
                        end
                    end
                end
            end
        end
    end
    
    return img
end

-- Основная логика генерации спрайта
local function generateCountdown(color, fontSize)
    -- Переводим высоту шрифта в целочисленный масштаб (базовая высота шрифта = 5 px)
    local scale = math.max(1, math.floor(fontSize / 5))
    
    -- Вычисляем общие размеры для максимального числа "99"
    local char_w = 3 * scale
    local char_h = 5 * scale
    local spacing = 1 * scale
    local padding = 2 * scale -- Запас от края холста

    local text_w = (char_w * 2) + spacing
    local text_h = char_h

    local sprite_w = text_w + padding * 2
    local sprite_h = text_h + padding * 2

    -- Создаем новый спрайт
    local sprite = Sprite(sprite_w, sprite_h, ColorMode.RGBA)
    sprite.transparentColor = 0 -- Гарантируем прозрачный фон
    
    -- Получаем целое число для цвета RGBA, совместимое с drawPixel
    local colorInt = color.rgbaPixel
    local layer = sprite.layers[1]

    -- Цикл генерации от 99 до 00
    for i = 99, 0, -1 do
        local frameNum = 100 - i
        local frame
        
        -- Используем первый кадр по умолчанию, для остальных создаем пустые (чтобы избежать дублирования текста)
        if frameNum == 1 then
            frame = sprite.frames[1]
        else
            frame = sprite:newEmptyFrame()
        end

        -- Устанавливаем длительность кадра 100 мс (0.1 сек)
        frame.duration = 0.1

        -- Форматируем число с ведущим нулем (09, 08, 00)
        local text = string.format("%02d", i)
        
        -- Генерируем изображение с текстом
        local textImg = drawString(text, scale, colorInt)

        -- Вычисляем координаты для идеального центрирования
        local x = math.floor((sprite_w - textImg.width) / 2)
        local y = math.floor((sprite_h - textImg.height) / 2)

        -- Вставляем изображение в новый Cel на текущем кадре
        sprite:newCel(layer, frame, textImg, Point(x, y))
    end

    -- Делаем сгенерированный спрайт активным и подгоняем масштаб окна
    app.activeSprite = sprite
    app.command.FitToScreen()
end

-- Создание и настройка диалогового окна
local dlg = Dialog("Countdown Generator")

dlg:color{ 
    id = "textColor", 
    label = "Color:", 
    color = Color{ r=255, g=255, b=255, a=255 } 
}
dlg:slider{ 
    id = "fontSize", 
    label = "Font Size:", 
    min = 8, 
    max = 128, 
    value = 32 
}
dlg:button{ 
    id = "generate", 
    text = "Generate", 
    focus = true,
    onclick = function()
        local args = dlg.data
        generateCountdown(args.textColor, args.fontSize)
        dlg:close()
    end 
}
dlg:button{ 
    id = "cancel", 
    text = "Cancel" 
}

dlg:show()