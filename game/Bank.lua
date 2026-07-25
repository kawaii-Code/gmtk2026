local Bank = require('libraries.knife.base'):extend()

function Bank:constructor(money)
    self.money = money
end

function Bank:can_buy(alarm_config)
    return self.money >= alarm_config.upgrades["buy"].cost
end

function Bank:has(count)
    return self.money >= count
end

function Bank:buy(alarm_config)
    assert(self:can_buy(alarm_config))
    self.money = self.money - alarm_config.upgrades["buy"].cost
end

function Bank:spend(count)
    assert(self:has(count))
    self.money = self.money - count
end

function Bank:earn(amount)
    self.money = self.money + amount
end

return Bank
