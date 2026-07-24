local Scrollbar = require('libraries.knife.base'):extend()

function Scrollbar:constructor()
    self.scroll = 0.0
    self.content_height = 0
    self.visible_height = 0
    self.size = 1

    self.getting_scrolled = false
    self.scroll_start_y = 0
end

function Scrollbar:is_hidden()
    return self.size >= 1
end

function Scrollbar:rect(scrollbar_area)
    local total_height = scrollbar_area.h
    local scroll_handle_height = total_height * self.size
    return Rect(
        scrollbar_area.x,
        scrollbar_area.y + self.scroll * (total_height - scroll_handle_height),
        scrollbar_area.w,
        scroll_handle_height
    )
end

function Scrollbar:pixel_scroll()
    return -1 * (self.content_height - self.visible_height) * self.scroll
end

function Scrollbar:update(scrollbar_area, visible_height, content_height)
    self.visible_height = visible_height
    self.content_height = content_height

    self.size = visible_height / content_height
    if self:is_hidden() then
        self.scroll = 0
        return
    end

    local rect = self:rect(scrollbar_area)

    if rect:intersect_point(game.input.mouse.x, game.input.mouse.y) then
        if game.input.mouse.pressed then
            if not self.getting_scrolled then
                self.scroll_start_y = game.input.mouse.y
                self.getting_scrolled = true
            end
        end
    end

    if self.getting_scrolled then
        local scroll_amount = 2 * (game.input.mouse.y - self.scroll_start_y) / scrollbar_area.h
        self.scroll_start_y = game.input.mouse.y
        self.scroll = self.scroll + scroll_amount
        self.scroll = math.clamp(self.scroll, 0, 1)
    end

    if not game.input.mouse.pressed then
        self.getting_scrolled = false
    end
end

function Scrollbar:draw(scrollbar_area)
    if self:is_hidden() then
        return
    end

    love.graphics.setColor({0, 1, 1, 1})
    love.graphics.rectangle('fill', scrollbar_area.x, scrollbar_area.y, scrollbar_area.w, scrollbar_area.h)
    love.graphics.setColor({1, 1, 1, 1})

    local rect = self:rect(scrollbar_area)
    love.graphics.setColor({1, 0, 0, 1})
    love.graphics.rectangle('fill', rect.x, rect.y, rect.w, rect.h)
    love.graphics.setColor({1, 1, 1, 1})
end

return Scrollbar
