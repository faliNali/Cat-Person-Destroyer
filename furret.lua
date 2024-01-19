local anim8 = require 'anim8'
local Furret = {}
Furret.__index = Furret

local image = love.graphics.newImage('images/furret.png')
local frameSize = {width = 550, height = 320}
local grid = anim8.newGrid(frameSize.width, frameSize.height,
                           image:getWidth(), image:getHeight())

function Furret.new(x, y)
  local furret = {}
  setmetatable(furret, Furret)
  
  furret.delete = false
  furret.animation = anim8.newAnimation(grid('1-4',1, '1-4',2, '1-4',3, '1-4',4), 0.03)
  furret.disabled = false
  furret.radius = 120
  furret.goalX = x
  furret.goalY = y
  furret.x = x - y - furret.radius
  furret.y = -furret.radius
  furret.offsetX = 0
  furret.offsetY = 0
  furret.vibrate = 0
  furret.speed = 240
  
  return furret
end

function Furret:update(dt)
  if not self.disabled then
    self.animation:update(dt)
    
    self.x = self.x + self.speed * dt
    self.y = self.y + self.speed * dt
  end
  
  if distance(self.x, self.y, self.goalX, self.goalY) <= self.radius then
    self.disabled = true
  end
  self.offsetX, self.offsetY = vibratePosition(self.vibrate)
end

function Furret:draw(debugMode)
  self.animation:draw(image, self.x + self.offsetX, self.y + self.offsetY,
                      math.pi/4, 0.5, 0.5, frameSize.width/2, frameSize.height/2)
  if debugMode then
    love.graphics.circle('line', self.x, self.y, self.radius)
    love.graphics.setColor(0.6, 1, 0.6)
    love.graphics.circle('fill', self.x, self.y, 4)
    love.graphics.setColor(1, 0.5, 0.5)
    love.graphics.circle('fill', self.goalX, self.goalY, 10)
    love.graphics.setColor(1, 1, 1)
  end
end

return Furret