--
--Vars--
--
local Scubadiver = require "scubadiver"
local Shield = require "shield"
entities = {}

gameover = false

score = 0
wasted = love.graphics.newImage("img/wasted.png")
ocean = love.graphics.newImage("img/ocean.jpg")
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
  love.graphics.draw(ocean, 0, -100*score, 0, width/ocean:getWidth(), 4*height/ocean:getHeight())
end

function love.draw()
  love.graphics.setColor(1, 1, 1, 1)
  printBG()
  love.graphics.setColor(1, 0, 0, 1)
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
  love.graphics.draw(wasted, width/2 - (wasted:getWidth()), height/2 - (wasted:getHeight()),0,2,2)
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
        ennemy.speed = param.speed + score/10
        ennemy.anglespeed = param.anglespeed
        ennemy.update = param.update
        ennemy.draw = param.draw
        ennemy.timer = 0
        ennemy.switch = param.switch
        ennemy.size = param.size
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

function newAnimation(image, width, height, duration)
    local animation = {}
    animation.spriteSheet = image;
    animation.quads = {};

    for y = 0, image:getHeight() - height, height do
        for x = 0, image:getWidth() - width, width do
            table.insert(animation.quads, love.graphics.newQuad(x, y, width, height, image:getDimensions()))
        end
    end

    animation.duration = duration or 1
    animation.currentTime = 0

    return animation
end
--------------------------------------------------------------------------------
function paramEnnemyGeneration()
  spawns =
  {
    fish =
    {
      start = 0,stop = 1000,
      frequency = 2,
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
        if touched(ennemy, diver, size) then
          --Perdu
          gameover = true
        end
      end,
      draw = function (entity)
        love.graphics.setColor(1,1,1)
        local fish = love.graphics.newImage("img/fish.png")
        love.graphics.draw(fish, entity.x, entity.y, math.rad(entity.angle), 1, 1)
        --love.graphics.polygon("fill", entity.x+30*math.cos(math.rad(entity.angle)), entity.y + 30*math.sin(math.rad(entity.angle)), entity.x+ 30*math.cos(math.rad(entity.angle+120)), entity.y+30*math.sin(math.rad(entity.angle+120)), entity.x+30*math.cos(math.rad(entity.angle-120)), entity.y+30*math.sin(math.rad(entity.angle-120)))
      end
    },
    shark =
    {
      start = 0,stop = 1000,
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
        love.graphics.setColor(1,1,1)
        local shark = love.graphics.newImage("img/shark.png")
        love.graphics.draw(shark, entity.x, entity.y, math.rad(entity.angle), 1, 1)      --  love.graphics.polygon("fill", entity.x+50*math.cos(math.rad(entity.angle)), entity.y + 50*math.sin(math.rad(entity.angle)), entity.x+ 50*math.cos(math.rad(entity.angle+120)), entity.y+50*math.sin(math.rad(entity.angle+120)), entity.x+50*math.cos(math.rad(entity.angle-120)), entity.y+50*math.sin(math.rad(entity.angle-120)))
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
    },

    globeFish =
    {
      start = 100,stop = 1000,
      frequency = 1,
      xmin = 0, xmax = width,
      ymin = height, ymax = height,
      anglemin=200, anglemax = 340,
      speed = 200, anglespeed = 1, switch = 1,size = 2,

      update = function (ennemy, dt)

        if ennemy.angle > 350 or ennemy.angle < 190 then
          ennemy.switch = ennemy.switch * -1
          ennemy.size = ennemy.size + ennemy.switch
        end

        ennemy.angle = ennemy.angle + ennemy.switch

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
        love.graphics.setColor(1,0.5,1)
        love.graphics.polygon("fill", entity.x+(entity.size*20)*math.cos(math.rad(entity.angle)), entity.y + (entity.size*20)*math.sin(math.rad(entity.angle) ), entity.x+ (entity.size*20)*math.cos(math.rad(entity.angle+120)), entity.y+(entity.size*20)*math.sin(math.rad(entity.angle+120)), entity.x+(entity.size*20)*math.cos(math.rad(entity.angle-120)), entity.y+(entity.size*20)*math.sin(math.rad(entity.angle-120)))
      end
    }
  }

end
