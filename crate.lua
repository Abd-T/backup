local crate = {}
crate.__index = crate
local activecrate = {}
local Bubble = require("bubble")
local Player = require("player")
stop = 0

function crate.new(x, y)
    instance = setmetatable({}, crate)
    instance.x = x
    instance.y = y
    instance.r = 0

    instance.img = love.graphics.newImage("map/assests/crate.png")
    instance.img1 = love.graphics.newImage("map/assests/crate.png")
    instance.img2 = love.graphics.newImage("map/assests/crate2.png")
    instance.width = instance.img1:getWidth() + 400
    instance.height = instance.img1:getHeight() + 580
    
    instance.damage = 1
    
    
    instance.catch = false
    instance.xVel = 0
    instance.yVel = 0
    instance.state = "dynamic"

    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, instance.state)
    instance.physics.shape = love.physics.newRectangleShape(instance.width * 0.03, instance.height * 0.03)
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.body:setMass(3)
    instance.physics.body:setGravityScale(0.5)
    instance.physics.body:setFixedRotation(true)
   
    table.insert(activecrate, instance)
end

function crate:draw()
    
    if Bubble.stoneBool and not Bubble.hoverMode then
        love.graphics.setColor(1,1,1)
        love.graphics.draw(self.img, self.x, self.y, self.r,0.1,0.1, (self.width - 400) / 2, self.height / 2 - 280)
    else
        love.graphics.setColor(1,1,1)
        love.graphics.draw(self.img1, self.x, self.y, self.r,0.1,0.1, (self.width - 400) / 2, self.height / 2 - 280)
    end
end

function crate:update(dt)
    self:syncPhysics()
    --self:disable()
    if self.catch and not Bubble.hoverMode then
        
        self.physics.body:setGravityScale(0)
        self.physics.body:setMass(200)
        self.physics.body:setLinearVelocity(Bubble.xVel + 0.00000001, Bubble.yVel + 0.00000001)
        if Bubble.stonePlayerBool then
            Player.physics.body:setLinearVelocity(Player.xVel + Bubble.xVel ,Player.yVel + Bubble.yVel )
        end
        
    elseif Bubble.hoverMode then
        self.catch = false 
        self.physics.body:setGravityScale(0.5)
        self.physics.body:setMass(3)
    end
    if self.y > MapHeight then
        self.physics.body:setPosition(80.50, 308.17)
    end
    if self.x > 1470 then
        self.catch = false
        Bubble.hoverMode = true
        self.physics.fixture:setSensor(true)
        if self.y > MapHeight - 20 then
            self.physics.fixture:setSensor(false)
        end
    end
    if Player.x > 60 and Player.x < 102 and Player.y > 370 and Player.y < 410 then
        self.physics.body:setPosition(80.50, 308.17)
    end
   
end

function crate:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
    self.r = self.physics.body:getAngle()
end

function crate:disable()
    if stop > 1 then
        Bubble.hoverMode = true
        stop = 0
    end
end


function crate.updateAll(dt)
    for i,instance in ipairs(activecrate) do
        instance:update(dt)
    end
end

function crate.drawAll()
    for i,instance in ipairs(activecrate) do
        instance:draw()
    end
end

function crate.beginContact(a, b, collision)
    for i,instance in ipairs(activecrate) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Bubble.physics.fixture or b == Bubble.physics.fixture then
                stop = stop + 1
                instance.catch = true 
                instance.img = instance.img2
                Bubble.hoverMode = false
                Bubble.bool = false
                Bubble.stoneBool = true
                Bubble.physics.fixture:setSensor(true)
            end
            if a == Player.physics.fixture or b == Player.physics.fixture then
                Bubble.stonePlayerBool = true
            end
        end 
    end
end

function crate.endContact(a, b, collision)
    for i,instance in ipairs(activecrate) do
        if a == instance.physics.fixture or b == instance.physics.fixture then 
            if a == Player.physics.fixture or b == Player.physics.fixture then
                Bubble.stonePlayerBool = false 
                
            end 
            if a == Bubble.physics.fixture or b == Bubble.physics.fixture then
                instance.catch = false
                Bubble.stoneBool = false
                instance.img = instance.img1  
                stop = stop + 1
            end
        end
    end
end


return crate