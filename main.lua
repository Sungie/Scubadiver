--
--Vars--
--
local Scubadiver = require "scubadiver"
local Shield = require "shield"
entities = {}

gameover = false

score = 190
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
  paramEnnemyGeneration()
end

function printBG()
  local x = 18
  for i = 0, x do
  --  love.graphics.setColor(1/i,1/i,1/i)
    love.graphics.setColor(1,1,1)

    love.graphics.rectangle("fill", 0,(-(((score)%x)-i)*height), width, height)
  end
  -- love.graphics.setColor(0,1,0.5)
  -- love.graphics.rectangle("fill", 0,0, width, height)
  -- love.graphics.rectangle("fill", 0,((((score)%3))*height), width, height)
  -- love.graphics.setColor(1,0.5,0)
  -- love.graphics.rectangle("fill", 0,((((score)%3)-1)*height), width, height)
  -- love.graphics.setColor(0.5,0,1)
  -- love.graphics.rectangle("fill", 0,((((score)%3)-2)*height), width, height)
end

function love.draw()
  printBG()
  love.graphics.print(tostring(math.floor(score)), 100 , 100, 0,1,1)
  for i, entity in pairs(entities) do
    if entity.draw  then
      entity:draw()
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
      if entity.update then entity:update(dt) end
    end
    spawn()
  end
end

function spawn()
  for p, param in pairs(spawns) do
    if score > param.start and score < param.stop then
      if math.random(0,100)>100-param.frequency then
        local ennemy = {}
        ennemy.x = math.random(param.xmin,param.xmax)
        ennemy.y = math.random(param.ymin,param.ymax)
        ennemy.angle = math.random(param.anglemin,param.anglemax)
        ennemy.speed = param.speed
        ennemy.anglespeed = param.anglespeed
        ennemy.update = param.update
        ennemy.draw = param.draw
        ennemy.timer = 0
        table.insert(entities,ennemy)
      end
    end
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

function touched(e1,e2,size)
  if size == nil then
    size = 50
  end
    if math.sqrt((math.pow((e1.x - e2.x), 2)) + (math.pow((e1.y - e2.y), 2))) < size then
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

function paramEnnemyGeneration()
  spawns =
  {
    fish =
    {
      start = 0,stop = 1,
      frequency = 3,
      xmin = 0, xmax = width,
      ymin = height/2, ymax = height,
      anglemin=0, anglemax = 360,
      speed = 100, anglespeed = 20,
      update = function (ennemy, dt)
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
          if ennemy.rot == nil then ennemy.rot = math.random()>0.5 end
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
        if touched(ennemy, diver, ennemy.size) then
          --Perdu
          gameover = true
        end
      end,
      draw = function (entity)
        love.graphics.setColor(0,0,0)
        love.graphics.polygon("fill", entity.x+30*math.cos(math.rad(entity.angle)), entity.y + 30*math.sin(math.rad(entity.angle)), entity.x+ 30*math.cos(math.rad(entity.angle+120)), entity.y+30*math.sin(math.rad(entity.angle+120)), entity.x+30*math.cos(math.rad(entity.angle-120)), entity.y+30*math.sin(math.rad(entity.angle-120)))
      end
    },
    shark =
    {
      start = 200,stop = 1000,
      frequency = 1,
      xmin = 0, xmax = width,
      ymin = 3*height/4, ymax = height,
      anglemin=0, anglemax = 360,
      speed = 200, anglespeed = 30,
      update = function (ennemy, dt)
        ennemy.timer = ennemy.timer + dt
        if ennemy.timer > 5 then
          ennemy.timer = 0
          ennemy.track = true
        end
        if ennemy.track then
          objectiveAngle = 180 + math.deg(math.atan2((ennemy.y-diver.y),(ennemy.x - diver.x)))
          if math.abs(ennemy.angle-objectiveAngle) < 180 then
            ennemy.angle =  (ennemy.angle + dt*ennemy.anglespeed*(ennemy.angle<objectiveAngle and 1 or -1))%360
          else
            ennemy.angle =  (ennemy.angle + dt*ennemy.anglespeed*(ennemy.angle<objectiveAngle and -1 or 1))%360
          end
        else
          if ennemy.rot == nil then ennemy.rot = math.random()>0.5 end
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
      end,
      draw = function (entity)
        love.graphics.setColor(0.3,0,0)
        love.graphics.polygon("fill", entity.x+50*math.cos(math.rad(entity.angle)), entity.y + 50*math.sin(math.rad(entity.angle)), entity.x+ 50*math.cos(math.rad(entity.angle+120)), entity.y+50*math.sin(math.rad(entity.angle+120)), entity.x+50*math.cos(math.rad(entity.angle-120)), entity.y+50*math.sin(math.rad(entity.angle-120)))
      end
    },
    turtle =
    {
      start = 0,stop = 1000,
      frequency = 1,
      xmin = width, xmax = width,
      ymin = 0, ymax = height,
      anglemin=180, anglemax = 180,
      speed = 200, anglespeed = 0,
      update = function (ennemy, dt)
        ennemy.timer = ennemy.timer + dt
        if ennemy.timer > 5 then
          ennemy.timer = 0
          ennemy.track = true
        end
        if ennemy.track then
          objectiveAngle = 180 + math.deg(math.atan2((ennemy.y-diver.y),(ennemy.x - diver.x)))
          if math.abs(ennemy.angle-objectiveAngle) < 180 then
            ennemy.angle =  (ennemy.angle + dt*ennemy.anglespeed*(ennemy.angle<objectiveAngle and 1 or -1))%360
          else
            ennemy.angle =  (ennemy.angle + dt*ennemy.anglespeed*(ennemy.angle<objectiveAngle and -1 or 1))%360
          end
        else
          if ennemy.rot == nil then ennemy.rot = math.random()>0.5 end
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
        if touched(ennemy, diver, 40) then
          --Perdu
          gameover = true
        end
      end,
      draw = function (entity)
        love.graphics.setColor(0,1,0)
        love.graphics.polygon("fill", entity.x+20*math.cos(math.rad(entity.angle)), entity.y + 20*math.sin(math.rad(entity.angle)), entity.x+ 20*math.cos(math.rad(entity.angle+120)), entity.y+20*math.sin(math.rad(entity.angle+120)), entity.x+20*math.cos(math.rad(entity.angle-120)), entity.y+20*math.sin(math.rad(entity.angle-120)))
      end
    },
    meduse =
    {
      start = 0,stop = 1000,
      frequency = 1,
      xmin = 0, xmax = width,
      ymin = height, ymax = height,
      anglemin=270, anglemax = 270,
      speed = 200, anglespeed = 0,
      update = function (ennemy, dt)
        ennemy.timer = ennemy.timer + dt
        if ennemy.timer > 5 then
          ennemy.timer = 0
          ennemy.track = true
        end
        if ennemy.track then
          objectiveAngle = 180 + math.deg(math.atan2((ennemy.y-diver.y),(ennemy.x - diver.x)))
          if math.abs(ennemy.angle-objectiveAngle) < 180 then
            ennemy.angle =  (ennemy.angle + dt*ennemy.anglespeed*(ennemy.angle<objectiveAngle and 1 or -1))%360
          else
            ennemy.angle =  (ennemy.angle + dt*ennemy.anglespeed*(ennemy.angle<objectiveAngle and -1 or 1))%360
          end
        else
          if ennemy.rot == nil then ennemy.rot = math.random()>0.5 end
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
      end,
      draw = function (entity)
        love.graphics.setColor(0,0.5,1)
        love.graphics.polygon("fill", entity.x+20*math.cos(math.rad(entity.angle)), entity.y + 20*math.sin(math.rad(entity.angle)), entity.x+ 20*math.cos(math.rad(entity.angle+120)), entity.y+20*math.sin(math.rad(entity.angle+120)), entity.x+20*math.cos(math.rad(entity.angle-120)), entity.y+20*math.sin(math.rad(entity.angle-120)))
      end
    }
  }

end
