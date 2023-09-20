love.graphics.setDefaultFilter("nearest", "nearest")

local love = require("love")

local STI = require("sti")

local aBubble = require("bubble")

local Player = require("player")

local Bubble = require("bubble")

local cherry = require("collectable")

local Camera = require("camera")

local game = require("menu")

local GUI = require("GUI")

local spikes = require("spikes")

local necromancer = require("necromancer")

local golem = require("golem")

local bird = require("bird")

local crate = require("crate")

math.randomseed(os.time())


function love.load()
    game:load()
    mainFont = love.graphics.newFont("map/assests/Windsong.ttf", 150)
    menu = STI("map/1.lua", {"box2d"})
    love.mouse.setVisible(false)
    love.window.setFullscreen(true, "desktop")
    Map = STI("map/3.lua", {"box2d"})
    World = love.physics.newWorld( 0, 2000)
    World:setCallbacks(beginContact, endContact)
    Map:box2d_init(World)
    Map.layers.solid.visible = false
    Map.layers.entity.visible = false
    Player:load()
    necromancer.loadAssets()
    golem.loadAssets()
    bird.loadAssets()
    MapWidth = Map.layers.ground.width * 16
    MapHeight = Map.layers.ground.height * 16
    Bubble:load()
    GUI:load()
    spawnEntities()

    done = false
    
    body = love.physics.newBody(World, 3000, 400, "static")
    shape = love.physics.newRectangleShape(210, 30)
    fixture = love.physics.newFixture(body, shape)
    body:setGravityScale(0)
end


function love.update(dt)
    if not game.state.menu then
        love.graphics.setColor(1,1,1,1)
        World:update(dt)
        Player:update(dt)
        cherry.updateAll(dt)
        spikes.updateAll(dt)
        necromancer.updateAll(dt)
        golem.updateAll(dt)
        bird.updateAll(dt)
        crate.updateAll(dt)
        Bubble:update(dt)
        Camera:setPosition(Player.x, Player.y)
        if Player.y > MapHeight then
            Player.physics.body:setPosition(Player.startX, Player.startY)
            Player:takeDamage(1)
        end
        if Player.x > 1645 and Player.x < 1690 and Player.y > 520 and Player.y < 600 then
            Player.startX = 1664
            Player.starty = 555
            
        elseif Player.x > 2006 and Player.x < 2050 and Player.y > 580 then
            Player.startX = 200
            Player.starty = 535
            Player.physics.body:setPosition(Player.startX, Player.starty)
        end
        if Player.cherries == 60 then
            body:setPosition(2210, 400)
        end
       
    end
    game:update(dt)
    
end

function love.draw()
    if not game.state.menu then
        Map:draw(-Camera.x, -Camera.y, Camera.scale, Camera.scale)
        Camera:apply()
        Player:draw()
        love.graphics.setColor(1,1,1)
        love.graphics.draw(love.graphics.newImage("map/assests/crate.png"), 73, 390, 0,0.06,0.06)
        love.graphics.rectangle( "fill", 2409, 390, 50 / 2, 50 / 2 )
        necromancer.drawAll()
        golem.drawAll()
        bird.drawAll()
        Bubble:draw()
        cherry.drawAll()
        spikes.drawAll()
        crate.drawAll()
        GUI:draw()
        Camera:clear()

        if done then
            love.graphics.setColor(1,0,0)
            love.graphics.print( "you did great", mainFont, 360, 300, 0, 1, 1, 0, 0, 0)
        end
        
    else
        if not game.state.death then
            love.graphics.setColor(1,1,1)
            menu:draw(-game.x, 0, 3, 3)
            love.graphics.draw(game.cherry, 300, 350, -game.scaleX, -0.3, 0.3)
            love.graphics.draw(game.cherry, 1240, 350, game.scaleX, 0.3, 0.3)
            love.graphics.setColor(1,1,1)
            love.graphics.print( "Press Space to start", mainFont, 360, 300, 0, 1, 1, 0, 0, 0)
            love.graphics.setColor(1,0,0)
            love.graphics.print( "Press F  to enter/exit hovermode,", mainFont, 120, 500, 0, 1, 1, 0, 0, 0)
            love.graphics.setColor(1,0,0)
            love.graphics.print( "controll sphere with arrowkeys", mainFont, 200, 630, 0, 1, 1, 0, 0, 0)
        else
            love.graphics.setColor(1,1,1)
            menu:draw(-game.x, 0, 3, 3)
          
            love.graphics.setColor(1,0,0)
            love.graphics.print( "You Lost", mainFont, 620, 120, 0, 1, 1, 0, 0, 0)
            love.graphics.setColor(1,0,0)
            love.graphics.print( "Press Space to be resurrected", mainFont, 220, 300, 0, 1, 1, 0, 0, 0)
            
        end
    end

   
end

function love.keypressed(key)
    Player:jump(key)
    Bubble:changeMode(key)

    if key == "space" then
        game.state.menu = false
    end
    
end

function beginContact(a, b, collision)
    if cherry.beginContact(a, b, collision) then return end
    if Bubble:beginContact(a, b, collision) then return end
    if spikes.beginContact(a, b, collision) then return end
    necromancer.beginContact(a, b, collision)
    golem.beginContact(a, b, collision)
    bird.beginContact(a, b, collision)
    Player:beginContact(a, b, collision)
    Bubble:beginContact(a, b, collision)
    crate.beginContact(a, b, collision)
    if a == fixture or b == fixture then 
        if a == Player.physics.fixture or b == Player.physics.fixture then
            done = true
        end 
    end
    

end

function endContact(a, b, collision)
    Player:endContact(a, b, collision)
    Bubble:endContact(a, b, collision)
    crate.endContact(a, b, collision)
end

function spawnEntities()
    for i,v in ipairs(Map.layers.entity.objects) do
        if v.type == "spikes" then
            spikes.new(v.x + v.width / 2, v.y + v.height / 2)
        elseif v.type == "cherry" then
            cherry.new(v.x + v.width / 2, v.y + v.height / 2)
        elseif v.type == "necromancer" then
            necromancer.new(v.x + v.width / 2, v.y + v.height / 2)
        elseif v.type == "golem" then
            golem.new(v.x + v.width / 2, v.y + v.height / 2)
        elseif v.type == "crate" then
            crate.new(v.x + v.width / 2, v.y + v.height / 2)
        elseif v.type == "bird" then
            bird.new(v.x + v.width / 2, v.y + v.height / 2)
        end
    end
end