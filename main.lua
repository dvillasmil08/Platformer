function love.load()
    wf = require 'Libraries/windfield'
    world = wf.newWorld(0, 800)

    player = world:newRectangleCollider(360, 100, 80, 80)
    player.speed = 240

    platform = world:newRectangleCollider(250, 400,  300, 100)
    platform:setType('static')
end

function love.update(dt)
    world:update(dt)

    local px, py = player:getPosition()
    -- could change right arrow to D
    if love.keyboard.isDown('right') then
        player:setX(px + player.speed*dt)
    end
    -- could change right arrow to A
    if love.keyboard.isDown('left') then
        player:setX(px - player.speed*dt)
    end
end

function love.draw()
    world:draw()
end

function love.keypressed(key)
    -- Could change up arrow to W
    if key == 'up' then
        player:applyLinearImpulse(0, -7000)
    end
end