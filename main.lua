print("Card Parser mod loaded")

-- variable to hold data for transfer to calculator
local GameState = assert(SMODS.load_file('game_state.lua'))()
local game_state = GameState.new()

SMODS.current_mod.calculate = function(self, context)
    -- todo get when a joker is added to the slot
    if context.card_added then
        local card = context.card
        if not card then return end
        G.E_MANAGER:add_event(Event({
            func = function()
                if card.area and card.area.config.type == 'joker' then
                    print("joker card added")
                end
                return true
            end
        }))
    end

    -- Get the playing cards the user got in hand when starting a blind
    -- if the user has not used a hand yet, overwrite the playing cards
    -- otherwise, append the new cards to the playing cards
    if context.hand_drawn or context.other_drawn then
        local first_hand_drawn = context.first_hand_drawn
        local cards = context.hand_drawn or context.other_drawn
        G.E_MANAGER:add_event(Event({
            func = function()
                if first_hand_drawn then
                    game_state:set_playing_cards(cards)
                else
                    game_state:add_playing_cards(cards)
                end
                game_state:print_playing_cards()
                return true
            end
        }))
    end

    -- remove playing cards when they are used in a hand
    if context.press_play then
        local cards = G.hand.highlighted
        game_state:remove_playing_cards(cards)
    end

    -- remove playing cards when they are used in a discard
    if context.pre_discard then
        local cards = context.full_hand
        G.E_MANAGER:add_event(Event({
            func = function()
                    game_state:remove_playing_cards(cards)
                return true
            end
        }))
    end
end

local game_start_run_ref = Game.start_run
function Game:start_run(args, ...)
    -- get the playing cards the user got in hand when loading into a round
    -- verify this only happen if the user is in a blind
    local ret = game_start_run_ref(self, args, ...)
    if args.savetext then
        local blind = G.GAME.blind.config.blind.key
        local cards = G.hand.cards;
        G.E_MANAGER:add_event(Event({
            func = function()
                if blind ~= nil then
                    game_state:set_playing_cards(cards)
                    game_state:print_playing_cards()
                end
                return true
            end
        }))
    end
    return ret
end

-- G.hand.cards
    -- Check for the following states
        -- Consumables
            -- Tarots
                -- Hanged Man
                -- Magician
                -- Empress
                -- Hierophant
                -- Lovers
                -- Chariot
                -- Justice
                -- Death
                -- Devil
                -- Tower
                -- Star
                -- Sun
                -- Moon
                -- World
            -- Spectral
                -- Familairal
                -- Grim
                -- Incantation
                -- Criptid
                -- Aura
                -- Sigil
                -- Ouiji
                -- Emilate
                -- Deja Vu
                -- Trance
                -- Medium
                -- Talisman

-- G.jokers.cards
    -- Check for the following states
        -- Player loads up a game from main menu to a round (this is how throwback joker is unlocked)
        -- Buying one
        -- Selling one
        -- Buying a bufoon booster (and not pressing "skip")
        -- Consumables
            -- Tarots
                -- Wheel
                -- Judgement
            -- Spectral
                -- Soul
                -- Wraith
                -- Ectoplasm
                -- Ankhe
                -- Hex