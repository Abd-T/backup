local Bubble = require("bubble")

local bird = {}
bird.__index = bird
local activebird = {}
local Player = require("player")

function bird.new(x, y)
    instance = setmetatable({}, bird)
    instance.x = x
    instance.y = y

    instance.r = 0
    
    instance.state = "walk"

    instance.damage = 1
    instance.color = 1
    instance.physics = {}
    instance.physics.body = love.physics.newBody(World, instance.x, instance.y, "dynamic")
    instance.physics.shape = love.physics.newRectangleShape(instance.width , instance.height )
    instance.physics.fixture = love.physics.newFixture(instance.physics.body, instance.physics.shape)
    instance.physics.body:setFixedRotation(true)
    instance.physics.body:setMass(25)
    instance.number = 0
    instance.Yoffset = 15
    instance.Xoffset = 25
    instance.bool = 0
    instance.speed = 100
    instance.xVel = instance.speed
    instance.yVel = 100
    instance.physics.body:setGravityScale(0)
    
    
    
    instance.animation = {timer = 0, rate = 0.1}
    instance.animation.walk = {total = 8, current = 1, img = bird.walkAnim}

    instance.animation.draw = instance.animation.walk.img[1]
   
    table.insert(activebird, instance)
end

function bird.loadAssets()

--"map/assests/bird/Walk/spr_birdWalk_strip10.png"
    bird.walkAnim = {}


    for i=1,8 do
        bird.walkAnim[i] = love.graphics.newImage("map/assests/bird/Walk/"..i..".png")
    end


    bird.width = bird.walkAnim[1]:getWidth()
    bird.height = bird.walkAnim[1]:getHeight()
end 

function bird:draw()
    local scaleX = -1

    if self.xVel < 0 then
        scaleX = 1
    end

    love.graphics.draw(self.animation.draw, self.x, self.y, 0,scaleX,1, self.width / 2 , self.height / 2)
end


function bird:animate(dt)
    self.animation.timer = self.animation.timer + dt
    if self.animation.timer > self.animation.rate then
        self.animation.timer = 0
        self:setNewFrame()
    end
end

function bird:setNewFrame()
    local anim = self.animation[self.state]
    if anim.current < anim.total then
        anim.current = anim.current + 1
    else    
        anim.current = 1
    end
    self.animation.draw = anim.img[anim.current]
end



function bird:update(dt)
    self:syncPhysics()
    self:animate(dt)
end 

function bird:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
    self.physics.body:setLinearVelocity(self.xVel, 0)
end

function bird:flipDirection()
    self.xVel = -self.xVel
end

function bird.updateAll(dt)
    for i,instance in ipairs(activebird) do
        instance:update(dt)
    end
end

function bird.drawAll()
    for i,instance in ipairs(activebird) do
        instance:draw()
    end
end

function bird.beginContact(a, b, collision)
    for i,instance in ipairs(activebird) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                Player:takeDamage(instance.damage)
            end
            instance:flipDirection()
        end
    end
end


return bird