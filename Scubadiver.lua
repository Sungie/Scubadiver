local Scubadiver = {}
  function Scubadiver:new()
    local scubadiver = {}
    scubadiver.img = love.graphics.newImage("img/scubadiver.png")
    scubadiver.name = "diver"
    scubadiver.x = width/2
    scubadiver.y = 50
    scubadiver.width = 50
    scubadiver.height = 50


    function scubadiver:update(dt)
    end

    function scubadiver:draw()
      love.graphics.setColor(1,1,1)
      --love.graphics.rectangle("fill", self.x - (self.width/2), self.y - (self.height/2), self.width, self.height)
      love.graphics.draw(scubadiver.img, self.x - (self.width/2), self.y - (self.height/2), 0, 1.7, 1.7)
    end

    return scubadiver
  end

return Scubadiver
