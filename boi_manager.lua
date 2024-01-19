Boi = require 'boi'
Explosion = require 'explosion'

local bois = {}
local shotBois = {}
local explosions = {}
local boiTimer = 0
local killed = 0
local killedRecent = 0
local shooterDisabled = false
local spawning = true
local BoiMgr = {}

local function orderY(a, b)
    return a.y < b.y
end

function BoiMgr.update(dt)
    killedRecent = 0
    if spawning then
        boiTimer = boiTimer - dt
        if boiTimer < 0 then
            boiTimer = boiTimer + math.random(0.2, 0.25)
            local boi = Boi.new()
            table.insert(bois, boi)
            table.sort(bois, orderY)
        end
    end
    for i, boi in ipairs(bois) do
        boi:update(dt)
        if boi.shot then
            table.insert(shotBois, boi)
            table.sort(shotBois, orderY)
            table.remove(bois, i)
        end
        if boi.delete then
            table.remove(bois, i)
        end
    end
    for i, boi in ipairs(shotBois) do
        boi:update(dt)
        if boi.delete then
            table.remove(shotBois, i)
            local explosion = Explosion.new(boi.x, boi.y)
            table.insert(explosions, explosion)
            killed = killed + 1
            killedRecent = killedRecent + 1
        end
    end
    for i, expl in ipairs(explosions) do
        expl:update(dt)
        if expl.delete then
            table.remove(explosions, i)
        end
    end
end

function BoiMgr.draw(debugMode)
    for i, boi in ipairs(bois) do
        boi:draw(debugMode)
    end
    for i, boi in ipairs(shotBois) do
        boi:draw(debugMode)
    end
    for i, expl in ipairs(explosions) do
        expl:draw()
    end
    
    if debugMode then
        love.graphics.print('amount of bois: ' .. tostring(#bois), 0, 40)
    end
end

function BoiMgr.mousepressed(x, y, button, istouch, presses)
    if button == 1 then
        if not shooterDisabled then
            for i, boi in ipairs(bois) do
                if distance(x, y, boi.x, boi.y) <= boi.radius then
                    local angle = math.atan2(boi.y - y, boi.x - x)
                    if x > boi.x then
                        boi.shotLeft = true
                    end
                    boi.shotVel.x, boi.shotVel.y = normalize(math.cos(angle), math.sin(angle))
                    boi.shotVel.x = boi.shotVel.x * boi.shotSpeed
                    boi.shotVel.y = -math.abs(boi.shotVel.y * boi.shotSpeed)
                    boi.shot = true
                end
            end
        end
    end
end

function BoiMgr.getKilled() return killedRecent end

function BoiMgr.setShooterDisabled(disabled) shooterDisabled = disabled end

function BoiMgr.reset()
    spawning = true
    for i, boi in ipairs(bois) do
        boi.delete = true
    end
end

function BoiMgr.getBois() return bois end

function BoiMgr.setSpawning(isSpawning) spawning = isSpawning end

return BoiMgr