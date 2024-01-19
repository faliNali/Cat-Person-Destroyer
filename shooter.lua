local shoot_image = love.graphics.newImage('images/shoot.png')
local defaultCrosshairs_image = love.graphics.newImage('images/crosshairs.png')
local ultraCrosshairs_image = love.graphics.newImage('images/ultra_crosshairs.png')
local sound = love.audio.newSource('sfx/shoot.wav', 'static')
local crosshairs_image = defaultCrosshairs_image

local shot = false
local vistime = 0.02
local vistimer = 0
local shotpos = {x = 0, y = 0}
local shotrotation = 0
local disabled = false
local ultraMode = false
local vibrate = 4
local shotOffset = {x = 0, y = 0}
local shooter = {}

function shooter.update(dt)
  if vistimer > 0 then
    vistimer = vistimer - dt
  else
    shot = false
  end
  
  if ultraMode then
    shotOffset.x, shotOffset.y = vibratePosition(vibrate)
    crosshairs_image = ultraCrosshairs_image
  else
    shotOffset.x, shotOffset.y = 0, 0
    crosshairs_image = defaultCrosshairs_image
  end
end

function shooter.draw()
  if shot then
    love.graphics.draw(shoot_image, shotpos.x, shotpos.y, shotrotation, 0.45, 0.45,
                       shoot_image:getWidth()/2, shoot_image:getHeight()/2)
  end
  love.graphics.draw(crosshairs_image, love.mouse.getX() + shotOffset.x, love.mouse.getY() + shotOffset.y,
                     0, 0.5, 0.5, crosshairs_image:getWidth()/2, crosshairs_image:getHeight()/2)
end

function shooter.mousepressed(x, y, button, number, istouch, presses)
  if button == 1 then
    if not disabled then
      sound:clone():play()
      shot = true
      shotrotation = math.random(0, math.pi)
      shotpos.x, shotpos.y = x, y
      vistimer = vistimer + vistime
    end
  end
end

function shooter.setDisabled(isDisabled) disabled = isDisabled end

function shooter.setUltra(isUltra) ultraMode = isUltra end

return shooter