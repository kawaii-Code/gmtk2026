local Stopwatch = require('libraries.knife.base'):extend()

function Stopwatch:constructor()
    self:reset()
end

function Stopwatch:update(dt)
    self.time = self.time + dt
end

function Stopwatch:reset()
    self.time = 0.0
end

return Stopwatch
