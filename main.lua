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

    local score = 100 - totalDiff * 25
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
    attributes = {"Saltiness","Bitterness", "Sweetness", "Sourness"}
    values = {1, 2, 3} -- Low, Medium, High

    buttons = {}
    drink = {}
    for _, attr in ipairs(attributes) do
        drink[attr] = 0 -- initialize all to 0
    end

    -- Layout
    local buttonWidth = 80
    local buttonHeight = 40
    local spacingX = 10
    local spacingY = 20
    local startX = (love.graphics.getWidth() - (buttonWidth * 3 + spacingX * 2)) / 2
    local startY = love.graphics.getHeight() - (buttonHeight * #attributes + spacingY * (#attributes - 1)) - 100

    for i, attr in ipairs(attributes) do
        for j, val in ipairs(values) do
            table.insert(buttons, {
                x = startX + (j-1)*(buttonWidth + spacingX),
                y = startY + (i-1)*(buttonHeight + spacingY),
                width = buttonWidth,
                height = buttonHeight,
                attribute = attr,
                value = val
            })
        end
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
targetScore = 60 -- Minimum score needed to pass (you can adjust this)
triesLeft = 4
multiplier = 1


function love.update(dt)
end


function love.draw()
    -- Draw buttons
    for _, button in ipairs(buttons) do
        love.graphics.rectangle("line", button.x, button.y, button.width, button.height)
        love.graphics.printf(button.value, button.x, button.y + 10, button.width, "center")
    end

    -- Draw labels for each attribute next to buttons
    for i, attr in ipairs(attributes) do
        local labelY = buttons[(i-1)*3 + 1].y + 10
        love.graphics.printf(attr, 0, labelY, buttons[1].x - 20, "right")
    end

    -- 🛠️ Draw Current Drink using attributes (fixed order)
    love.graphics.print("Current Drink:", 50, 30)
    local offsetY = 50
    for i, attr in ipairs(attributes) do
        love.graphics.print(attr .. ": " .. drink[attr], 50, offsetY)
        offsetY = offsetY + 20
    end

    -- Draw Serve button
    if canServe() then
        love.graphics.rectangle("line", serveButton.x, serveButton.y, serveButton.width, serveButton.height)
        love.graphics.printf(serveButton.label, serveButton.x, serveButton.y + 10, serveButton.width, "center")
    end

    -- Draw last score
    if lastScore ~= nil then
        love.graphics.print("Last Score: " .. lastScore, 50, 200)
    end

    love.graphics.print("Tries Left: " .. triesLeft, 50, 250)
    love.graphics.print("Multiplier: " .. multiplier, 50, 270)
    love.graphics.print("Target Score: " .. targetScore, 50, 290)
end

function love.mousepressed(x, y, button)
    if button == 1 then -- left mouse button
        for _, btn in ipairs(buttons) do
            if isInside(x, y, btn) then
                drink[btn.attribute] = btn.value
            end
        end

        if canServe() and isInside(x, y, serveButton) then
            serveDrink()
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

