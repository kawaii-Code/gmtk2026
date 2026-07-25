local Alarm = require('libraries.knife.base'):extend()

function Alarm:constructor(config, shelf, x_position)
    self.config = config
    self.spritesheet = game.assets.images[config.sprite_name]
    self.sprite = game.animations[config.sprite_name_mini .. "_idle"]
    self.pressed = false
    assert(self.sprite, config.sprite_name_mini)
    assert(config.shelf)

    print(self.config.name)
    print(self.config.Minigame)

    print(shelf, x_position)
    self.shelf = shelf
    self.x_position = x_position
    self.x_offset = 0

    self.display = AlarmDisplay(config.display_animation, config.animation_full_path)

    self.timer = Timer(game.alarm_stats[self.config.name].time)--, "start")
    self.timer_done_last_frame = false
end

function Alarm:update(dt)
    self.timer:update(dt)

    self.display:display_time(math.ceil(self.timer.time))

    if not self.timer_done_last_frame and self.timer:done() then
        game.assets.sounds[self.config.sprite_name_mini .. "_going_off"]:play()
    end

    if not self.pressed and self.timer:done() then
        self.x_offset = math.random(-10, 10)
    end
    self.sprite:update(dt)

    self.timer_done_last_frame = self.timer:done()
end

function Alarm:on_press()
    game.assets.sounds[self.config.sprite_name_mini .. "_on_press"]:play()

    self.pressed = true
    self.x_offset = 0
    self.sprite = game.animations[self.config.sprite_name_mini .. "_press_in"]
    self.sprite:gotoFrame(1)
    self.sprite.onLoop = "pauseAtEnd"
    self.sprite:resume()
end

function Alarm:on_minigame_done()
    game.assets.sounds[self.config.sprite_name_mini .. "_on_done"]:play()

    self.pressed = false
    self.sprite = game.animations[self.config.sprite_name_mini .. "_press_out"]
    self.sprite:gotoFrame(1)
    self.sprite.onLoop = function()
        self.sprite = game.animations[self.config.sprite_name_mini .. "_idle"]
    end
    self.sprite:resume()
end

return Alarm
