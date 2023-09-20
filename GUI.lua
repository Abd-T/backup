local Player = require("player")
local Camera = require("camera")

local GUI = {}

function GUI:load()
    self.cherry = {}
    self.cherry.img = love.graphics.newImage("map/assests/cherry.png")
    self.cherry.width = self.cherry.img:getWidth()
    self.cherry.height = self.cherry.img:getHeight()
    self.cherry.scale = 0.05
    self.cherry.x = 20
    self.cherry.y = 20
    self.font = love.graphics.newFont("map/assests/Windsong.ttf", 300)

    
    self.hearts = {}
    self.hearts.img = love.graphics.newImage("map/assests/heart.png")
    self.hearts.width = self.hearts.img:getWidth()
    self.hearts.height = self.hearts.img:getHeight()
    self.hearts.x = 0
    self.hearts.y = 20
    self.hearts.scale = 0.05
    self.hearts.spacing = self.hearts.width * self.hearts.scale + 10    
end

function GUI:draw()
    self:displayCherries()
    self:displayHearts()
end

function GUI:displayHearts()
    for i=1, Player.health.current do
        local x = self.hearts.x + self.hearts.spacing * i + Camera.x
        love.graphics.setColor(0,0,0,0.5)
        love.graphics.draw(self.hearts.img, x + 2, 2 + self.hearts.y + Camera.y, 0, self.hearts.scale)
        love.graphics.setColor(1,1,1,1)
        love.graphics.draw(self.hearts.img, x, self.hearts.y + Camera.y, 0, self.hearts.scale)
    end
end

function GUI:displayCherries()
    love.graphics.setColor(0,0,0,0.5)
    love.graphics.draw(self.cherry.img, self.cherry.x + Camera.x + 392, self.cherry.y + Camera.y + 2, 0, self.cherry.scale, self.cherry.scale)
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(self.cherry.img, self.cherry.x + Camera.x + 390, self.cherry.y + Camera.y, 0, self.cherry.scale, self.cherry.scale)

    love.graphics.setFont(self.font)
    local x = self.cherry.x + self.cherry.width * self.cherry.scale -5 + Camera.x
    local y = self.cherry.y + self.cherry.height / 2 * self.cherry.scale -15 + Camera.y
    
    love.graphics.setColor(0,0,0,0.5)
    love.graphics.print(" : "..Player.cherries.."/ 60", x + 392, y + 2, 0, 0.08, 0.08 )
    love.graphics.setColor(1,1,1,1)
    love.graphics.print(" : "..Player.cherries.."/ 60", x + 390, y, 0, 0.08, 0.08 )
end

return GUI