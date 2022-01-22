function love.load()
    love.window.setMode(1000, 768)

    anim8 = require 'libraries/anim8/anim8'
    sti = require 'libraries/Simple-Tiled-Implementation/sti'
    cameraFile = require 'libraries/hump/camera'

    cam = cameraFile()

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

    -- dangerZone = world:newRectangleCollider(0, 550, 800, 50, {collision_class = "Danger"})
    -- dangerZone:setType('static')

    platforms = {}

    loadMap()
end

function love.update(dt)
    world:update(dt)
    gameMap:update(dt)
    playerUpdate(dt)

    local px, py = player:getPosition()
    cam:lookAt(px, py)
end

function love.draw()
    cam:attach()
        gameMap:drawLayer(gameMap.layers["Base"])
        world:draw()
        drawPlayer()
    cam:detach()
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

function spawnPlatform(x, y, width, height)
    if width > 0 and height > 0 then
        local platform = world:newRectangleCollider(x, y, width, height, {collision_class = "Platform"})
        platform:setType('static')
        table.insert(platforms, platform)
    end
end

function loadMap()
    gameMap = sti("maps/levelOne.lua")
    for i, obj in pairs(gameMap.layers["platform"].objects) do
        spawnPlatform(obj.x, obj.y, obj.width, obj.height)
    end
end