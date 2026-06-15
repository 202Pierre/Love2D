function love.load()
    player = { x = 400, y = 550, radius = 35, moveToX = 400 }
    objects = {}
    score = 0
    gameOver = false
    spawnTimer = 0
end

function love.update(dt)
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    
    if gameOver then return end
    
    player.x = player.x + (player.moveToX - player.x) * dt * 10
    
    if player.x < player.radius then player.x = player.radius end
    if player.x > screenWidth - player.radius then player.x = screenWidth - player.radius end
    
    spawnTimer = spawnTimer + dt
    if spawnTimer > 0.8 then
        table.insert(objects, { 
            x = math.random(player.radius, screenWidth - player.radius), 
            y = -20, 
            radius = math.random(18, 30),
            speed = 150
        })
        spawnTimer = 0
    end
    
    for i = #objects, 1, -1 do
        local obj = objects[i]
        obj.y = obj.y + obj.speed * dt
        
        local dx = player.x - obj.x
        local dy = player.y - obj.y
        local dist = math.sqrt(dx^2 + dy^2)
        if dist < player.radius + obj.radius then
            gameOver = true
        end
        
        if obj.y > screenHeight + 50 then
            table.remove(objects, i)
            score = score + 1
        end
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

function love.draw()
    local screenWidth = love.graphics.getWidth()
    local screenHeight = love.graphics.getHeight()
    
    love.graphics.setBackgroundColor(0.1, 0.1, 0.15)
    love.graphics.setColor(0.2, 0.7, 1)
    love.graphics.circle("fill", player.x, player.y, player.radius)
    
    love.graphics.setColor(1, 0.3, 0.3)
    for _, obj in ipairs(objects) do
        love.graphics.circle("fill", obj.x, obj.y, obj.radius)
    end
    
    love.graphics.setColor(1, 1, 1)
    love.graphics.print("Score: " .. score, 20, 20)
    
    if gameOver then
        love.graphics.printf("GAME OVER - Tap to restart", 0, screenHeight/2, screenWidth, "center")
    end
end

-- nwcse.reserve@gmail.com june13 2026