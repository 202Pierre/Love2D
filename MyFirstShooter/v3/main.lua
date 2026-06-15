function love.load()
    screenWidth = love.graphics.getWidth()
    screenHeight = love.graphics.getHeight()
    
    -- Player
    player = {
        x = screenWidth / 2,
        y = screenHeight - 80,
        radius = 30,
        moveToX = screenWidth / 2
    }
    
    -- Game state
    enemies = {}
    projectiles = {}
    particles = {}
    score = 0
    gameOver = false
    spawnTimer = 0
    shootCooldown = 0
    
    -- Enemy types
    enemyTypes = {
        { color = {1, 0.3, 0.3}, radius = 20, speed = 150, points = 10, shape = "circle" },
        { color = {1, 0.8, 0.2}, radius = 25, speed = 100, points = 20, shape = "square", health = 2 },
        { color = {0.8, 0.2, 1}, radius = 15, speed = 250, points = 30, shape = "circle" }
    }
end

function love.update(dt)
    if gameOver then return end
    
    screenWidth = love.graphics.getWidth()
    screenHeight = love.graphics.getHeight()
    
    -- Move player
    player.x = player.x + (player.moveToX - player.x) * dt * 12
    if player.x < player.radius then player.x = player.radius end
    if player.x > screenWidth - player.radius then player.x = screenWidth - player.radius end
    
    -- Shoot cooldown
    if shootCooldown > 0 then
        shootCooldown = shootCooldown - dt
    end
    
    -- Spawn enemies
    spawnTimer = spawnTimer + dt
    if spawnTimer > 0.9 then
        local enemyType = enemyTypes[math.random(#enemyTypes)]
        table.insert(enemies, {
            x = math.random(enemyType.radius, screenWidth - enemyType.radius),
            y = -enemyType.radius,
            radius = enemyType.radius,
            speed = enemyType.speed,
            color = enemyType.color,
            points = enemyType.points,
            shape = enemyType.shape,
            health = enemyType.health or 1,
            type = enemyType
        })
        spawnTimer = 0
    end
    
    -- Update projectiles
    for i = #projectiles, 1, -1 do
        local p = projectiles[i]
        p.y = p.y - 400 * dt
        
        if p.y + p.radius < 0 then
            table.remove(projectiles, i)
        end
    end
    
    -- Update enemies and check collisions
    for i = #enemies, 1, -1 do
        local e = enemies[i]
        e.y = e.y + e.speed * dt
        
        -- Check collision with player
        local dx = player.x - e.x
        local dy = player.y - e.y
        local dist = math.sqrt(dx^2 + dy^2)
        if dist < player.radius + e.radius then
            createParticles(e.x, e.y, e.color)
            gameOver = true
        end
        
        -- Check collision with projectiles
        for j = #projectiles, 1, -1 do
            local p = projectiles[j]
            local pdx = e.x - p.x
            local pdy = e.y - p.y
            local pdist = math.sqrt(pdx^2 + pdy^2)
            
            if pdist < e.radius + p.radius then
                -- Hit!
                createParticles(e.x, e.y, e.color)
                e.health = e.health - 1
                table.remove(projectiles, j)
                
                if e.health <= 0 then
                    score = score + e.points
                    table.remove(enemies, i)
                end
                break
            end
        end
        
        -- Remove if off screen
        if e and e.y > screenHeight + e.radius + 50 then
            table.remove(enemies, i)
        end
    end
    
    -- Update particles
    for i = #particles, 1, -1 do
        local p = particles[i]
        p.x = p.x + p.vx * dt
        p.y = p.y + p.vy * dt
        p.life = p.life - dt
        
        if p.life <= 0 then
            table.remove(particles, i)
        end
    end
end

function createParticles(x, y, color)
    for i = 1, 12 do
        table.insert(particles, {
            x = x, y = y,
            vx = (math.random() - 0.5) * 200,
            vy = (math.random() - 0.5) * 200,
            life = 0.5,
            color = color
        })
    end
end

function love.touchpressed(id, x, y, dx, dy)
    if gameOver then
        love.load()
    else
        player.moveToX = x
    end
end

function love.touchmoved(id, x, y, dx, dy)
    if not gameOver then
        player.moveToX = x
    end
end

function love.touchreleased(id, x, y, dx, dy)
    if not gameOver and shootCooldown <= 0 then
        -- Shoot 3 projectiles in a spread
        for angle = -0.3, 0.3, 0.3 do
            table.insert(projectiles, {
                x = player.x,
                y = player.y - player.radius,
                radius = 8,
                vx = math.sin(angle) * 150,
                vy = -300
            })
        end
        shootCooldown = 0.3
    end
end

function love.draw()
    screenWidth = love.graphics.getWidth()
    screenHeight = love.graphics.getHeight()
    
    love.graphics.setBackgroundColor(0.05, 0.05, 0.1)
    
    -- Draw particles
    for _, p in ipairs(particles) do
        love.graphics.setColor(p.color[1], p.color[2], p.color[3], p.life)
        love.graphics.circle("fill", p.x, p.y, 4)
    end
    
    -- Draw enemies
    for _, e in ipairs(enemies) do
        love.graphics.setColor(e.color[1], e.color[2], e.color[3])
        if e.shape == "circle" then
            love.graphics.circle("fill", e.x, e.y, e.radius)
        else
            love.graphics.rectangle("fill", e.x - e.radius, e.y - e.radius, e.radius * 2, e.radius * 2)
        end
        
        -- Health bar for tough enemies
        if e.health > 1 then
            love.graphics.setColor(1, 1, 1)
            love.graphics.rectangle("fill", e.x - e.radius, e.y - e.radius - 10, (e.radius * 2) * (e.health / 2), 4)
        end
    end
    
    -- Draw projectiles
    love.graphics.setColor(0.2, 1, 0.5)
    for _, p in ipairs(projectiles) do
        love.graphics.circle("fill", p.x, p.y, p.radius)
    end
    
    -- Draw player
    love.graphics.setColor(0.2, 0.7, 1)
    love.graphics.circle("fill", player.x, player.y, player.radius)
    love.graphics.setColor(1, 1, 1)
    love.graphics.circle("line", player.x, player.y, player.radius)
    
    -- UI
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Score: " .. score, 20, 20)
    
    if shootCooldown > 0 then
        love.graphics.print("READY", player.x - 25, player.y - 45)
    else
        love.graphics.print("FIRE!", player.x - 25, player.y - 45)
    end
    
    if gameOver then
        love.graphics.printf("GAME OVER - Tap to restart", 0, screenHeight/2, screenWidth, "center")
    end
end

function love.resize(w, h)
    screenWidth = w
    screenHeight = h
    if player then
        player.y = h - 80
        player.x = math.min(math.max(player.x, player.radius), w - player.radius)
        player.moveToX = player.x
    end
end