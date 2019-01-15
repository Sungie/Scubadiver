--
--Vars--
--
local Scubadiver = require "scubadiver"
local Shield = require "shield"
entities = {}

gameover = false

score = 0
wasted = love.graphics.newImage("img/wasted.jpg")

----
----

function love.load()
  love.window.setFullscreen(true)
  width = love.graphics.getWidth()
  height = love.graphics.getHeight()

  shield = Shield:new()
  diver = Scubadiver:new()
  table.insert(entities, shield)
  table.insert(entities, diver)
end

function printBG()
  love.graphics.setColor(1,1,1)
  love.graphics.rectangle("fill", 0,0, width, height)
  love.graphics.setColor(0, 0, 0)
end

function love.draw()
  printBG()
  love.graphics.print(tostring(math.floor(score)), 100 , 100, 0,1,1)

  for i, entity in pairs(entities) do
    if entity.draw  then
      entity:draw()
    else
      --draw ennemies
      love.graphics.setColor(0,0,0)
      love.graphics.polygon("fill", entity.x+30*math.cos(math.rad(entity.angle)), entity.y + 30*math.sin(math.rad(entity.angle)), entity.x+ 30*math.cos(math.rad(entity.angle+120)), entity.y+30*math.sin(math.rad(entity.angle+120)), entity.x+30*math.cos(math.rad(entity.angle-120)), entity.y+30*math.sin(math.rad(entity.angle-120)))
    end
  end
  if gameover then
    gameoverdraw()
  end
end

function gameoverdraw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(wasted, width/2 - (wasted:getWidth())/2, height/2 - (wasted:getHeight())/2,0,1,1)
end

function love.update(dt)
  if not gameover then
  --gameloop
    score = score + dt
    for i, entity in pairs(entities) do
      if entity.update then entity.update(dt) end
    end
    spawn()
  end
end

function spawn()
  if math.random(0,100)>99 then
    local ennemy = {}
    ennemy.name = "ennemy"
    ennemy.x = math.random(width-50*score,width)
    ennemy.y = math.random(height-50*score,height)
    ennemy.angle = math.random(0,360)
    ennemy.speed = 100+0.1*score
    ennemy.anglespeed = 20+0.001*score
    ennemy.timer = 0
    ennemy.track = true
    ennemy.rot = math.random()>0.5
    ennemy.update = function (dt)
      ennemy.timer = ennemy.timer + dt
      if ennemy.timer > 5 then
        ennemy.timer = 0
        ennemy.track = math.random()>0.5
      end
      if ennemy.track then
        objectiveAngle = 180 + math.deg(math.atan2((ennemy.y-diver.y),(ennemy.x - diver.x)))
        if math.abs(ennemy.angle-objectiveAngle) < 180 then
          ennemy.angle =  (ennemy.angle + dt*ennemy.anglespeed*(ennemy.angle<objectiveAngle and 1 or -1))%360
        else
          ennemy.angle =  (ennemy.angle + dt*ennemy.anglespeed*(ennemy.angle<objectiveAngle and -1 or 1))%360
        end
      else
        if ennemy.rot then
          ennemy.angle = (ennemy.angle + dt*ennemy.anglespeed) % 360
        else
          ennemy.angle = (ennemy.angle - dt*ennemy.anglespeed) % 360
        end
      end
      ennemy.x = ennemy.x+ ennemy.speed*math.cos(math.rad(ennemy.angle))*dt
      ennemy.y = ennemy.y+ ennemy.speed*math.sin(math.rad(ennemy.angle))*dt
      if touched(ennemy,shield) or ennemy.y < 0 then
        removeEntity(ennemy)
      end
      if touched(ennemy, diver) then
        --Perdu
        gameover = true
      end
    end
    table.insert(entities,ennemy)
  end
end

function removeEntity(targetEntity)
  for i, entity in pairs(entities) do
    if entity == targetEntity then
      table.remove(entities,i)
      return
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
  shield:mousepressed(x,y,button,isTouch)
end

function love.mousemoved(x, y, dx, dy)
  shield:mousemoved(x,y,dx,dy)
end

function love.mousereleased(x, y, button, isTouch)
  shield:mousereleased(x,y,button,isTouch)
end
