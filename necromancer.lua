local Bubble = require("bubble")

local necromancer = {}
necromancer.__index = necromancer
local activeNecromancer = {}
local Player = require("player")

function necromancer.new(x, y)
    instance = setmetatable({}, necromancer)
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
    instance.Xoffset = 66
    instance.bool = 0
    instance.speed = 100
    instance.xVel = instance.speed
    instance.yVel = 100
    instance.speedMod = 1
    instance.rageCounter = 0
    instance.rageTrigger = 120
    instance.bool = true
    instance.physics.fixture:setSensor(false)
    instance.animation = {timer = 0, rate = 0.1}
    instance.animation.walk = {total = 10, current = 1, img = necromancer.walkAnim}
    instance.animation.jump = {total = 10, current = 1, img = necromancer.jumpAnim}
    instance.animation.death = {total = 52, current = 1, img = necromancer.deathAnim}
    instance.toBeRemoved = false
    instance.animation.draw = instance.animation.walk.img[1]
    instance.scaleX = 1
    instance.Lside = true
    
    table.insert(activeNecromancer, instance)
end

function necromancer.loadAssets()
    necromancer.walkAnim = {}
    necromancer.jumpAnim = {}
    necromancer.deathAnim = {}

    for i=1,10 do
        necromancer.walkAnim[i] = love.graphics.newImage("map/assests/Necromancer/Walk/"..i..".png")
    end

    for i=1,10 do
        necromancer.jumpAnim[i] = love.graphics.newImage("map/assests/Necromancer/Jump/"..i..".png")
    end

    for i=1,52 do
        necromancer.deathAnim[i] = love.graphics.newImage("map/assests/Necromancer/Death/"..i..".png")
    end


    necromancer.width = necromancer.walkAnim[1]:getWidth() - 66
    necromancer.height = necromancer.walkAnim[1]:getHeight() / 2 
end 

function necromancer:draw()
    

    if self.Lside then
        self.scaleX = -1
    else
        self.scaleX = 1
    end

    love.graphics.draw(self.animation.draw, self.x, self.y, 0,self.scaleX,1, (self.width + self.Xoffset) / 2 , self.height / 2 + self.Yoffset )
end

function necromancer:changeSide()
    if self.xVel < 0 then
        self.Lside = true
    elseif self.xVel == 0 and self.Lside then
        self.Lside = true
    else
        self.Lside = false
    end
end

function necromancer:incremenctRage()
    self.rageCounter = self.rageCounter + 1
    if self.rageCounter > self.rageTrigger then
        self.state = "jump"
        self.speedMod = 2
        if self.animation.jump.current == 10 then
            self.bool = false
            self.animation.jump.current = 1
        end
    end
    if not self.bool then
        self.state = "walk"
        self.rageCounter = 0
        self.speedMod = 1
        self.bool = true
    end
end

function necromancer:animate(dt)
    self.animation.timer = self.animation.timer + dt
    if self.animation.timer > self.animation.rate then
        self.animation.timer = 0
        self:setNewFrame()
    end
end

function necromancer:setNewFrame()
    local anim = self.animation[self.state]
    if anim.current < anim.total then
        anim.current = anim.current + 1
    else    
        anim.current = 1
    end
    self.animation.draw = anim.img[anim.current]
end

function necromancer:remove()
    for i,instance in ipairs(activeNecromancer) do
        if instance == self then
            self.physics.body:destroy()
            table.remove(activeNecromancer, i)
        end
    end
end

function necromancer:update(dt)
    self:syncPhysics()
    self:animate(dt)
    self:checkRemove()
    self:changeSide()
    self.number = love.math.random( 0,9999 )
    if self.number % 2 == 0 and self.bool then
        self:incremenctRage()
    end
    if self.animation.death.current == 52 then
        self.toBeRemoved = true
    end
end 

function necromancer:checkRemove()
    if self.toBeRemoved then
        self:remove()
    end
end

function necromancer:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
    self.physics.body:setLinearVelocity(self.xVel * self.speedMod, self.yVel)
end

function necromancer:flipDirection()
    self.xVel = -self.xVel
    
end

function necromancer.updateAll(dt)
    for i,instance in ipairs(activeNecromancer) do
        instance:update(dt)
    end
end

function necromancer.drawAll()
    for i,instance in ipairs(activeNecromancer) do
        instance:draw()
    end
end

function necromancer.beginContact(a, b, collision)
    for i,instance in ipairs(activeNecromancer) do
        if a == instance.physics.fixture or b == instance.physics.fixture then
            if a == Player.physics.fixture or b == Player.physics.fixture then
                Player:takeDamage(instance.damage)
            end
            if a == Bubble.physics.fixture or b == Bubble.physics.fixture then
                if Bubble.attackMode then
                    instance.state = "death"
                    instance.bool = false
                    instance.xVel = 0
                    instance.yVel = 0
                    if instance.Lside then
                        instance.scaleX = -1
                    end
                    instance.physics.fixture:setSensor(true)
                    instance.physics.body:setGravityScale(0)
                    instance.physics.fixture:destroy()
                end
            end
            instance:flipDirection()
        end
    end
end


return necromancer