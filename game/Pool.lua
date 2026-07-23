local Pool = require('libraries.knife.base'):extend()

function Pool:constructor()
    self.items = {}
    self.used = {}
    self.freeList = {1}
end

function Pool:put(item)
    local slot = table.remove(self.freeList)

    if slot > #self.items then
        table.insert(self.items, item)
        table.insert(self.used, true)
        table.insert(self.freeList, 1 + #self.items)
    end

    self.used[slot] = true
    self.items[slot] = item

    return self.items[slot]
end

function Pool:get(index)
    if self.used[index] then
        return self.items[index], true
    else
        error('invalid index')
    end
end

function Pool:delete(index)
    if self.used[index] then
        self.used[index] = false
        table.insert(self.freeList, index)
    else
        error('invalid index')
    end
end

function Pool:foreach(func)
    for index, item in ipairs(self.items) do
        if self.used[index] then
            func(item)
        end
    end
end

function Pool:capacity()
    assert(#self.items == #self.used)
    return #self.items
end

function Pool:count()
    local count = 0
    self:foreach(function(_item)
        count = count + 1
    end)
    return count
end

return Pool
