function love.load()
    love.window.setMode(1000, 768)

    anim8 = require 'libraries/anim8/anim8'
    sti = require 'libraries/Simple-Tiled-Implementation/sti'
    cameraFile = require 'libraries/hump/camera'

    cam = cameraFile()

    sounds = {}
    sounds.jump = love.audio.newSource("audio/jump.wav", "static")
    sounds.music = love.audio.newSource("audio/music.mp3", "stream")
    sounds.music:setLooping(true)
    sounds.music:setVolume(0.05)
    sounds.jump:setVolume(0.10)

    sounds.music:play()

    sprites = {}
    sprites.playerSheet = love.graphics.newImage('sprites/TileSheet/gameboy.png')
    sprites.enemySheet = love.graphics.newImage('sprites/TileSheet/enemySheet.png')
    sprites.background = love.graphics.newImage('sprites/background.png')
    
    local grid = anim8.newGrid(96, 96, sprites.playerSheet:getWidth(), sprites.playerSheet:getHeight())
    local enemyGrid = anim8.newGrid(100, 79, sprites.enemySheet:getWidth(), sprites.enemySheet:getHeight())

    animations = {}
    animations.idle = anim8.newAnimation(grid('1-1',1), 1)
    animations.jump = anim8.newAnimation(grid('2-2',1), 1)
    animations.run = anim8.newAnimation(grid('3-4',1), 0.3)
    animations.enemy = anim8.newAnimation(enemyGrid('1-2',1), 0.1)

    wf = require 'libraries/windfield/windfield'
    world = wf.newWorld(0, 800, false)
    world:setQueryDebugDrawing(true)

    world:addCollisionClass('Platform')
    world:addCollisionClass('Player'--[[, {ignores = {'Platform'}}]])
    world:addCollisionClass('Danger')

    require('Player')
    require('enemy')

    dangerZone = world:newRectangleCollider(-500, 800, 5000, 50, {collision_class = "Danger"})
    dangerZone:setType('static')

    platforms = {}


    doorX = 0
    doorY = 0

    currentLevel = "level1"

    loadMap(currentLevel)
end

function love.update(dt)
    world:update(dt)
    gameMap:update(dt)
    playerUpdate(dt)
    updateEnemies(dt)

    local px, py = player:getPosition()
    -- If you DONT want the camera to Y position static
    -- Change bellow code to: cam:lookAt(px, py)
    cam:lookAt(px, love.graphics.getHeight()/2)

    local colliders = world:queryCircleArea(doorX, doorY, 10, {'Player'})
    if #colliders > 0 then
        if currentLevel == "level1" then
        loadMap("level2")
        elseif currentLevel == "level2" then
            --change to level3 if more than 2 levels are available
            -- and use same elseif for multiple levels
            loadMap("level1")
        end
    end
end

function love.draw()
    love.graphics.draw(sprites.background, 0 ,0)
    cam:attach()
        gameMap:drawLayer(gameMap.layers["Base"])
        drawPlayer()
        drawEnemies()
    cam:detach()
end

function love.keypressed(key)
    -- Could change up arrow to W
    if key == 'up' then
        if player.grounded then
            player:applyLinearImpulse(0, -3000)
            sounds.jump:play()
        end
    end
    if key == 'r' then
        loadMap("level2")
    end
end

-- function love.mousepressed(x, y, button)
--     if button == 1 then
--         local colliders = world:queryCircleArea(x, y, 200, {'Platform', 'Danger'})
--         for i,c in ipairs(colliders) do
--             c:destroy()
--         end
--     end
-- end

function spawnPlatform(x, y, width, height)
    if width > 0 and height > 0 then
        local platform = world:newRectangleCollider(x, y, width, height, {collision_class = "Platform"})
        platform:setType('static')
        table.insert(platforms, platform)
    end
end

function destroyAll()
    local i = #platforms
    while i > -1 do
        if platforms[i] ~= nil then
            platforms[i]:destroy()
        end
        table.remove(platforms, i)
        i = i -1
    end

    local i = #enemies
    while i > -1 do
        if enemies[i] ~= nil then
            enemies[i]:destroy()
        end
        table.remove(enemies, i)
        i = i -1
    end
end

function loadMap(mapName)
    currentLevel = mapName
    destroyAll()
    gameMap = sti("maps/" .. mapName .. ".lua")
    for i, obj in pairs(gameMap.layers["Start"].objects) do
       playerStartX = obj.x
       playerStartY = obj.y
    end
    player:setPosition(playerStartX, playerStartY)
    for i, obj in pairs(gameMap.layers["Platform"].objects) do
        spawnPlatform(obj.x, obj.y, obj.width, obj.height)
    end
    for i, obj in pairs(gameMap.layers["Enemies"].objects) do
        spawnEnemy(obj.x, obj.y)
    end
    for i, obj in pairs(gameMap.layers["Door"].objects) do
        doorX = obj.x
        doorY = obj.y
    end
end