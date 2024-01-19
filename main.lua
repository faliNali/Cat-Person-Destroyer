local boiManager
local shooter
local ultra

local debugMode
local fps

function love.load()
    love.mouse.setVisible(false)
    love.graphics.setBackgroundColor(0.45, 0.75, 1)
    math.randomseed(os.time())

    boiManager = require 'boi_manager'
    shooter = require 'shooter'
    ultra = require 'ultra'

    debugMode = false
    fps = 0
end

function love.update(dt)
    fps = 1/dt
    boiManager.update(dt)
    shooter.update(dt)
    ultra.update(dt, boiManager, shooter)

    if debugMode then
        love.mouse.setVisible(true)
    else
        love.mouse.setVisible(false)
    end
end

function love.draw()
    boiManager.draw(debugMode)
    ultra.draw(debugMode, boiManager)
    shooter.draw()

    if debugMode then
        love.graphics.print('press f3 to disable debug mode')
        love.graphics.print('fps: ' .. tostring(fps), 0, 20)
    else
        love.graphics.print('press f3 for debug mode')
    end
end

function love.mousepressed(x, y, button, istouch, presses)
    boiManager.mousepressed(x, y, button, istouch, presses)
    shooter.mousepressed(x, y, button, istouch, presses)
    ultra.mousepressed(x, y, button, istouch, presses, boiManager, shooter)
end

function love.keypressed(key, scancode, isrepeat)
    if key == 'f3' then
        debugMode = not debugMode
    end
end

function distance(x1,y1,x2,y2) return math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2) end

function distance1(x1, x2) return x1 - x2 end

function normalize(x,y) local l=(x*x+y*y)^.5 if l==0 then return 0,0,0 else return x/l,y/l,l end end

function vibratePosition(vibrate)
    return math.random(-vibrate/2, vibrate/2), math.random(-vibrate/2, vibrate/2)
end