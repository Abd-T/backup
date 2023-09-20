local game = require("menu")

local Player = {}


function Player:load()
    self.x = 200
    self.y = 535
    self.startX = self.x
    self.startY = self.y
    self.width = 18
    self.height = 23
    self.xVel = 0
    self.yVel = 0
    self.maxSpeed = 150
    self.acceleration = 3000
    self.friction = 3500
    self.gravity = 1500
    self.cherries = 0

    self.alive = true

    self.physics = {}
    self.physics.body = love.physics.newBody(World, self.x, self.y, "dynamic")
    self.physics.body:setFixedRotation(true)
    self.physics.shape = love.physics.newRectangleShape(self.width, self.height)
    self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)

    self.graceTime = 0
    self.graceDuration = 0.1
    
    self.direction = "right"
    self.state = "idle"
    self.health = {current = 9, max = 9}


    self.color = {}
    self.color.red = 1
    self.color.green = 1
    self.color.blue = 1
    self.color.speed = 3

    self:loadAssets()

    self.grounded = false
    self.jumpAmount = -370
    self.hasDoubleJump = true
    self.physics.body:setGravityScale(0)
end

function Player:update(dt)
    self:unTint(dt)
    self:setState()
    self:animate(dt)
    self:syncPhysics()
    self:move(dt)
    self:applyGravity(dt)
    self:decreaseGraceTime(dt)
    self:setDirection()
    self:respawn()
end

function Player:setState()
    if not self.grounded then
        self.state = "jump"
    elseif self.xVel == 0 then
        self.state = "idle"
    else
        self.state = "run"
    end
end 

function Player:animate(dt)
    self.animation.timer = self.animation.timer + dt
    if self.animation.timer > self.animation.rate then
        self.animation.timer = 0
        self:setNewFrame()
    end
end

function Player:setNewFrame()
    local anim = self.animation[self.state]
    if anim.current < anim.total then
        anim.current = anim.current + 1
    else    
        anim.current = 1
    end
    self.animation.draw = anim.img[anim.current]
end

function Player:takeDamage(amount)
    self:tintRed()
    if self.health.current - amount > 0 then
        self.health.current = self.health.current - amount
    else
        self.health.current = 0
        self:die()
    end
    
end

function Player:tintRed()
    self.color.green = 0
    self.color.blue = 0

end

function Player:unTint(dt)
    self.color.red = math.min(self.color.red + self.color.speed * dt, 1)
    self.color.green = math.min(self.color.green + self.color.speed * dt, 1)
    self.color.blue = math.min(self.color.blue + self.color.speed * dt, 1)

end

function Player:die()
    print("you died")
    self.alive = false
end

function Player:respawn()
    if not self.alive then
        game.state.death = true
        game.state.menu = true
        
        self.physics.body:setPosition(self.startX, self.startY)
        self.health.current = self.health.max
        self.alive = true
    end
end

function Player:applyGravity(dt)
    if self.grounded == false then
        self.yVel = self.yVel + self.gravity * dt
    end
end

function Player:syncPhysics()
    self.x, self.y = self.physics.body:getPosition()
    self.physics.body:setLinearVelocity(self.xVel, self.yVel)
end

function Player:move(dt)
    if love.keyboard.isDown("d") then
        if self.xVel < self.maxSpeed then
            if self.xVel + self.acceleration * dt < self.maxSpeed then
                self.xVel = self.xVel + self.acceleration * dt
            else
                self.xVel = self.maxSpeed
            end
        end
    elseif love.keyboard.isDown("a") then
        if self.xVel > -self.maxSpeed then
            if self.xVel - self.acceleration * dt > -self.maxSpeed then
            self.xVel = self.xVel - self.acceleration * dt
            else
                self.xVel = -self.maxSpeed
            end
        end
    else
        self:applyFriction(dt)
    end
end

function Player:applyFriction(dt)
    if self.xVel > 0 then
        if self.xVel - self.friction * dt > 0 then
            self.xVel = self.xVel - self.friction * dt
        else
            self.xVel = 0
        end
    elseif self.xVel < 0 then
        if self.xVel + self.friction * dt < 0 then
            self.xVel = self.xVel + self.friction * dt
        else
            self.xVel = 0
        end
    end 

end

function Player:loadAssets()
    self.animation = {timer = 0, rate = 0.1}
    self.animation.run = {total = 8, current = 1, img = {}}
    for i=1, self.animation.run.total do 
        self.animation.run.img[i] = love.graphics.newImage("map/assests/ninja/run/"..i..".png")
    end

    self.animation.idle = {total = 5, current = 1, img = {}}
    for i=1, self.animation.idle.total do 
        self.animation.idle.img[i] = love.graphics.newImage("map/assests/ninja/idle/"..i..".png")
    end

    self.animation.jump = {total = 3, current = 1, img = {}}
    for i=1, self.animation.jump.total do 
        self.animation.jump.img[i] = love.graphics.newImage("map/assests/ninja/jump/"..i..".png")
    end

    self.animation.draw = self.animation.run.img[1]
    self.animation.width = self.animation.draw:getWidth() 
    self.animation.height = self.animation.draw:getHeight()
end

function Player:setDirection()
    if self.xVel < 0 then
        self.direction = "left"
    elseif self.xVel > 0 then
        self.direction = "right"
    end
end

function Player:decreaseGraceTime(dt)
    if not self.grounded then
        self.graceTime = self.graceTime - dt
    end
end

function Player:beginContact(a, b, collision)
    local nx, ny = collision:getNormal()
    if self.grounded == true then return end
    if a == self.physics.fixture then
        if ny > 0 then
            self:land(collision)
        elseif ny < 0 then
            self.yVel = 0
        end
    elseif b == self.physics.fixture then
        if ny < 0 then
            self:land(collision)
        elseif ny > 0 then
            self.yVel = 0
        end
    end
end

function Player:endContact(a, b, collision)
    if a == self.physics.fixture or b == self.physics.fixture then
        if self.currentGroundCollision == collision then
            self.grounded = false
        end
    end
end

function Player:land(collision)
    self.currentGroundCollision = collision
    self.yVel = 0
    self.grounded = true
    self.hasDoubleJump = true
    self.graceTime = self.graceDuration
end

function Player:jump(key)
    if (key == "w") then
        if self.grounded or self.graceTime > 0 then
            self.yVel = self.jumpAmount
            self.grounded = false
            self.graceTime = 0
        elseif self.hasDoubleJump then
            self.hasDoubleJump = false
            self.yVel = self.jumpAmount * 0.8
        end
    end
end

function Player:draw()
    local scaleX = 0.35
    if self.direction == "left" then
        scaleX = -0.35
    end 
    love.graphics.setColor(self.color.red,self.color.green,self.color.blue)
    love.graphics.draw(self.animation.draw, self.x, self.y, 0, scaleX, 0.35, self.animation.width / 2, self.animation.height / 2)
    love.graphics.setColor(1,1,1,1)
end

function Player:incrementCherries()
    self.cherries = self.cherries + 1
end

return Player