local SimpleClickMinigame = require('game.SimpleClickMinigame')
local Hitbox = require('game.Hitbox')

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

config.actual_alarm_area_width = 400
config.actual_alarm_area_height = 600

config.min_font_size = 8
config.max_font_size = 72

config.shop_button_hover_scale = 1.05
config.scroll_strength = 0.01 -- 1% за один микро-прокрутку колеса

config.shop = {
    margin_top = 40,
    margin_left = 20,
    button_pad_y = 15,
}

config.starting_money = 10

config.scrollbar_width = 25

config.alarms = {
    {
        name = "basic",
        shop_icon = "icon",
        cost = 10,
        earn = 5,
        time = 3,
        hitbox = Hitbox(0, 0, 130, 130),
        Minigame = SimpleClickMinigame,
    },
    {
        name = "digital",
        shop_icon = "icon",
        cost = 10,
        earn = 5,
        time = 3,
        hitbox = Hitbox(0, 0, 130, 130),
        Minigame = SimpleClickMinigame,
    },
    {
        name = "crab",
        shop_icon = "icon",
        cost = 30,
        earn = 10,
        time = 10,
        hitbox = Hitbox(0, 0, 130, 130),
        Minigame = SimpleClickMinigame,
    },
}


config.shelf = {
    x_pad = 5,
    height = 20,
    pad = 60,
}

config.shop_horizontal_screen_percentage = 0.3  -- 30% по горизонтали занимает магазин

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
