local SimpleClickMinigame = require('libraries.knife.base'):extend()

-- Вызывается когда на нас кликают
function SimpleClickMinigame:constructor(alarm)
    self.alarm = alarm
end

function SimpleClickMinigame:update(dt)
    return true
end

function SimpleClickMinigame:draw(screen_height, mouse)
end

return SimpleClickMinigame
