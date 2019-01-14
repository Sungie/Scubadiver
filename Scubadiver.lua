local Scubadiver = {}
  function Scubadiver:new()
    local scubadiver = {}
    scubadiver.name = "diver"
    scubadiver.x = width/2
    scubadiver.y = 50
    scubadiver.width = 50
    scubadiver.height = 50


    function scubadiver:update(dt)
    end

    function scubadiver:draw()
      love.graphics.setColor(1,0,0)
      love.graphics.rectangle("fill", self.x - (self.width/2), self.y - (self.height/2), self.width, self.height)
    end

    return scubadiver
  end

return Scubadiver
