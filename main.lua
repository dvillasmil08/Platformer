function love.load()
    love.window.setMode(1000, 768)

    anim8 = require 'libraries/anim8/anim8'
    sti = require 'libraries/Simple-Tiled-Implementation/sti'
 
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

    require('Player')

    platform = world:newRectangleCollider(250, 400,  300, 100,  {collision_class = "Platform"})
    platform:setType('static')

    dangerZone = world:newRectangleCollider(0, 550, 800, 50, {collision_class = "Danger"})
    dangerZone:setType('static')

    loadMap()
end

function love.update(dt)
    world:update(dt)
    gameMap:update(dt)
    playerUpdate(dt)
end

function love.draw()
    world:draw()
    gameMap:drawLayer(gameMap.layers["Base"])
    drawPlayer()
end

function love.keypressed(key)
    -- Could change up arrow to W
    if key == 'up' then
        if player.grounded then
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

function loadMap()
    gameMap = sti("maps/levelOne.lua")
end