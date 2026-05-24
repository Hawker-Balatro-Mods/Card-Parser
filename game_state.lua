

-- todo either find or make a sort function for playing cards
-- Class to hold the state that will be transferred to the calculator
GameState = {
    playing_cards = {}, -- the playing cards in hand during a blind
    jokers = {}, -- the jokers at the top area
    joker_consumable_keys = {"c_wheel_of_fortune", "c_ectoplasm", "c_hex", "c_ankh"}, -- consumables keys to be aware of to update the jokers
    playing_cards_consumable_keys = {"c_magician", "c_empress", "c_heirophant", "c_lovers", "c_chariot", "c_justice", "c_strength", "c_hanged_man", "c_death", "c_devil", "c_tower", "c_star", "c_moon", "c_sun", "c_world", "c_familiar", "c_grim", "c_incantation", "c_talisman", "c_aura", "c_sigil", "c_ouija", "c_immolate", "c_deja_vu", "c_trance", "c_medium", "c_cryptid"} -- consumables keys to be aware of to update the playing_cards
}

-- returns if key is in joker_consumable_keys
function GameState.is_joker_consumable_key(key)
    for _, value in ipairs(GameState.joker_consumable_keys) do
        if value == key then
            return true
        end
    end
    return false
end

function GameState.consumable_print()
    print("consumable print")
    
end

-- Reset game state to be empty
function GameState.reset()
    GameState.playing_cards = {}
    GameState.jokers = {}
    print("reset state")
end

-- todo refactor these bottom two into one function
-- Add a joker to a joker slot
function GameState.add_joker(joker)
    table.insert(GameState.jokers, joker)
end

-- Add multiple jokers to joker slot
function GameState.add_jokers(jokers)
    for _, joker in ipairs(jokers) do
        table.insert(GameState.jokers, joker)
    end
end

-- Overwrite the jokers
function GameState.set_jokers(jokers)
    local copy = {}
    for _, joker in ipairs(jokers) do
        table.insert(copy, joker)
    end
    GameState.jokers = copy
end


-- Remove joker from a joker slot
function GameState.remove_joker(target_joker)
    local new_jokers = {}

    for _, joker in ipairs(GameState.jokers) do
        if not same_joker(target_joker, joker) then
            table.insert(new_jokers, joker)
        end
    end

    GameState.jokers = new_jokers
end

-- Overwrite the playing cards
function GameState.set_playing_cards(cards)
    local copy = {}
    for _, card in ipairs(cards) do
        table.insert(copy, card)
    end
    GameState.playing_cards = copy
end

-- Add cards to playing cards
function GameState.add_playing_cards(cards)
    for _, card in ipairs(cards) do
        table.insert(GameState.playing_cards, card)
    end
end

-- Remove cards from playing cards
function GameState.remove_playing_cards(cards_to_remove)
    local new_playing_cards = {}

    for _, card in ipairs(GameState.playing_cards) do
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

    GameState.playing_cards = new_playing_cards
end

-- Print the playing cards
function GameState.print_playing_cards()
    print("Playing cards in hand: " .. print_play_card_data(GameState.playing_cards))
end

-- Print jokers in the joker area
function GameState.print_jokers()
    print("Jokers in slot: " .. print_joker_data(GameState.jokers))
end

-- Helper function to see if two playing cards are the same
function same_playing_card(c1, c2)   
    if not 
    (c1.base.id == c2.base.id and 
    c1.base.suit == c2.base.suit and 
    c1.seal == c2.seal and
    c1.enhancement == c2.enhancement and
    (c1.edition == nil) == (c2.edition == nil)) then
        return false
    end

    if c1.edition == nil then
		return true
	end

    return c1.edition.type == c2.edition.type
end

-- Helper function to see if two jokers are the same by name, debuff, and edition
function same_joker(j1, j2)
    if not (j1.label == j2.label and j1.debuff == j2.debuff and (j1.edition == nil) == (j2.edition == nil)) then
        return false
    end

	if j1.edition == nil then
		return true
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
        -- X of Y (Enhancement, Edition, Seal, Debuffed)
        local perks = {}
        if card.edition ~= nil then
            table.insert(perks, card.edition.type)
        end

        if card.ability.effect ~= "Base" then
            table.insert(perks, card.ability.effect)
        end

        if card.seal ~= nil then
            table.insert(perks, card.seal.." Seal" )
        end

        if card.debuff then
            table.insert(perks, "Debuffed")
        end

        local id = card.base.id
        local name = card_names[id] or tostring(id)
        local perk_string = table.concat(perks, ", ")

        if(#perks > 0) then
            table.insert(card_strings, name .." of ".. card.base.suit.." ("..perk_string..")")
        else
            table.insert(card_strings, name .." of ".. card.base.suit)
        end

        
    end

    return table.concat(card_strings, ", ") .. " (" .. #cards .. ")"
end

-- Helper function to print jokers including editions and debuffed
function print_joker_data(jokers)
    local joker_strings = {}

    for _, joker in ipairs(jokers) do
        -- Joker (Foil, Deuffed)
        local perks = {}

        if joker.edition ~= nil then
            table.insert(perks, joker.edition.type)
        end

         if joker.debuff then
            table.insert(perks, "Debuffed")
        end

        local perk_string = table.concat(perks, ", ")

        if(#perks > 0) then
            table.insert(joker_strings, joker.label.." (" ..perk_string.. ")")
        else
            table.insert(joker_strings, joker.label)
        end
    end

    return table.concat(joker_strings, ", ") .. " (" .. #jokers .. ")"
end

return GameState