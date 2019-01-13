entities = {
  {name="ennemy1", x=10, y=10, angle = 0}
}

touched = false
shieldHandled = false

function love.load()

  love.window.setFullscreen(true)
  width = love.graphics.getWidth()
  height = love.graphics.getHeight()

  shield = {name="shield",x=width/2, y = height/2 - 100, speed=50, vel=nil, radius = 30}
  heart = {name="heart", x= width/2, y= 10},
  table.insert(entities, shield)
  table.insert(entities, heart)

end

function love.draw()
  love.graphics.setColor(1,1,1)
  love.graphics.rectangle("fill", 0,0, width, height)

  for i, entity in pairs(entities) do
    if entity.name == "heart" then
      love.graphics.setColor(1,0,0)
      love.graphics.rectangle("fill", entity.x, entity.y, 50, 50)
    elseif entity.name == "shield" then
      love.graphics.setColor(0.5,0.5,0.5)
      love.graphics.circle("fill", entity.x, entity.y, shield.radius)
    else
      love.graphics.setColor(0,0,0)
      love.graphics.polygon("fill", entity.x+math.cos(entity.angle), entity.y + math.sin(entity.angle), entity.x- math.cos(entity.angle+120), entity.y-math.sin(entity.angle+120), entity.x-math.cos(entity.angle-120), entity.y-math.sin(entity.angle-120))
    end
  end
end

function love.update(dt)

  if shield.vel ~= nil then
    shield.x = shield.x + shield.vel.x/math.sqrt(math.pow(shield.vel.x,2)+math.pow(shield.vel.y,2)) * shield.speed * dt
    shield.y = shield.y + shield.vel.y/math.sqrt(math.pow(shield.vel.x,2)+math.pow(shield.vel.y,2)) * shield.speed * dt
  end
  for i, entity in pairs(entities) do
    if entity.name~="heart" and entity.name~="shield" then
      entity.angle = entity.angle + 0.1
    end
  end
end

function love.keypressed(key, scancode, isrepeat)
  if key == "escape" then
    love.event.quit()
  end
end

function love.mousepressed(x, y, button, isTouch)
  --shield.vel = {x= x/20 - shield.x, y = y/20 - shield.y}

  --Distance between {x,y} and center of the circle
  dist = math.sqrt((math.pow((x - shield.x), 2)) + (math.pow((y - shield.y), 2)))
  if math.floor(dist) < shield.radius then
      touched = true
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
  touched = false
  shieldHandled = false
end
