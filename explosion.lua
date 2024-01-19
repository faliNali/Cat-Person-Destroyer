local anim8 = require 'anim8'
local Explosion = {}
Explosion.__index = Explosion
 
local image = love.graphics.newImage('images/explosion.png')
local frameSize = {x = 200, y = 300}
local grid = anim8.newGrid(frameSize.x, frameSize.y, image:getWidth(), image:getHeight())
local sounds = {
  love.audio.newSource('sfx/explosion1.wav', 'static'),
  love.audio.newSource('sfx/explosion2.wav', 'static'),
  love.audio.newSource('sfx/explosion3.wav', 'static'),
  love.audio.newSource('sfx/explosion4.wav', 'static')}

function Explosion.new(x, y)
  local expl = {}
  setmetatable(expl, Explosion)
  
  expl.animation = anim8.newAnimation(grid('1-17',1), 0.04, 'pauseAtStart')
  expl.x = x
  expl.y = y
  expl.delete = false
  local sound = sounds[math.random(1, #sounds)]:clone()
  sound:play()
  
  return expl
end

function Explosion:update(dt)
  self.animation:update(dt)
  if self.animation.status == 'paused' then
    self.delete = true
  end
end

function Explosion:draw()
  self.animation:draw(image, self.x, self.y, 0, 1, 1, frameSize.x/2, frameSize.y/2)
end

return Explosion