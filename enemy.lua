enemies = {}

function spawnEnemy(x, y)
    local enemy = world:newRectangleCollider(x, y, 70, 90, {collision_class = "Danger"})
    enemy.direction = 1
    enemy.speed = 200
    table.insert(enemies, enemy)
end

function updateEnemies(dt)
    for i,e in ipairs(enemies) do
        local ex, ey, = e:getPosition()
        e:setX(ex + e.speed * dt * e.direction)
    end
end