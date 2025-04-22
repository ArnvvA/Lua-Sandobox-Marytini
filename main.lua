local crtShader
local canvas
local startTime = love.timer.getTime()
local gameCanvas

Drink = {}
Drink.__index = Drink



function Drink:new(saltiness, bitterness, sweetness, sourness)
    local obj = {
        Saltiness = saltiness or 0,
        Bitterness = bitterness or 0,
        Sweetness = sweetness or 0,
        Sourness = sourness or 0
    }
    setmetatable(obj, self)
    return obj
end

function Drink:scoreAgainst(target)
    local parameters = {"Saltiness", "Bitterness", "Sweetness", "Sourness"}
    local totalDiff = 0
    for _, attr in ipairs(parameters) do
        totalDiff = totalDiff + math.abs(self[attr] - target[attr])
    end

    local score = ((8 - totalDiff) * multiplier) * 10
    return math.max(score, 0)
end


function Drink:isExactMatch(target)
    return self.Saltiness == target.Saltiness and
           self.Bitterness == target.Bitterness and
           self.Sweetness == target.Sweetness and
           self.Sourness == target.Sourness
end

function generateRandomTarget()
    return Drink:new(
        love.math.random(1, 3),
        love.math.random(1, 3),
        love.math.random(1, 3),
        love.math.random(1, 3)
    )
end


function love.load()

    crtShader = love.graphics.newShader("crt.glsl")
    -- canvas = love.graphics.newCanvas(love.graphics.getWidth(), love.graphics.getHeight())
    gameCanvas = love.graphics.newCanvas(1600, 900)  -- your actual game resolution

    clickSound = love.audio.newSource("card.ogg", "static")
    pourSound = love.audio.newSource("pour-drink-trimmed.mp3", "static")
    font = love.graphics.newFont("dogica.ttf", 20) -- 20 is the font size
    love.graphics.setFont(font)

    love.window.setMode(1600, 900)

    images = {
        Saltiness = love.graphics.newImage("salt.png"),
        Bitterness = love.graphics.newImage("bitter.png"),
        Sweetness = love.graphics.newImage("sweet.png"),
        Sourness = love.graphics.newImage("sour.png")
    }

    
    attributes = {"Saltiness","Bitterness", "Sweetness", "Sourness"}
    values = {1, 2, 3} -- Low, Medium, High

    -- Layout for side-by-side images and buttons to the right of each image
    local buttonWidth = 80
    local buttonHeight = 40
    local spacingX = 120 -- Increased spacing to prevent overlap
    local imageScale = 0.333
    local imageWidth = images[attributes[1]]:getWidth() * imageScale
    local imageHeight = images[attributes[1]]:getHeight() * imageScale
    local totalWidth = (#attributes * (imageWidth + buttonWidth)) + ((#attributes - 1) * spacingX)
    local startX = (love.graphics.getWidth() - totalWidth) / 2
    local imageY = 220

    buttons = {}
    drink = {}
    for i, attr in ipairs(attributes) do
        drink[attr] = 0 -- initialize all to 0
        local colX = startX + (i-1)*(imageWidth + buttonWidth + spacingX)
        -- Image position
        local imgX = colX
        local imgY = imageY
        -- Button column position (right next to image)
        local btnColX = imgX + imageWidth + 56
        local btnColYBottom = imgY + imageHeight - 30
        local btnColYTop = imgY
        local btnSpacingY = (btnColYBottom - btnColYTop - (#values * buttonHeight)) / (#values - 1)
        for j, val in ipairs(values) do
            local btnY = btnColYBottom - j * buttonHeight
            table.insert(buttons, {
                x = btnColX,
                y = btnY,
                width = buttonWidth + 50,
                height = buttonHeight,
                attribute = attr,
                value = val
            })
        end
        -- Store image position for drawing
        if not imagePositions then imagePositions = {} end
        imagePositions[attr] = {x = imgX, y = imgY}
    end

    -- Serve button
    serveButton = {
        x = (love.graphics.getWidth() - 120) / 2,
        y = love.graphics.getHeight() - 60,
        width = 120,
        height = 40,
        label = "Serve"
    }
end

targetDrink = generateRandomTarget()
lastScore = nil
totalScore = 0
targetScore = 60 -- Minimum score needed to pass (you can adjust this)
triesLeft = 4
multiplier = 1
level = 1

function love.update(dt)
end

function love.draw()
    -- Step 1: Draw your game to gameCanvas (1600x900)
    love.graphics.setCanvas(gameCanvas)
    love.graphics.clear(0.2, 0.3, 0.4)

    -- Your existing game draw code
    local imageScale = 0.5
    for i, attr in ipairs(attributes) do
        local img = images[attr]
        local pos = imagePositions[attr]
        love.graphics.draw(img, pos.x, pos.y, 0, imageScale, imageScale)
    end

    local valueLabels = { [1] = "Low", [2] = "Medium", [3] = "High" }

    for _, button in ipairs(buttons) do
        love.graphics.rectangle("line", button.x, button.y, button.width, button.height)
        local label = valueLabels[button.value] or tostring(button.value)
        love.graphics.printf(label, button.x, button.y + 10, button.width, "center")
    end

    love.graphics.print("Current Drink:", 50, 30)
    local offsetY = 50
    for i, attr in ipairs(attributes) do
        love.graphics.print(attr .. ": " .. drink[attr], 50, offsetY)
        offsetY = offsetY + 20
    end

    if canServe() then
        love.graphics.rectangle("line", serveButton.x, serveButton.y, serveButton.width, serveButton.height)
        love.graphics.printf(serveButton.label, serveButton.x, serveButton.y + 10, serveButton.width, "center")
    end

    love.graphics.print("Level: " .. level, 50, 170)
    if lastScore ~= nil then
        love.graphics.print("Last Score: " .. lastScore, 50, 470)
    end
    love.graphics.print("Total Score: " .. totalScore, 50, 500)
    love.graphics.print("Tries Left: " .. triesLeft, 50, 530)
    love.graphics.print("Multiplier: " .. multiplier, 50, 560)
    love.graphics.print("Target Score: " .. targetScore, 50, 590)

    -- Step 2: End drawing to gameCanvas
    love.graphics.setCanvas()

    -- Step 3: Apply shader to stretch gameCanvas fullscreen
    crtShader:send("millis", love.timer.getTime() - startTime)
    crtShader:send("resolution", { love.graphics.getWidth(), love.graphics.getHeight() })
    love.graphics.setShader(crtShader)

    -- Stretch gameCanvas to fill window size
    local scaleX = love.graphics.getWidth() / gameCanvas:getWidth()
    local scaleY = love.graphics.getHeight() / gameCanvas:getHeight()
    love.graphics.draw(gameCanvas, 0, 0, 0, scaleX, scaleY)

    love.graphics.setShader()
end


function love.mousepressed(x, y, button)

    if button == 1 then -- left mouse button
        for _, btn in ipairs(buttons) do
            if isInside(x, y, btn) then
                drink[btn.attribute] = btn.value
                love.audio.play(clickSound)

            end
        end

        if canServe() and isInside(x, y, serveButton) then
            serveDrink()
            love.audio.play(pourSound)

        end
    end
end

function isInside(x, y, button)
    return x > button.x and x < button.x + button.width and
           y > button.y and y < button.y + button.height
end

function canServe()
    for _, val in pairs(drink) do
        if val == 0 then
            return false
        end
    end
    return true
end

function serveDrink()
    -- Create player drink
    local playerDrink = Drink:new(
        drink["Saltiness"],
        drink["Bitterness"],
        drink["Sweetness"],
        drink["Sourness"]
    )

    -- Calculate base score
    local rawScore = playerDrink:scoreAgainst(targetDrink)
    lastScore = rawScore * multiplier
    totalScore = totalScore + lastScore

    print("Drink served!")
    print("Raw Score:", rawScore)
    print("Multiplied Score:", lastScore)
    print("Tries left:", triesLeft)

    if rawScore >= targetScore then
        print("You passed the target score!")
        
        -- Bonus multiplier for leftover tries
        if triesLeft > 0 then
            multiplier = multiplier + triesLeft
            print("Bonus! Multiplier increased by", triesLeft)
        end

        -- Extra bonus if it's a perfect match
        if playerDrink:isExactMatch(targetDrink) then
            multiplier = multiplier + 2
            print("Perfect Match! Extra bonus!")
        end

        -- Move to next target
        targetDrink = generateRandomTarget()
        triesLeft = 4 -- Reset tries
        multiplier = multiplier - 1
        lastScore = 0
        totalScore = 0

        level = level + 1
        targetScore = 60 + (level - 1) * 30 -- Starting from 60, increase by 10 per level
        print("Level Up! Now at level " .. level)
        print("New Target Score: " .. targetScore)


    else
        triesLeft = triesLeft - 1
        if triesLeft == 0 then
            print("Out of tries! Reset multiplier!")
            multiplier = 1 -- Reset multiplier
            targetDrink = generateRandomTarget()
            triesLeft = 4
        else
            print("Try again! Tries left:", triesLeft)
        end
    end

    -- Reset drink after every serve
    for attr, _ in pairs(drink) do
        drink[attr] = 0
    end
end
