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

-- Overwrite the playing cards
function GameState:set_playing_cards(cards)
    for _, card in ipairs(cards) do
        table.insert(self.playing_cards, card)
    end
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

-- Helper function to see if two playing cards are the same
function same_playing_card(c1, c2)
    -- todo need to add seals, enhancements, and editions
    return c1.base.id == c2.base.id and 
           c1.base.suit == c2.base.suit
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

return GameState