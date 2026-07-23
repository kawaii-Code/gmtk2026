local Timer = require('libraries.knife.base'):extend()

function Timer:constructor(duration, start_mode)
    self.duration = duration
    if start_mode == "start" then
        self.time = self.duration
    else
        self.time = 0.0
    end
end

function Timer:stop()
    self.time = 0.0
end

function Timer:reset()
    self.time = self.duration
end

function Timer:reset_with_new_duration(duration)
    self.duration = duration
    self:reset()
end

function Timer:running()
    return not self:done()
end

function Timer:done()
    return self.time == 0.0
end

function Timer:progress()
    return 1.0 - self.time / self.duration
end

function Timer:update(dt)
    self.time = math.max(0.0, self.time - dt)
end

return Timer
