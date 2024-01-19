Furret = require 'furret'

local ultraButton_image = love.graphics.newImage('images/ultra.png')
local ultraButtonOn_image = love.graphics.newImage('images/ultra_on.png')
local explosion_image = love.graphics.newImage('images/nuclear.png')
local buttonOn_sound = love.audio.newSource('sfx/button_on.wav', 'static')
local buttonOff_sound = love.audio.newSource('sfx/button_off.wav', 'static')
local explosionCharge_sound = love.audio.newSource('sfx/furret_charge.wav', 'static')
local nuclearExplosion_sound = love.audio.newSource('sfx/nuclear.ogg', 'static')
nuclearExplosion_sound:setVolume(0.3)
local doomsdaySong_music = love.audio.newSource('sfx/accumula_town.mp3', 'stream')
local button = {}
button.image = ultraButton_image
button.radius = 80
button.x = love.graphics.getWidth() - 100
button.y = 120
button.offsetX = 0
button.offsetY = 0
button.scaleX = 0.5
button.scaleY = 0.5
button.vibrate = 10


local maxKills = 200
local killed = 0
local ultraMode = false
local furret = nil
-- off, setup, start, end
local ultraState = 'off'
local backgroundBrightness = 0
local objectVibration = 0
local showExplosion = false
local explosionPos = {}
explosionPos.x = love.graphics.getWidth()/2
explosionPos.y = love.graphics.getHeight()/2
explosionPos.offsetX, explosionPos.offsetY = 0, 0
explosionPos.vibrate = 160

local ultra = {}

function ultra.update(dt, boiManager, shooter)
  killed = killed + boiManager.getKilled()
  if killed > maxKills then killed = maxKills end
  
  if killed >= maxKills  then
    if distance(button.x, button.y, love.mouse.getX(), love.mouse.getY()) <= button.radius then
      button.scaleX, button.scaleY = 0.55, 0.55
    else
      button.scaleX, button.scaleY = 0.5, 0.5
    end
  end
  if ultraMode then
    button.image = ultraButtonOn_image
    boiManager.setShooterDisabled(true)
    shooter.setDisabled(true)
    button.offsetX, button.offsetY = vibratePosition(button.vibrate)
  else
    button.image = ultraButton_image
    boiManager.setShooterDisabled(false)
    shooter.setDisabled(false)
  end
  
  ------------- off state ---------------
  if furret then
    furret:update(dt)
    if furret.disabled then
      backgroundBrightness = backgroundBrightness + 0.01
      if ultraState == 'off' then
        ultraState = 'setup'
      end
    end
  end
  ------------ setup state --------------
  if ultraState == 'setup' then
    doomsdaySong_music:stop()
    explosionCharge_sound:play()
    
    boiManager.setSpawning(false)
    for i, boi in ipairs(boiManager.getBois()) do
      boi.disabled = true
    end
    ultraState = 'start'
  ------------ start state --------------
  elseif ultraState == 'start' then
    objectVibration = objectVibration + 6
    furret.vibrate = objectVibration
    for i, boi in ipairs(boiManager.getBois()) do
      boi.vibrate = objectVibration
    end
    if not explosionCharge_sound:isPlaying() then
      nuclearExplosion_sound:play()
      ultraState = 'end'
    end
  ------------  end  state --------------
  elseif ultraState == 'end' then
    for i, boi in ipairs(boiManager.getBois()) do
      boi.delete = true
    end
    furret = nil
    showExplosion = true
    if not nuclearExplosion_sound:isPlaying() then
      objectVibration = 0
      killed = 0
      boiManager:reset()
      showExplosion = false
      backgroundBrightness = 0
      ultraMode = false
      ultraState = 'off'
    end
  end
  
  if showExplosion then
    explosionPos.offsetX, explosionPos.offsetY = vibratePosition(explosionPos.vibrate)
  end
end

function ultra.draw(debugMode, boiManager)
  love.graphics.setColor(0.9, 1, 0.9)
  love.graphics.rectangle('fill', love.graphics.getWidth() - 220, 20, maxKills, 30)
  love.graphics.setColor(0.4, 1, 0.4)
  love.graphics.rectangle('fill', love.graphics.getWidth() - 220, 20, killed, 30)
  love.graphics.setColor(1, 1, 1)
  
  if killed >= maxKills then
    love.graphics.draw(button.image, button.x + button.offsetX, button.y + button.offsetY,
                       0, button.scaleX, button.scaleY,
                       button.image:getWidth()/2, button.image:getHeight()/2)
    if debugMode then
    love.graphics.circle('line', button.x, button.y, button.radius)
    end
  end
  
  if furret then
    furret:draw(debugMode)
  end
  
  love.graphics.setColor(1, 1, 1, backgroundBrightness)
  love.graphics.rectangle('fill', 0, 0, love.graphics.getWidth(), love.graphics.getHeight())
  love.graphics.setColor(1, 1, 1, 1)
  
  if showExplosion then
    love.graphics.draw(explosion_image,
                       explosionPos.x + explosionPos.offsetX, explosionPos.y + explosionPos.offsetY,
                       0, 1, 1, explosion_image:getWidth()/2, explosion_image:getHeight()/2)
  end
end

function ultra.mousepressed(x, y, buttonPressed, istouch, presses, boiManager, shooter)
  if buttonPressed == 1 then
    if ultraState == 'off' and killed == maxKills then
      if distance(x, y, button.x, button.y) <= button.radius then
        ultraMode = not ultraMode
        shooter.setUltra(ultraMode)
        
        if ultraMode then
          buttonOn_sound:clone():play()
        else
          buttonOff_sound:clone():play()
        end
      else
        if ultraMode then
          if not furret then
            shooter.setUltra(false)
            furret = Furret.new(x, y)
            doomsdaySong_music:play()
          end
        end
      end
    end
  end
end

return ultra