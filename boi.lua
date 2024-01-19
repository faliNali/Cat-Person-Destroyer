local anim8 = require 'anim8'
local Boi = {}
Boi.__index = Boi

local image = love.graphics.newImage('images/boi.png')
local frameSize = {width = 240, height = 240}
local grid = anim8.newGrid(frameSize.width, frameSize.height,
                         image:getWidth(), image:getHeight())

local gravity = 40

function Boi.new()
    local boi = {}
    setmetatable(boi, Boi)

    boi.delete = false
    boi.shot = false
    boi.disabled = false
    boi.animation = anim8.newAnimation(grid('1-8',1), 0.08)
    boi.radius = 55
    local randBool = {true, false}
    boi.left = randBool[math.random(1, 2)]
    if boi.left then
        boi.x = love.graphics.getWidth() + boi.radius
        boi.scaleX = -0.5
    else
        boi.x = -boi.radius
        boi.scaleX = 0.5
    end
    
    boi.originY = math.random(boi.radius, love.graphics.getHeight() - boi.radius)
    boi.y = boi.originY
    boi.scaleY = 0.5
    
    boi.offsetX = 0
    boi.offsetY = 0
    boi.vibrate = 0
    boi.rotation = 0
    boi.rotationAccum = math.random(-15, 15)
    boi.speed = 120
    boi.shotSpeed = 1100
    boi.shotVel = {x = 0, y = 0}
    boi.shotLeft = false

    return boi
end

function Boi:update(dt, delete)
    if not self.disabled then
        self.animation:update(dt)
        
        if self.shot then
            self.rotation = self.rotation + self.rotationAccum * dt
            
            if distance1(self.x, 0) <= self.radius or
               distance1(love.graphics.getWidth(), self.x) <= self.radius then
                self.shotVel.x = -self.shotVel.x
            end
            self.x = self.x + self.shotVel.x * dt
            self.y = self.y + self.shotVel.y * dt
            self.shotVel.y = self.shotVel.y + gravity
            if self.y > self.originY then
                self.delete = true
            end
        else
            if self.left then self.x = self.x - self.speed * dt
            else self.x = self.x + self.speed * dt end

            if self.x > love.graphics.getWidth() + self.radius then
                self.delete = true
            end
        end
    end
    self.offsetX, self.offsetY = vibratePosition(self.vibrate)
end

function Boi:draw(debugMode)
    self.animation:draw(image, self.x + self.offsetX, self.y + self.offsetY, self.rotation,
                        self.scaleX, self.scaleY, frameSize.width/2, frameSize.height/2)
    if debugMode then
        love.graphics.setColor(0.5, 1, 0.7)
        love.graphics.circle('fill', self.x, self.y, 2)
        love.graphics.setColor(1, 1, 1)
        love.graphics.circle('line', self.x, self.y, self.radius)
    end
end



return Boi