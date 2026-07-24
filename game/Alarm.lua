local Timer = require('game.Timer')

local Alarm = require('libraries.knife.base'):extend()

function Alarm:constructor(config, shelf)
    self.config = config
    self.shelf = shelf

    print(self.config.name)
    print(self.config.Minigame)

    self.x_position = config.x_position or 0
    self.offset_x = 0

    self.timer = Timer(self.config.time, "start")
end

function Alarm:update(dt)
    self.timer:update(dt)

    if self.timer:done() then
        self.offset_x = math.random(-10, 10)
    end
end

return Alarm
