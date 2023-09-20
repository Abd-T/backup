local game = {}



function game:load()
    self.state = {}
    self.state.menu = true
    self.state.running = false
    self.state.death = false

    self.x = 0

    self.loop = 512
    
    self.cherry = love.graphics.newImage("map/assests/cherry.png")
    

end

function game:update(dt)
    if self.x == self.loop then
        self.x = 0
    end
    self.x = self.x + 1
    self.scaleX = math.sin(love.timer.getTime() * 2) * 0.7
end

return game