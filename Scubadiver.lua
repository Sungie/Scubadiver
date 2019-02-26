local Scubadiver = {}
  function Scubadiver:new()
    local scubadiver = {}
    scubadiver.img = love.graphics.newImage("img/scubadiver.png")
    scubadiver.name = "diver"
    scubadiver.x = width/2
    scubadiver.y = 50
    scubadiver.width = 100
    scubadiver.height = 100
    scubadiver.size = scubadiver.img:getHeight() - 18
    scubadiver.head = {x = scubadiver.x,y = scubadiver.y + 35, size = 15, draw = function() end}

    animation = newAnimation(scubadiver.img, 32, 40, 2)


    function scubadiver:update(dt)
      animation.currentTime = animation.currentTime + dt
      if animation.currentTime >= animation.duration then
          animation.currentTime = animation.currentTime - animation.duration
      end
    end

    function scubadiver:draw()
      love.graphics.setColor(1,1,1)
      --Hitbox
      --love.graphics.rectangle("fill", self.x - (self.width/2), self.y - (self.height/2), self.width, self.height)
      --love.graphics.draw(scubadiver.img, self.x - (self.width/2), self.y - (self.height/2), 0, 2, 2, 0 ,0)
      local spriteNum = math.floor(animation.currentTime / animation.duration * #animation.quads) + 1
      love.graphics.draw(animation.spriteSheet, animation.quads[spriteNum],self.x - (self.width/2), self.y - (self.height/2) - 10, 0, 3,3)
    end


    return scubadiver
  end

return Scubadiver
