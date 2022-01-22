function love.load()
    anim8 = require 'libraries/anim8/anim8'
 
    sprites = {}
    sprites.playerSheet = love.graphics.newImage('sprites/TileSheet/gameboy.png')

    local grid = anim8.newGrid(96, 96, sprites.playerSheet:getWidth(), sprites.playerSheet:getHeight())

    animations = {}
    animations.idle = anim8.newAnimation(grid('1-1',1), 1)
    animations.jump = anim8.newAnimation(grid('2-2',1), 1)
    animations.run = anim8.newAnimation(grid('3-4',1), 0.3)

    wf = require 'libraries/windfield'
    world = wf.newWorld(0, 800, false)
    world:setQueryDebugDrawing(true)

    world:addCollisionClass('Platform')
    world:addCollisionClass('Player'--[[, {ignores = {'Platform'}}]])
    world:addCollisionClass('Danger')

    player = world:newRectangleCollider(360, 100, 50, 66, {collision_class = "Player"})
    player:setFixedRotation(true)
    player.speed = 240
    player.animation = animations.idle
    player.isMoving = false
    player.direction = 1

    platform = world:newRectangleCollider(250, 400,  300, 100,  {collision_class = "Platform"})
    platform:setType('static')

    dangerZone = world:newRectangleCollider(0, 550, 800, 50, {collision_class = "Danger"})
    dangerZone:setType('static')
end

function love.update(dt)
    world:update(dt)
    player.isMoving = false
    if player.body then
        local px, py = player:getPosition()
        -- could change right arrow to D
        if love.keyboard.isDown('right') then
            player:setX(px + player.speed*dt)
            player.isMoving = true
            player.direction = 1
        end
        -- could change right arrow to A
        if love.keyboard.isDown('left') then
            player:setX(px - player.speed*dt)
            player.isMoving = true
            player.direction = -1
        end
        
        if player:enter('Danger') then
            player:destroy()    
        end
    end

    if player.isMoving then
        player.animation = animations.run
    else
        player.animation = animations.idle
    end 
    player.animation:update(dt)
end

function love.draw()
    world:draw()

    local px, py = player:getPosition()
    player.animation:draw(sprites.playerSheet, px, py, nil, 1 * player.direction, 1, 46, 62)
end

function love.keypressed(key)
    -- Could change up arrow to W
    if key == 'up' then
        local colliders = world:queryRectangleArea(player:getX() - 25, player:getY() + 33, 33, 2, {'Platform'})
        if #colliders > 0 then
            player:applyLinearImpulse(0, -3000)
        end
    end
end

function love.mousepressed(x, y, button)
    if button == 1 then
        local colliders = world:queryCircleArea(x, y, 200, {'Platform', 'Danger'})
        for i,c in ipairs(colliders) do
            c:destroy()
        end
    end
end