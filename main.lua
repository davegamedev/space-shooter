function love.load()
    windowWidth = 480
    windowHeight = 800
    windowTitle = "Space Shooter"
    love.window.setMode(windowWidth, windowHeight)
    love.window.setTitle(windowTitle)

    gameColors = require("libraries/colors")
    gameColors = colors
    gameTitleFont = love.graphics.newFont(48)
    gameOtherFont = love.graphics.newFont(16)
    
    gameState = 1

    sprites = {}
    sprites.background = love.graphics.newImage("sprites/background_darkPurple.png")
    sprites.player = love.graphics.newImage("sprites/playerShip1_orange.png")
    sprites.playerLife = love.graphics.newImage("sprites/playerLife1_orange.png")
    sprites.meteor = love.graphics.newImage("sprites/meteorBrown_med1.png")
    sprites.laser = love.graphics.newImage("sprites/laserRed16.png")

    background = {}
    background.x = 0
    background.y = -800
    background.h = 1600
    background.speed = 200

    player = {}
    player.x = love.graphics.getWidth() / 2 - 25
    player.y = windowHeight - 90
    player.w = 99
    player.h = 75
    player.speed = 300
    player.lifes = 3

    meteors = {}
    meteorRot = 0
    createMeteorTimerMax = 0.35 
    createMeteorTimer = createMeteorTimerMax

    lasers = {}
    canShoot = true
    canShootTimerMax = 0.25
    canShootTimer = canShootTimerMax

    score = 0
end

function love.update(dt)
    -- Background update y position
    if background.y <= 0 then
        background.y = background.y + background.speed * dt
    else
        background.y = -800
        background.y = background.y + background.speed * dt
    end

    -- Player move
    if love.keyboard.isDown("right") then
        player.x = player.x + player.speed * dt
    end
    if love.keyboard.isDown("left") then
        player.x = player.x - player.speed * dt
    end

    -- Player bounds
    if player.x < 0 then
        player.x = 0;
    end
    if player.x > windowWidth - player.w then
        player.x = windowWidth - player.w
    end
    
    -- Player shoot the laser
    if canShootTimer > 0 then
        canShootTimer = canShootTimer - dt
    else
        canShoot = true
    end
    if love.keyboard.isDown("space") and gameState == 2 then
        shootLaser()
    end

    -- Check player lifes
    if player.lifes <= 0 then
        player.lifes = 0
        -- love.event.quit()
        gameState = 1
    end
    
    -- Meteor auto spawn
    createMeteorTimer = createMeteorTimer - dt
    if createMeteorTimer <= 0 and gameState == 2 then
        spawnMeteor()
        createMeteorTimer = createMeteorTimerMax
    end
    
    for i, m in ipairs(meteors) do
        -- Meteors move
        m.y = m.y + m.speed * dt
        -- Meteors remove collide window height
        if m.y > windowHeight or gameState == 1 then
            table.remove(meteors, i)
        end
    end

    for i, l in ipairs(lasers) do
        -- Laser move
        l.y = l.y - l.speed * dt
        -- Laser remove collide window top
        if l.y < 0 then
            table.remove(lasers, i)
        end
    end

    for i, m in ipairs(meteors) do
        for j, l in ipairs(lasers) do
            -- Check the meteor and laser collision
            if checkCollision(m.x, m.y, m.w, m.h, l.x, l.y, l.w, l.h) then
                -- Remove the items for lists and add score
                table.remove(lasers, j)
                table.remove(meteors, i)
                score = score + 1
            end
        end
        -- Check the meteor and player collision
        if checkCollision(m.x, m.y, m.w, m.h, player.x, player.y, player.w, player.h) then
            -- Remove the meteor and extract player lifes
            table.remove(meteors, i)
            player.lifes = player.lifes - 1
        end
    end
end

function love.draw()
    love.graphics.setColor(gameColors.white, 1)

    love.graphics.draw(sprites.background, background.x, background.y)

    if gameState == 1 then
        love.graphics.setFont(gameTitleFont)
        love.graphics.print("Space Shooter", (windowWidth / 2) - 180, (windowHeight/2) - 80)
        love.graphics.setFont(gameOtherFont)
        love.graphics.print("Press S to start the game", (windowWidth / 2) - 100, (windowHeight / 2) - 10)
    end

    if gameState == 2 then
        love.graphics.draw(sprites.player, player.x, player.y)

        for i, m in ipairs(meteors) do
            love.graphics.draw(sprites.meteor, m.x, m.y)
        end

        for i, l in ipairs(lasers) do
            love.graphics.draw(sprites.laser, l.x, l.y)
        end

        love.graphics.setFont(gameOtherFont)
        love.graphics.print("Score: " .. score, windowWidth / 2 - 10, 10)

        for i=1, player.lifes, 1 do
            love.graphics.draw(sprites.playerLife, (i * (sprites.playerLife:getWidth() + 10)) - sprites.playerLife:getWidth(), 5)
        end
    end
end

function spawnMeteor()
    local meteor = {}
    meteor.x = math.random(0, windowWidth - sprites.meteor:getWidth())
    meteor.y = 0
    meteor.w = 43
    meteor.h = 43
    meteor.speed = math.random(100, 300)
    table.insert(meteors, meteor)
end

function spawnLaser()
    local laser = {}
    laser.x = player.x + (sprites.player:getWidth() / 2) - (sprites.laser:getWidth() / 2)
    laser.y = player.y - sprites.player:getHeight()
    laser.w = 13
    laser.h = 54
    laser.speed = 500
    table.insert(lasers, laser)
end
 
function shootLaser()
    if canShoot then
        spawnLaser()
        canShoot = false
        canShootTimer = canShootTimerMax
    end
end

function checkCollision(x1,y1,w1,h1,x2,y2,w2,h2)
    return x1 < x2 + w2 and x2 < x1 + w1 and y1 < y2 + h2 and y2 < y1 + h1
end

function love.keypressed(key)
    if key == "escape" then
        love.event.quit()
    end
    if key == "s" and gameState == 1 then
        player.lifes = 3
        gameState = 2
    end
end