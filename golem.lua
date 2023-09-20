local Bubble = require("bubble")

local golem = {}
golem.__index = golem
local activegolem = {}
local Player = require("player")

function golem.new(x, y)
    instance = setmetatable({}, golem)
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
    instance.speedMod = 1
    instance.rageCounter = 0
    instance.rageTrigger = 120
    instance.bool = true
    instance.physics.fixture:setSensor(false)
    instance.animation = {timer = 0, rate = 0.1}
    instance.animation.walk = {total = 4, current = 1, img = golem.walkAnim}
    instance.animation.jump = {total = 7, current = 1, img = golem.jumpAnim}
    instance.animation.death = {total = 9, current = 1, img = golem.deathAnim}
    instance.toBeRemoved = false
    instance.animation.draw = instance.animation.walk.img[1]
   
    table.insert(activegolem, instance)
end

function golem.loadAssets()

--"map/assests/golem/Walk/spr_golemWalk_strip10.png"
    golem.walkAnim = {}
    golem.jumpAnim = {}
    golem.deathAnim = {}

    for i=1,4 do
        golem.walkAnim[i] = love.graphics.newImage("map/assests/Golem/Walk/"..i..".png")
    end

    for i=1,7 do
        golem.jumpAnim[i] = love.graphics.newImage("map/assests/Golem/Jump/"..i..".png")
    end

    for i=1,9 do
        golem.deathAnim[i] = love.graphics.newImage("map/assests/Golem/Death/"..i..".png")
    end


    golem.width = golem.walkAnim[1]:getWidth() - 25
    golem.height = golem.walkAnim[1]:getHeight() / 2
end 

function golem:draw()
    local scaleX = 1

    if self.xVel < 0 then
        scaleX = -1
    end

    love.graphics.draw(self.animation.draw, self.x, self.y, 0,scaleX,1, (self.width + self.Xoffset) / 2 , self.height / 2 + 20 )
end

function golem:incremenctRage()
    self.rageCounter = self.rageCounter + 1
    if self.rageCounter > self.rageTrigger then
        self.state = "jump"
        self.speedMod = 2
        if self.animation.jump.current == 7 then
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

function golem:animate(dt)
    self.animation.timer = self.animation.timer + dt
    if self.animation.timer > self.animation.rate then
        self.animation.timer = 0
        self:setNewFrame()
    end
end

function golem:setNewFrame()
    local anim = self.animation[self.state]
    if anim.current < anim.total then
        anim.current = anim.current + 1
    else    
        anim.current = 1
    end
    self.animation.draw = anim.img[anim.current]
end

function golem:remove()
    for i,instance in ipairs(activegolem) do
        if instance == self then
            self.physics.body:destroy()
            table.remove(activegolem, i)
        end
    end
end

function golem:update(dt)
    self:syncPhysics()
    self:animate(dt)
    self:checkRemove()
    self.number = love.math.random( 0,9999 )
    if self.number % 2 == 0 and self.bool then
        self:incremenctRage()
    end
    if self.animation.death.current == 9 then
        self.toBeRemoved = true
    end
end 

function golem:checkRemove()
    if self.toBeRemoved then
        self:remove()
    end
end

function golem:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
    self.physics.body:setLinearVelocity(self.xVel * self.speedMod, self.yVel)
end

function golem:flipDirection()
    self.xVel = -self.xVel
end

function golem.updateAll(dt)
    for i,instance in ipairs(activegolem) do
        instance:update(dt)
    end
end

function golem.drawAll()
    for i,instance in ipairs(activegolem) do
        instance:draw()
    end
end

function golem.beginContact(a, b, collision)
    for i,instance in ipairs(activegolem) do
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
                    instance.physics.fixture:setSensor(true)
                    instance.physics.body:setGravityScale(0)
                    instance.physics.fixture:destroy()
                end
            end
            instance:flipDirection()
        end
    end
end


return golem