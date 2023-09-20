

local cherry = {}
cherry.__index = cherry
activeCherries = {}
local Player = require("player")

function cherry.new(x, y)
    instance = setmetatable({}, cherry)
    instance.x = x
    instance.y = y
    instance.img = love.graphics.newImage("map/assests/cherry.png")
    instance.width = instance.img:getWidth()
    instance.height = instance.img:getHeight()
    instance.scaleX = 0.03
    instance.randomTimeOffset = math.random(0, 100)
    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "static")
    instance.physics.shape = love.physics.newRectangleShape(instance.width * 0.03, instance.height * 0.03)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setSensor(true)
    instance.toBeRemoved = false
    table.insert(activeCherries, instance)
end

function cherry:draw()
    love.graphics.setColor(1,1,1,1)
    love.graphics.draw(self.img, self.x, self.y, 0,self.scaleX * 0.03,0.03, self.width / 2, self.height / 2)
end

function cherry:remove()
    for i,instance in ipairs(activeCherries) do
        if instance == self then
            Player:incrementCherries()
            print(Player.cherries)
            self.physics.body:destroy()
            table.remove(activeCherries, i)
        end
    end
end

function cherry:update(dt)
    self:animate(dt)
    self:checkRemove()
end

function cherry:checkRemove()
    if self.toBeRemoved then
        self:remove()
    end
end

function cherry:animate(dt)
    self.scaleX = math.sin(love.timer.getTime() * 2 + self.randomTimeOffset)
end

function cherry.updateAll(dt)
    for i,instance in ipairs(activeCherries) do
        instance:update(dt)
    end
end

function cherry.drawAll()
    for i,instance in ipairs(activeCherries) do
        instance:draw()
    end
end

function cherry.beginContact(a, b, collision)
    for i,instance in ipairs(activeCherries) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                instance.toBeRemoved = true
                return true
            end
        end
    end
end


return cherry