local Shield = {}

  function Shield:new()
    local shield = {}
    shield.name = "shield"
    shield.x = width/2
    shield.y = 500
    shield.vel = nil
    shield.radius = 30
    shield.speed = 500
    shield.handled = false


    function shield:update(dt)
      --Update shield
    end

    function shield:draw()
      love.graphics.setColor(0.5,0.5,0.5)
      love.graphics.circle("fill", self.x, self.y, self.radius)
    end

    function shield:mousepressed(x, y, button, isTouch)
      --Distance between {x,y} and center of the circle
      local dist = math.sqrt((math.pow((x - shield.x), 2)) + (math.pow((y - shield.y), 2)))
      if math.floor(dist) < shield.radius then
          shield.handled = true
      end
    end
    function shield:mousemoved(x, y, dx, dy)
      if shield.handled == true then
        shield.x = x
        shield.y = y
      end
    end
    function shield:mousereleased(x, y, button, isTouch)
      if shield.handled then
        shield.vel = {velx = width/2 - shield.x, vely = height/2 - 100 - shield.y}
      end
      shield.handled = false
    end

    return shield
  end

return Shield
