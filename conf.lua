anim8 = require('libraries.anim8')
lume = require('libraries.lume')

Alarm = require('game.Alarm')
AlarmDisplay = require('game.AlarmDisplay')
Rect = require('game.Rect')
Timer = require('game.Timer')
Hitbox = require('game.Hitbox')
Stopwatch = require('game.Stopwatch')
ShopButton = require('game.ShopButton')
MoneyEffect = require('game.MoneyEffect')
Scrollbar = require('game.Scrollbar')
SimpleClickMinigame = require('game.SimpleClickMinigame')
ClickSpriteMinigame = require('game.ClickSpriteMinigame')
WalkAroundMinigame = require('game.WalkAroundMinigame')
FishingMinigame = require('game.FishingMinigame')
Bank = require('game.Bank')

require('game.game')
require('game.game_helpers')
require('game.math')

config = {}

config.screen = {}
config.screen.width = 240
config.screen.height = 135

config.camera = {}
config.camera.smoothing = 0.1

config.goblin = {}
config.goblin.speed = 5

config.player = {}
config.player.speed = 10
config.player.run_speed = 25

-- Не будильники, а игровая область.
-- Ибо лень писать alarm_area везде.
config.alarm = {
    width = 400,
    height = 600,
    margin_top = 150,
    shelf = {
        margin_horizontal = 5,
        height = 20,
        spacing = 120,
    },
}

config.actual_alarm_area_width = 400
config.actual_alarm_area_height = 600

config.min_font_size = 8
config.max_font_size = 72

config.shop_button_hover_scale = 1.05
config.scroll_strength = 0.01--/108 -- 1% за один микро-прокрутку колеса

config.shop = {
    margin_left = 0.03,
    button_spacing = 15,
}

config.shop_horizontal_screen_percentage = 0.4

config.starting_money = 10

config.cursor_size = 0.12

local r,g,b,a = lume.color("#474152")
config.font_color = {r, g, b, a}
r,g,b,a = lume.color("#CBBFCF")
config.shop_bg_color = {r, g, b, a}
r,g,b,a = lume.color("#f4d2cd")
config.bg_color = {r, g, b, a}
config.scrollbar_bg = config.shop_bg_color
config.money_effect_color = {0, 1, 0, 1}
r,g,b,a = lume.color("#7d7390")
config.scrollbar_fg = {r, g, b, a}--config.font_color
r,g,b,a = lume.color("#ebaebc")
config.crabs = {r,g,b,a}

config.scrollbar_width = 25


config.time_scale = 1.2

-- В каком порядке они здесь, в таком же порядке будут и в магазине
-- СЛАВЕ: наверное удобнее будет создавать апгрейды не вручную здесь
-- в таблице, а ниже написать какой-нибудь цикл, где ты эти значения
-- наделаешь.
config.alarms = {
    {
        name = "digital",
        skin_count = 4,
        hitbox = Hitbox(0, 80, 100, 70),
        animation_full_path = "release_countdown",
        sprite_name = "alarm_digital",
        sprite_name_mini = "digital",
        Minigame = SimpleClickMinigame,

        upgrades = {
            ["buy"] = {
                cost = 5,
                earn = 5,
                time = 5,
            },
            ["time"] = {
                { cost = 6, bonus = 1 },
                { cost = 0, bonus = 1 },
                { cost = 0, bonus = 1 },
            },
        },
    },

    {
        name = "clock",
        hitbox = Hitbox(0, 70, 75, 80),

        skin_count = 4,
        animation_full_path = "release_clock_clock",
        sprite_name = "alarm_clock",
        sprite_name_mini = "clock",

        Minigame = SimpleClickMinigame,

        upgrades = {
            ["buy"] = {
                cost = 25,
                earn = 25,
                time = 30,
            },
            ["time"] = {
                { cost = 30, bonus = 5 }, -- -1 секунда времени за 10 бачей
                { cost = 0, bonus = 5 },
                { cost = 0, bonus = 5 },
                { cost = 0, bonus = 5 },
            },
        },
    },

    {
        name = "crab",
        skin_count = 1,
        hitbox = Hitbox(0, 80, 90, 70),
        animation_full_path = "release_countdown_crab",
        sprite_name = "alarm_crab",
        sprite_name_mini = "crab",
        Minigame = WalkAroundMinigame,

        upgrades = {
            ["buy"] = {
                cost = 100,
                earn = 50,
                time = 16,
            },
            ["time"] = {
                { cost = 50, bonus = 3 },
                { cost = 0, bonus = 3 },
                { cost = 0, bonus = 3 },
            },
        },
    },

    {
        name = "bear",
        skin_count = 1,
        hitbox = Hitbox(0, 80, 90, 70),
        animation_full_path = "release_bear_clock",
        sprite_name = "alarm_bear",
        sprite_name_mini = "bear",

        Minigame = ClickSpriteMinigame,

        upgrades = {
            ["buy"] = {
                cost = 256,
                earn = 1024,
                time = 32,
            },
            ["time"] = {
                { cost = 512, bonus = 8 },
                { cost = 0, bonus = 8 },
                { cost = 0, bonus = 8 },
            },
        },
    },

    {
        name = "aquarium",
        skin_count = 1,
        hitbox = Hitbox(0, 20, 130, 130),
        animation_full_path = "release_aquarium-clock",
        sprite_name = "alarm_aquarium",
        sprite_name_mini = "aquarium",
        Minigame = FishingMinigame,

        upgrades = {
            ["buy"] = {
                cost = 5000,
                earn = 3000,
                time = 10,
            },
            ["time"] = {
                { cost = 500, bonus = 2 }, -- -1 секунда времени за 10 бачей
                { cost = 0, bonus = 2 },
                { cost = 0, bonus = 2 },
                { cost = 0, bonus = 2 },
            },
        },
    },

    {
        name = "old_fashion",
        skin_count = 1,
        hitbox = Hitbox(0, 80, 120, 70),
        animation_full_path = "release_old_fashion_clock",
        sprite_name = "alarm_old_fashion",
        sprite_name_mini = "old_fashion",
        Minigame = SimpleClickMinigame,

        upgrades = {
            ["buy"] = {
                cost = 12500,
                earn = 15000,
                time = 60,
            },
            ["time"] = {
                { cost = 4000, bonus = 5 },
                { cost = 0, bonus = 5 },
                { cost = 0, bonus = 5 },
            },
        },
    },

    {
        name = "crocodile",
        skin_count = 1,
        hitbox = Hitbox(0, 80, 70, 70),
        animation_full_path = "release_crocodile_clock",
        sprite_name = "alarm_crocodile",
        sprite_name_mini = "crocodile",
        Minigame = SimpleClickMinigame,

        upgrades = {
            ["buy"] = {
                cost = 30000,
                earn = 10000,
                time = 5,
            },
            ["time"] = {
                { cost = 5000, bonus = 1 },
                { cost = 0, bonus = 1 },
                { cost = 0, bonus = 1 },
            },
        },
    },

    -- {
    --     name = "shooting_range",
    --     skin_count = 1,
    --     hitbox = Hitbox(0, 50, 110, 110),
    --     animation_full_path = "release_shooting_range_clock",
    --     sprite_name = "alarm_shooting_range",
    --     sprite_name_mini = "shooting_range",
    --     Minigame = SimpleClickMinigame,

    --     upgrades = {
    --         ["buy"] = {
    --             cost = 70000,
    --             earn = 10000,
    --             time = 40,
    --         },
    --         ["time"] = {
    --             { cost = 100000, bonus = 5 },
    --             { cost = 0, bonus = 5 },
    --             { cost = 0, bonus = 5 },
    --         },
    --     },
    -- },

    {
        name = "bomb",
        skin_count = 1,
        hitbox = Hitbox(0, 50, 110, 110),
        animation_full_path = "release_bomb",
        sprite_name = "alarm_bomb",
        sprite_name_mini = "bomb",
        Minigame = SimpleClickMinigame,

        upgrades = {
            ["buy"] = {
                cost = 70000,
                earn = '?',
                time = 9,
            },
            ["time"] = {
                { cost = 10000000, bonus = 5 },
                { cost = 0, bonus = 5 },
                { cost = 0, bonus = 5 },
            },
        },
    },
}

for _, config in ipairs(config.alarms) do
    config.upgrades["earn"] = { {cost = math.floor(1.5 * config.upgrades["buy"].cost), bonus = config.upgrades["buy"].earn} }

    local first = true
    local last_cost = 0
    for _, v in ipairs(config.upgrades["time"]) do
        if not first then
            v.cost = math.ceil(1.8 * last_cost)
        end
        last_cost = v.cost
        first = false
    end
end


config.mouse_scroll_strength = 10

function love.conf(t)
    t.identity = nil                    -- The name of the save directory (string)
    t.appendidentity = false            -- Search files in source directory before save directory (boolean)
    t.version = "11.4"                  -- The LÖVE version this game was made for (string)
    t.console = false                   -- Attach a console (boolean, Windows only)
    t.accelerometerjoystick = true      -- Enable the accelerometer on iOS and Android by exposing it as a Joystick (boolean)
    t.externalstorage = false           -- True to save files (and read from the save directory) in external storage on Android (boolean)
    t.gammacorrect = true              -- Enable gamma-correct rendering, when supported by the system (boolean)

    t.audio.mic = false                 -- Request and use microphone capabilities in Android (boolean)
    t.audio.mixwithsystem = true        -- Keep background music playing when opening LOVE (boolean, iOS and Android only)

    t.window.title = "Alarm Alarm"         -- The window title (string)
    t.window.icon = nil                 -- Filepath to an image to use as the window's icon (string)
    t.window.width = config.screen.width * 4                -- The window width (number)
    t.window.height = config.screen.height * 4               -- The window height (number)
    t.window.borderless = false         -- Remove all border visuals from the window (boolean)
    t.window.resizable = true          -- Let the window be user-resizable (boolean)
    t.window.minwidth = config.screen.width               -- Minimum window width if the window is resizable (number)
    t.window.minheight = config.screen.height              -- Minimum window height if the window is resizable (number)
    t.window.fullscreen = false         -- Enable fullscreen (boolean)
    t.window.fullscreentype = "desktop" -- Choose between "desktop" fullscreen or "exclusive" fullscreen mode (string)
    t.window.vsync = 1                  -- Vertical sync mode (number)
    t.window.msaa = 0                   -- The number of samples to use with multi-sampled antialiasing (number)
    t.window.depth = nil                -- The number of bits per sample in the depth buffer
    t.window.stencil = nil              -- The number of bits per sample in the stencil buffer
    t.window.display = 1                -- Index of the monitor to show the window in (number)
    t.window.highdpi = false            -- Enable high-dpi mode for the window on a Retina display (boolean)
    t.window.usedpiscale = true         -- Enable automatic DPI scaling when highdpi is set to true as well (boolean)
    t.window.x = nil                    -- The x-coordinate of the window's position in the specified display (number)
    t.window.y = nil                    -- The y-coordinate of the window's position in the specified display (number)

    t.modules.audio = true              -- Enable the audio module (boolean)
    t.modules.data = true               -- Enable the data module (boolean)
    t.modules.event = true              -- Enable the event module (boolean)
    t.modules.font = true               -- Enable the font module (boolean)
    t.modules.graphics = true           -- Enable the graphics module (boolean)
    t.modules.image = true              -- Enable the image module (boolean)
    t.modules.joystick = true           -- Enable the joystick module (boolean)
    t.modules.keyboard = true           -- Enable the keyboard module (boolean)
    t.modules.math = true               -- Enable the math module (boolean)
    t.modules.mouse = true              -- Enable the mouse module (boolean)
    t.modules.physics = false            -- Enable the physics module (boolean)
    t.modules.sound = true              -- Enable the sound module (boolean)
    t.modules.system = true             -- Enable the system module (boolean)
    t.modules.thread = false             -- Enable the thread module (boolean)
    t.modules.timer = true              -- Enable the timer module (boolean), Disabling it will result 0 delta time in love.update
    t.modules.touch = false              -- Enable the touch module (boolean)
    t.modules.video = true              -- Enable the video module (boolean)
    t.modules.window = true             -- Enable the window module (boolean)
end
