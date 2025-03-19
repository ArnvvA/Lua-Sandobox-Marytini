local screen_width = love.graphics.getWidth()
local screen_height = love.graphics.getHeight()

local card_sprite

local deck = {
    cards = {},
    transform = {
        x = screen_width / 2 - 63,
        y = screen_height / 2 - 88,
        width = 126,
        height = 176,
    },
}

local cards = {}


local function new_card()
    return {
        dragging = false,
        transform = {
            x = (screen_width - 126) / 2,
            y = (screen_height - 176) / 2,
            width = 126,
            height = 176
        },
        target_transform = {
            x = (screen_width - 126) / 2,
            y = (screen_height - 176) / 2,
            width = 126,
            height = 176
        },
        velocity = {
            x = 0,
            y = 0,
        },
        is_on_deck = true,
    }
end

local function align(deck)
    local deck_height = 10 / #deck.cards
    for position, card in ipairs(deck.cards) do
        if not card.dragging then
            card.target_transform.x = deck.transform.x - deck_height * (position - 1)
            card.target_transform.y = deck.transform.y + deck_height * (position - 1)
        end
    end
end

local function move(card, dt)
    local momentum = 0.75
    local max_velocity = 50
    if (card.target_transform.x ~= card.transform.x or card.velocity.x ~=0) 
    or 
    (card.target_transform.y ~= card.transform.y or card.velocity.y ~=0) 
    then 
        card.velocity.x = momentum * card.velocity.x + 
        (1 - momentum) * (card.target_transform.x - card.transform.x) * 30 * dt
        
        card.velocity.y = momentum * card.velocity.y + 
        (1 - momentum) * (card.target_transform.y - card.transform.y) * 30 * dt
        
        card.transform.x = card.transform.x + card.velocity.x
        card.transform.y = card.transform.y + card.velocity.y

        local velocity = math.sqrt(card.velocity.x ^ 2 + card.velocity.y ^ 2)
        if velocity > max_velocity then
            card.velocity.x = max_velocity * card.velocity.x / velocity
            card.velocity.y = max_velocity * card.velocity.y / velocity
        end
    end
end



function love.load()
    card_sprite = love.graphics.newImage("card.png")
    --love.graphics.setBackgroundColor(0.2, 0.3, 0.4)
    for _ = 1, 52 do
        local card = new_card()
        table.insert(cards, card)
        table.insert(deck.cards, card)
    end
end
    

function love.draw()
    love.graphics.clear(0.2,0.3,0.4)

    love.graphics.circle(
        "fill",
        deck.transform.x + deck.transform.width / 2,
        deck.transform.y + deck.transform.height + 50,
        15
    )
    
    for _, card in ipairs(deck.cards) do
        love.graphics.draw(card_sprite, card.transform.x, card.transform.y)
    end
    for _, card in ipairs(cards) do
        if not card.is_on_deck then
            love.graphics.draw(card_sprite, card.transform.x, card.transform.y)
        end
    end
end

function love.mousepressed(x, y)
    for position = #deck.cards, 1, -1 do
        local card = deck.cards[position]
        if x > card.transform.x
            and x < card.transform.x + card.transform.width
            and y > card.transform.y
            and y < card.transform.y + card.transform.height
        then
            card.dragging = true
            break
        end
    end

    if x > deck.transform.x + deck.transform.width / 2 - 15
        and x < deck.transform.x + deck.transform.width / 2 + 15
        and y > deck.transform.y + deck.transform.height + 50 - 15
        and y < deck.transform.y + deck.transform.height + 50 + 15 then
        local count = 1
        for _, card in ipairs(cards) do
            if not card.is_on_deck then
                count = count + 1
                table.insert(deck.cards, card)
            end
        end
    end
end


function love.update(delta_time)
    for _, card in ipairs(cards) do
        if card.dragging then
            card.target_transform.x = love.mouse.getX() - card.transform.width / 2
            card.target_transform.y = love.mouse.getY() - card.transform.height / 2
        end
        move(card, delta_time)
        align(deck)
    end
end


function love.mousereleased()
    for position, card in ipairs(deck.cards) do
        if card.dragging == true then
            card.dragging = false
            card.is_on_deck = false
            table.remove(deck.cards, position)
        end
    end
end

function love.keypressed(key)
    if key == "escape" then 
        love.event.quit()
    end
end

