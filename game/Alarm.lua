local Alarm = require('libraries.knife.base'):extend()

function Alarm:constructor(config, shelf, x_position, skin)
    self.config = config
    self.spritesheet = game.assets.images[config.sprite_name .. "_" .. skin]
    self.sprite = game.animations[config.sprite_name_mini .. "_idle"]
    self.pressed = false
    assert(self.sprite, config.sprite_name_mini)

    print(self.config.name)
    print(self.config.Minigame)

    print(shelf, x_position)
    self.shelf = shelf
    self.x_position = x_position
    self.skin = skin
    self.x_offset = 0
    self.y_offset = 0

    self.press_in_animation = game.animations[self.config.sprite_name_mini .. "_press_in"]:clone()
    self.press_out_animation = game.animations[self.config.sprite_name_mini .. "_press_out"]:clone()

    self.pressed_stopwatch = Stopwatch()

    self.display = AlarmDisplay(config.animation_full_path)

    self.timer = Timer(game.alarm_stats[self.config.name].time, "start")
    self.timer_done_last_frame = false
end

function Alarm:update(dt)
    self.timer:update(dt)
    self.display:update(dt)
    self.pressed_stopwatch:update(dt)

    self.display:display_time(math.ceil(self.timer.time))

    if is_time_maxed_out(self.config) then
        if not self.pressed and self.timer:done() then
            self.pressed_stopwatch.stopped = false
            self:on_press(function()
                local earn = game.alarm_stats[self.config.name].earn
                game.bank:earn(earn)
                local money_effect = MoneyEffect(game.input.mouse.x, game.input.mouse.y, earn)
                table.insert(game.money_effects, money_effect)
                self.timer:reset_with_new_duration(game.alarm_stats[self.config.name].time)
                self:on_minigame_done()
            end)
        end
    else
        if not self.timer_done_last_frame and self.timer:done() then
            game.assets.sounds[self.config.sprite_name_mini .. "_alarm"]:play()
        end
    end

    if not self.pressed and self.timer:done() then
        self.x_offset = math.random(-3, 3)
        self.y_offset = math.random(-7, 7)
    end
    self.sprite:update(dt)

    self.timer_done_last_frame = self.timer:done()
end

function Alarm:on_press(callback)
    callback = callback or "pauseAtEnd"
    game.assets.sounds["on_press"]:play()

    self.pressed = true
    self.x_offset = 0
    self.y_offset = 0
    self.sprite = self.press_in_animation
    self.sprite:gotoFrame(1)
    self.sprite.onLoop = callback
    self.sprite:resume()

    self.display:reset_animation()
    self.display.press_out_animation = false
    self.display.press_in_animation = true
    self.display.offset_y = 0
end

function Alarm:on_minigame_done()
    game.assets.sounds["on_done"]:play()

    self.pressed_stopwatch.stopped = true
    self.pressed_stopwatch:reset()

    self.display:reset_animation()
    self.display.press_in_animation = false
    self.display.press_out_animation = true
    self.display.offset_y = 3

    self.pressed = false
    self.sprite = self.press_out_animation
    self.sprite:gotoFrame(1)
    self.sprite.onLoop = function()
        self.sprite = game.animations[self.config.sprite_name_mini .. "_idle"]
    end
    self.sprite:resume()
end

return Alarm
