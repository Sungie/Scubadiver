--
--Vars--
--
local Scubadiver = require "scubadiver"
local Shield = require "shield"

entities = {}

gameover = false
currScreen = "title"
score = 0

title = love.graphics.newImage("img/title.png")
wasted = love.graphics.newImage("img/wasted.png")
ocean = love.graphics.newImage("img/ocean.jpg")
bulles = love.graphics.newImage("img/bulles.png")
btnPlay = love.graphics.newImage("img/btnPlay.png")

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

function love.draw()
  if currScreen == "title" then
    drawTitle()
  elseif currScreen == "play" then
    love.graphics.setColor(1, 1, 1, 1)
    drawBG()
    love.graphics.setColor(1, 0, 0, 1)
    love.graphics.print(tostring(math.floor(score)), 100 , 100, 0,1,1)
    for i, entity in pairs(entities) do
      if entity.draw  then
        --draw hitbox red circle
        if entity.name == "shield" then else love.graphics.setColor(1, 0, 0, 1) love.graphics.circle("fill", entity.x, entity.y, 25) end

          entity:draw()
      end
    end
    --drawBulles()
    if gameover then
      gameoverdraw()
    end
  end
end

function drawBulles()
  love.graphics.draw(bulles, width/2, height - 50, 0, 2, 2)
end
function gameoverdraw()
  love.graphics.setColor(1, 1, 1, 1)
  love.graphics.draw(wasted, width/2 - (wasted:getWidth()), height/2 - (wasted:getHeight()),0,2,2)
end
function drawTitle()
  love.graphics.setColor(1, 1, 1)
  love.graphics.draw(title, 0,0,0, width/title:getWidth(), height/title:getHeight())
  love.graphics.draw(btnPlay, width/2 - btnPlay:getWidth()/2 , 4*height/5 - btnPlay:getHeight()/2)
end
function drawBG()
  local bg = love.graphics.newQuad(4*width/5, 4*height/5, width, height, ocean:getWidth(), ocean:getHeight())
  love.graphics.draw(ocean, bg,1,1)
  love.graphics.draw(ocean, 0, -100*score, 0, width/ocean:getWidth(), 4*height/ocean:getHeight())
end

function love.update(dt)
  if currScreen == "title" then

  elseif currScreen == "play" then
    --gameover = false
    if not gameover then
    --gameloop
      score = score + dt
      for i, entity in pairs(entities) do
        if entity.update then entity:update(dt) end
        if entity.animation then
          entity.animation.currentTime = entity.animation.currentTime + dt
          if entity.animation.currentTime >= entity.animation.duration then
              entity.animation.currentTime = entity.animation.currentTime - entity.animation.duration
          end
        end
      end
      spawn()
    end
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
        ennemy.size = param.size and 1 or 25
        ennemy.img = param.img
        if param.animation then ennemy.animation = newAnimation(param.img, param.size, param.size, animation.time) end
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
  if currScreen == "play" then
    shield:mousepressed(x,y,button,isTouch)
  elseif currScreen == "title" then
    if x >= width/2 - btnPlay:getWidth()/2 and x < width/2 + btnPlay:getWidth()/2
      and y > 4*height/5 - btnPlay:getHeight()/2 and y < 4*height/5 + btnPlay:getHeight()/2 then
        currScreen = "play"
    end
  end
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
      frequency = 1,
      xmin = 0, xmax = width,
      ymin = height/2, ymax = height,
      anglemin=0, anglemax = 360,
      speed = 100, anglespeed = 20,img = love.graphics.newImage("img/fish.png"),
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
        if touched(ennemy, diver) then
          --Perdu
          gameover = true
        end
      end,
      draw = function (entity)
        love.graphics.setColor(1,1,1)
        love.graphics.draw(entity.img, entity.x, entity.y, math.rad(entity.angle), 2, 2, entity.img:getWidth()/2, entity.img:getHeight()/2)
        --love.graphics.polygon("fill", entity.x+30*math.cos(math.rad(entity.angle)), entity.y + 30*math.sin(math.rad(entity.angle)), entity.x+ 30*math.cos(math.rad(entity.angle+120)), entity.y+30*math.sin(math.rad(entity.angle+120)), entity.x+30*math.cos(math.rad(entity.angle-120)), entity.y+30*math.sin(math.rad(entity.angle-120)))
      end
    },
    shark =
    {
      start = 0,stop = 1000,
      frequency = 1,
      xmin = 0, xmax = width,
      ymin = 3*height/4, ymax = height,
      anglemin=0, anglemax = 360, size = 64,
      speed = 200, anglespeed = 30, img = love.graphics.newImage("img/sharkF.png"),
      animation = {time=1},
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
        local spriteNum = math.floor(entity.animation.currentTime / entity.animation.duration * #entity.animation.quads) + 1
        love.graphics.draw(entity.animation.spriteSheet, entity.animation.quads[spriteNum], entity.x , entity.y , math.rad(entity.angle), 2,2, entity.img:getWidth()/4, entity.img:getHeight()/2)
        --love.graphics.polygon("fill", entity.x+50*math.cos(math.rad(entity.angle)), entity.y + 50*math.sin(math.rad(entity.angle)), entity.x+ 50*math.cos(math.rad(entity.angle+120)), entity.y+50*math.sin(math.rad(entity.angle+120)), entity.x+50*math.cos(math.rad(entity.angle-120)), entity.y+50*math.sin(math.rad(entity.angle-120)))
      end
    },
    turtle =
    {
      start = 0,stop = 1000,
      frequency = 1,
      xmin = width, xmax = width,
      ymin = 32, ymax = height/3,
      anglemin=180, anglemax = 180, size = 32,
      speed = 200, anglespeed = 0,img = love.graphics.newImage("img/turtleF.png"),
      animation = {time = 2},
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
        --love.graphics.draw(entity.img, entity.x, entity.y, math.rad(entity.angle), 2, 2, entity.img:getWidth()/2, entity.img:getHeight()/2)
        local spriteNum = math.floor(entity.animation.currentTime / entity.animation.duration * #entity.animation.quads) + 1
        love.graphics.draw(entity.animation.spriteSheet, entity.animation.quads[spriteNum], entity.x, entity.y,  math.rad(entity.angle), 2,2, entity.img:getWidth()/4, entity.img:getHeight()/2)

        --love.graphics.polygon("fill", entity.x+50*math.cos(math.rad(entity.angle)), entity.y + 50*math.sin(math.rad(entity.angle)), entity.x+ 50*math.cos(math.rad(entity.angle+120)), entity.y+50*math.sin(math.rad(entity.angle+120)), entity.x+50*math.cos(math.rad(entity.angle-120)), entity.y+50*math.sin(math.rad(entity.angle-120)))

      end
    },
    meduse =
    {
      start = 0,stop = 1000,
      frequency = 1,
      xmin = 0, xmax = width,
      ymin = height, ymax = height, size = 32,
      anglemin=270, anglemax = 270,
      speed = 200, anglespeed = 0,img = love.graphics.newImage("img/meduseF.png"),
      animation = {time = 2},
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
        local spriteNum = math.floor(entity.animation.currentTime / entity.animation.duration * #entity.animation.quads) + 1
        love.graphics.draw(entity.animation.spriteSheet, entity.animation.quads[spriteNum], entity.x - (entity.img:getWidth()/2), entity.y - (entity.img:getHeight()/2), 0, 2,2)
        --love.graphics.polygon("fill", entity.x+20*math.cos(math.rad(entity.angle)), entity.y + 20*math.sin(math.rad(entity.angle)), entity.x+ 20*math.cos(math.rad(entity.angle+120)), entity.y+20*math.sin(math.rad(entity.angle+120)), entity.x+20*math.cos(math.rad(entity.angle-120)), entity.y+20*math.sin(math.rad(entity.angle-120)))
      end
    },

    globeFish =
    {
      start = 0,stop = 1000,
      frequency = 1,
      xmin = 0, xmax = width,
      ymin = height, ymax = height,
      anglemin=200, anglemax = 340, size = 32,
      speed = 200, anglespeed = 1, switch = 1,
      img = love.graphics.newImage("img/globefish.png"),
      animation = {time = 2},
      update = function (ennemy, dt)

        if ennemy.angle > 350 or ennemy.angle < 190 then
          ennemy.switch = ennemy.switch * -1
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
        love.graphics.setColor(1, 1, 1, 1)
        if entity.switch == 1 then
          love.graphics.draw(entity.animation.spriteSheet, entity.animation.quads[2],entity.x, entity.y, math.rad(entity.angle), 2,2, entity.animation.spriteSheet:getWidth()/2,16)--, entity.img.spriteSheet:getHeight()/2)
        else
          love.graphics.draw(entity.animation.spriteSheet, entity.animation.quads[1],entity.x, entity.y, math.rad(entity.angle), 1,1, entity.animation.spriteSheet:getWidth()/2,16)--, entity.img.spriteSheet:getHeight()/2)
        end
      end
    }
  }
end
