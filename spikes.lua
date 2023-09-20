local spikes = {}
spikes.__index = spikes
local activeSpikes = {}
local Player = require("player")

function spikes.new(x, y)
    instance = setmetatable({}, spikes)
    instance.x = x
    instance.y = y
    instance.img = love.graphics.newImage("map/assests/spikes.png")
    instance.width = instance.img:getWidth()
    instance.height = instance.img:getHeight()
    
    instance.damage = 1
    instance.color = 1
    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "static")
    instance.physics.shape = love.physics.newRectangleShape(instance.width * 0.03, instance.height * 0.03)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.fixture:setSensor(true)
   
    table.insert(activeSpikes, instance)
end

function spikes:draw()
    love.graphics.setColor(1,self.color,self.color)
    love.graphics.draw(self.img, self.x, self.y, 0,1,1, self.width / 2, self.height / 2)
end

function spikes:remove()
    for i,instance in ipairs(activeSpikes) do
        if instance == self then
            Player:incrementCherries()
            print(Player.cherries)
            self.physics.body:destroy()
            table.remove(activeSpikes, i)
        end
    end
end

function spikes:update(dt)
    self.color = math.sin(love.timer.getTime() * 3)
end

function spikes:checkRemove()
    if self.toBeRemoved then
        self:remove()
    end
end


function spikes.updateAll(dt)
    for i,instance in ipairs(activeSpikes) do
        instance:update(dt)
    end
end

function spikes.drawAll()
    for i,instance in ipairs(activeSpikes) do
        instance:draw()
    end
end

function spikes.beginContact(a, b, collision)
    for i,instance in ipairs(activeSpikes) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                Player:takeDamage(instance.damage)
                return true
            end
        end
    end
end


return spikes