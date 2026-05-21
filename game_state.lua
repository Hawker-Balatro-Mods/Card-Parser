-- todo either find or make a sort function for playing cards
-- Class to hold the state that will be transferred to the calculator
local GameState = {}
GameState.__index = GameState

function GameState.new()
    local self = setmetatable({}, GameState)
    self.playing_cards = {} -- the playing cards in hand during a blind
    self.jokers = {} -- the jokers at the top area
    return self
end

-- Reset game state to be empty
function GameState:reset()
    self.playing_cards = {}
    self.jokers = {}
    print("reset state")
end

-- todo refactor these bottom two into one function

-- Add a joker to a joker slot
function GameState:add_joker(joker)
    table.insert(self.jokers, joker)
end

-- Add multiple jokers to joker slot
function GameState:add_jokers(jokers)
    for _, joker in ipairs(jokers) do
        table.insert(self.jokers, joker)
    end
end

-- Overwrite the jokers
function GameState:set_jokers(jokers)
    local copy = {}
    for _, joker in ipairs(jokers) do
        table.insert(copy, joker)
    end
    self.jokers = copy
end


-- Remove joker from a joker slot
function GameState:remove_joker(target_joker)
    local new_jokers = {}

    for _, joker in ipairs(self.jokers) do
        if not same_joker(target_joker, joker) then
            table.insert(new_jokers, joker)
        end
    end

    self.jokers = new_jokers
end

-- Overwrite the playing cards
function GameState:set_playing_cards(cards)
    local copy = {}
    for _, card in ipairs(cards) do
        table.insert(copy, card)
    end
    self.playing_cards = copy
end

-- Add cards to playing cards
function GameState:add_playing_cards(cards)
    for _, card in ipairs(cards) do
        table.insert(self.playing_cards, card)
    end
end

-- Remove cards from playing cards
function GameState:remove_playing_cards(cards_to_remove)
    local new_playing_cards = {}

    for _, card in ipairs(self.playing_cards) do
        local should_remove = false

        -- Check if this card matches any card to remove
        for _, target_card in ipairs(cards_to_remove) do
            if same_playing_card(card, target_card) then
                should_remove = true
                break
            end
        end

        -- Keep card if it should not be removed
        if not should_remove then
            table.insert(new_playing_cards, card)
        end
    end

    self.playing_cards = new_playing_cards
end

-- Print the playing cards
function GameState:print_playing_cards()
    print("Playing cards in hand: " .. print_play_card_data(self.playing_cards))
end

-- Print jokers in the joker area
function GameState:print_jokers()
    print("Jokers in slot: " .. print_joker_data(self.jokers))
end

-- Helper function to see if two playing cards are the same
function same_playing_card(c1, c2)
    -- todo need to add seals, enhancements, and editions
    return c1.base.id == c2.base.id and 
           c1.base.suit == c2.base.suit
end

-- Helper function to see if two jokers are the same by name, debuff, and edition
function same_joker(j1, j2)
    if ~(j1.label == j2.label and j1.debuff == j2.debuff) then
        return false
    end

    if j1.edition == nil and j2.edition == nil then
        return false
    end

    return j1.edition.type == j2.edition.type
    
end

-- Helper function to print playing cards (not necessarily the ones in the player's hand)
function print_play_card_data(cards)
    local card_strings = {}
    local card_names = {
        [11] = "Jack",
        [12] = "Queen",
        [13] = "King",
        [14] = "Ace"
    }

    for _, card in ipairs(cards) do
        local id = card.base.id
        local name = card_names[id] or tostring(id)
        table.insert(card_strings, name .. " of " .. card.base.suit)
    end

    return table.concat(card_strings, ", ") .. " (" .. #cards .. ")"
end

-- Helper function to print jokers
function print_joker_data(jokers)
    local joker_strings = {}

    for _, joker in ipairs(jokers) do
        table.insert(joker_strings, joker.label)
    end

    return table.concat(joker_strings, ", ") .. " (" .. #jokers .. ")"
end

return GameState