
local Player = require("player")
local Camera = require("camera")


local Bubble = {}

function Bubble:load()
    self.x = Player.x + 40
    self.y = Player.y - 40
    self.radius = 14
    self.xVel = 0
    self.yVel = 0
    self.maxSpeed = 200
    self.width = 20
    self.height = 10
    self.projectileSpeed = 65
    self.maxProjectileSpeed = 500
    self.acceleration = 4000
    self.hoverMode = true
    
    self.shape = love.graphics.newImage("map/assests/hoverball.png")
    self.shape2 = love.graphics.newImage("map/assests/hoverball2.png")
    self.shape3 = love.graphics.newImage("map/assests/hoverball3.png")

    self.attackMode = false

    self.bool = false
    self.playerBool = false
    self.stoneBool = false
    self.stonePlayerBool = false

    self.physics = {}
    self.physics.body = love.physics.newBody(World, self.x, self.y, "dynamic")
    self.physics.body:setFixedRotation(false)
    self.physics.shape = love.physics.newCircleShape(self.radius)
    self.physics.fixture = love.physics.newFixture(self.physics.body, self.physics.shape)
    self.physics.fixture:setSensor(true)
    self.physics.body:setGravityScale(0)
    
    self.gravity = 10

    
end

function Bubble:update(dt)
    self:pushProjectile(dt)
    self:currentPlacement()
    self:getDirection()
    self.physics.body:setLinearVelocity(self.xVel, self.yVel)
    self.radius = self.physics.shape:getRadius()
    self:stickToPlayer(dt)
    self:stayInSight()
    self:attackModeSwitch()
    if not self.hoverMode then
        self:launch()
    end
    if Player.health.current == 2 then
        self.physics.body:setPosition(self.x, self.y)
    end
end

function Bubble:currentPlacement()
    self.x, self.y = self.physics.body:getPosition()
end

function Bubble:draw()
    if self.xVel < 150 and self.xVel > -150 and self.yVel < 150 and self.yVel > -150 then
        if not self.bool then  
            love.graphics.draw(self.shape, self.x, self.y, 0, 0.08, 0.08, 160, 160)
        else
            love.graphics.draw(self.shape3, self.x, self.y, 0, 0.08, 0.08, 160, 160)
        end
    else
        if not self.hoverMode then
            if self.stoneBool then
                love.graphics.setColor(1,1,1)
                love.graphics.draw(self.shape2, self.x, self.y, 0, 0.08, 0.08, 160, 160)
            else
                love.graphics.draw(self.shape2, self.x, self.y, 0, 0.08, 0.08, 160, 160)
            end
        else
            love.graphics.draw(self.shape, self.x, self.y, 0, 0.08, 0.08, 160, 160)
        end
    end
end

function Bubble:attackModeSwitch()
    if self.xVel < 150 and self.xVel > -150 and self.yVel < 150 and self.yVel > -150 and not self.hoverMode then
        self.attackMode = false
    else
        self.attackMode = true
    end
end

function Bubble:pushProjectile(dt)
    if self.xVel - self.projectileSpeed * dt > 0 then
        self.xVel = self.xVel - self.projectileSpeed * dt
    elseif self.xVel + self.projectileSpeed * dt < 0 then
        self.xVel = self.xVel + self.projectileSpeed * dt
    else
        self.xVel = 0
    end
    if self.yVel - self.projectileSpeed * dt > 0 then
        self.yVel = self.yVel - self.projectileSpeed * dt
    elseif self.yVel + self.projectileSpeed * dt < 0 then
        self.yVel = self.yVel + self.projectileSpeed * dt
    else
        self.yVel = 0
    end
end


function Bubble:launch()
    if not self.stonePlayerBool or self.stonePlayerBool then
        if love.keyboard.isDown("right") then
            if self.xVel < self.maxSpeed then
                if self.xVel + self.acceleration * 0.001 < self.maxSpeed then
                    self.xVel = self.xVel + self.acceleration * 0.001
                else
                    self.xVel = self.maxSpeed
                end
            end
        end
        if love.keyboard.isDown("left") then
            if self.xVel > -self.maxSpeed then
                if self.xVel - self.acceleration * 0.001 > -self.maxSpeed then
                self.xVel = self.xVel - self.acceleration * 0.001
                else
                    self.xVel = -self.maxSpeed
                end
            end
        end
        if love.keyboard.isDown("down") then
            if self.yVel < self.maxSpeed then
                if self.yVel + self.acceleration * 0.001 < self.maxSpeed then
                    self.yVel = self.yVel + self.acceleration * 0.001
                else
                    self.yVel = self.maxSpeed
                end
            end
        end
        if love.keyboard.isDown("up") then
            if self.yVel > -self.maxSpeed then
                if self.yVel - self.acceleration * 0.001 > -self.maxSpeed then
                self.yVel = self.yVel - self.acceleration * 0.001
                else
                    self.yVel = -self.maxSpeed
                end
            end
        end
    end
end


function Bubble:stickToPlayer(dt)
    if self.hoverMode then
        if (Player.x + 40) - self.x < -1 then
            if self.xVel > -actualX then
                if self.xVel + -actualX * 0.2 > -actualX then
                    self.xVel = self.xVel + -actualX * 0.08
                else
                    self.xVel = -actualX 
                end
            end
        elseif (Player.x + 40) - self.x > 1 then
            if self.xVel < actualX then
                if self.xVel + actualX * 0.2 < actualX then
                    self.xVel = self.xVel + actualX * 0.08
                else
                    self.xVel = actualX 
                end
            end
        
        end


        if (Player.y - 40) - self.y > 1 then   
            if self.yVel < actualY then
                if self.yVel + actualY * 0.2 < actualY then
                    self.yVel = self.yVel + actualY * 0.08
                else
                    self.yVel = actualY
                end
            end 
        elseif (Player.y - 40) - self.y < -1 then
            if self.yVel > -actualY then
                if self.yVel + actualY * 0.2 > -actualY then
                    self.yVel = self.yVel - actualY * 0.5
                else
                    self.yVel = -actualY
                end
            end 
        
        end
    end
end

function Bubble:getDirection()
    distanceX = Player.x - self.x 
    distanceY = Player.y - self.y

    squaredDistanceX = distanceX * distanceX
    squaredDistanceY = distanceY * distanceY

    squaredDistanceZ = squaredDistanceX + squaredDistanceY

    actualX = (squaredDistanceZ - squaredDistanceY) ^ 0.5
    actualY = (squaredDistanceZ - squaredDistanceX) ^ 0.5
end


function Bubble:beginContact(a, b, collision)
    
    local nx, ny = collision:getNormal()
    if a == self.physics.fixture or b == self.physics.fixture then           
        if self.hoverMode then
            self.bool = true
            return true
        elseif not self.hoverMode then
            if a ~= Player.physics.fixture and b ~= Player.physics.fixture then
                self.hoverMode = true
                self.physics.fixture:setSensor(true)
            end
        end

        if a == Player.physics.fixture or b == Player.physics.fixture then
            self.playerBool = true
            self.bool = false
            self.physics.fixture:setSensor(true)
            return true
        end

        for i,instance in ipairs(activeCherries) do
            if a == instance.physics.fixture or b == instance.physics.fixture then
                self.hoverMode = false
            end
        end
    end
end

function Bubble:endContact(a, b, collision)
    if a == self.physics.fixture or b == self.physics.fixture then  
        self.bool = false
        if a == Player.physics.fixture or b == Player.physics.fixture then
            self.playerBool = false
        end
    end
end

function Bubble:changeMode(key)
    if not self.bool then
        if not self.playerBool then
            if key == "f" then
                if not self.hoverMode then
                    self.physics.fixture:setSensor(true)
                    self.hoverMode = true
                elseif self.hoverMode then
                    self.physics.fixture:setSensor(false)
                    self.hoverMode = false
                end
            end
        end
    end
end

function Bubble:stayInSight()
    if self.x < Camera.x or self.y < Camera.y or self.x > (Camera.x + love.graphics.getWidth() / Camera.scale) or self.y > (Camera.y + love.graphics.getHeight() / Camera.scale) then
        self.hoverMode = true
        self.physics.fixture:setSensor(true)
    end
end

return Bubble