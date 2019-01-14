--
--Vars--
--
local Scubadiver = require "scubadiver"

entities = {
  -- {name="ennemy1", x=500, y=500, angle = 30, speed = 180, anglespeed=120},
  -- {name="ennemy2", x=900, y=500, angle = 90, speed = 180, anglespeed=120},
  -- {name="ennemy3", x=500, y=900, angle = 50, speed = 180, anglespeed=120},
  -- {name="ennemy4", x=750, y=500, angle = 300, speed = 180, anglespeed=120}
}

shieldHandled = false
gameover = false

score = 0
wasted = love.graphics.newImage("img/wasted.jpg")

--
--

function love.load()
  love.window.setFullscreen(true)
  width = love.graphics.getWidth()
  height = love.graphics.getHeight()
  shield = {name = "shield", x = width/2, y = height/2 , speed = 500, vel = nil, radius = 30}
  diver = Scubadiver:new()
  --diver = { name = diver.name , x = diver.x, y = diver.y, width = diver.w ,height = diver.h}
  table.insert(entities, shield)
  table.insert(entities, diver)
end



function love.draw()
  love.graphics.setColor(1/(score/10),1/(score/10),1/(score/10))
  love.graphics.rectangle("fill", 0,0, width, height)
  love.graphics.setColor(0, 0, 0)

    love.graphics.print(tostring(math.floor(score)), 100 , 100, 0,1,1)
    for i, entity in pairs(entities) do
      if entity.name == "diver" then
        diver:draw()
      elseif entity.name == "shield" then
        love.graphics.setColor(0.5,0.5,0.5)
        love.graphics.circle("fill", entity.x, entity.y, shield.radius)
      else
        love.graphics.setColor(0,0,0)
        love.graphics.polygon("fill", entity.x+30*math.cos(math.rad(entity.angle)), entity.y + 30*math.sin(math.rad(entity.angle)), entity.x+ 30*math.cos(math.rad(entity.angle+120)), entity.y+30*math.sin(math.rad(entity.angle+120)), entity.x+30*math.cos(math.rad(entity.angle-120)), entity.y+30*math.sin(math.rad(entity.angle-120)))
      end
    end
    if gameover then
      love.graphics.setColor(1, 1, 1, 1)
      love.graphics.draw(wasted, width/2 - (wasted.getWidth(wasted))/2, height/2 - (wasted.getHeight(wasted))/2,0,1,1)
    end
  end
function love.update(dt)
  if gameover then
  else
  --gameloop
    score = score + dt
    if shield.vel ~= nil then
      shield.x = shield.x + shield.vel.velx/math.sqrt(math.pow(shield.vel.velx,2)+math.pow(shield.vel.vely,2)) * shield.speed * dt
      shield.y = shield.y + shield.vel.vely/math.sqrt(math.pow(shield.vel.velx,2)+math.pow(shield.vel.vely,2)) * shield.speed * dt
    end
    if shield.x > width/2 - 10 and shield.x < width/2 +10
      and shield.y < height/2 - 90 and shield.y > height/2 - 110 then
      shield.vel = nil
    end
    if shieldHandled == false then
      if shield.vel ~= nil then
        shield.x = shield.x + shield.vel.velx/math.sqrt(math.pow(shield.vel.velx,2)+math.pow(shield.vel.vely,2)) * shield.speed * dt
        shield.y = shield.y + shield.vel.vely/math.sqrt(math.pow(shield.vel.velx,2)+math.pow(shield.vel.vely,2)) * shield.speed * dt
      end
    end
    for i, entity in pairs(entities) do
      if entity.name~="diver" and entity.name~="shield" then
        objectiveAngle = 180 + math.deg(math.atan2((entity.y-diver.y),(entity.x - diver.x)))
        if math.abs(entity.angle-objectiveAngle) < 180 then
          entity.angle =  (entity.angle + dt*entity.anglespeed*(entity.angle<objectiveAngle and 1 or -1))%360
        else
          entity.angle =  (entity.angle + dt*entity.anglespeed*(entity.angle<objectiveAngle and -1 or 1))%360
        end
        entity.x = entity.x+ entity.speed*math.cos(math.rad(entity.angle))*dt
        entity.y = entity.y+ entity.speed*math.sin(math.rad(entity.angle))*dt

        if touched(entity,shield) then
          table.remove(entities,i)
        end
        if touched(entity, diver) then
          --Perdu
          gameover = true
        end
      end
    end
    if math.random(0,100)>90 then
      local ennemy = {name="ennemy", x=math.random(0,width), y=math.random(height/2,height), angle = math.random(0,360), speed = 180, anglespeed=30}
      table.insert(entities,ennemy)
    end
  end
end

function touched(e1,e2)
  if math.sqrt((math.pow((e1.x - e2.x), 2)) + (math.pow((e1.y - e2.y), 2))) < 50 then
    return true
  end
  return false
end

function love.keypressed(key, scancode, isrepeat)
  if key == "escape" then
    love.event.quit()
  end
end

function love.mousepressed(x, y, button, isTouch)
  --Distance between {x,y} and center of the circle
  local dist = math.sqrt((math.pow((x - shield.x), 2)) + (math.pow((y - shield.y), 2)))
  if math.floor(dist) < shield.radius then
      shieldHandled = true
  end
end

function love.mousemoved(x, y, dx, dy)
  if shieldHandled == true then
    shield.x = x
    shield.y = y
  end
end

function love.mousereleased(x, y, button, isTouch)
  if shieldHandled then
    shield.vel = {velx = width/2 - shield.x, vely = height/2 - 100 - shield.y}
  end
  shieldHandled = false
end
