print("Card Parser mod loaded")

-- todo remove to the cards selected by hanged man from playing cards

-- variable to hold data for transfer to calculator
GameState = assert(SMODS.load_file('game_state.lua'))()

local Converter = assert(SMODS.load_file('converter.lua'))()



SMODS.current_mod.calculate = function(self, context)
    -- get when a joker is added to the slot
    if context.card_added then
        local card = context.card
        if not card then return end
        G.E_MANAGER:add_event(Event({
            func = function()
                if card.ability.set == "Joker" then
                    GameState.add_joker(card)
                    GameState.print_jokers()
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
                    GameState.set_playing_cards(cards)
                else
                    GameState.add_playing_cards(cards)
                end
                GameState.print_playing_cards()
				Converter.compileHand(GameState.jokers, GameState.playing_cards)
                return true
            end
        }))
    end

    -- remove playing cards when they are used in a hand
    if context.press_play then
        local cards = G.hand.highlighted
        GameState.remove_playing_cards(cards)
    end

    -- remove playing cards when they are used in a discard
    if context.pre_discard then
        local cards = context.full_hand
        G.E_MANAGER:add_event(Event({
            func = function()
                    GameState.remove_playing_cards(cards)
                return true
            end
        }))
    end

    -- remove a joker when being sold
    if context.selling_card and context.card.ability.set == "Joker" then
        GameState.remove_joker(context.card)
        GameState.print_jokers()
    end

end

local game_start_run_ref = Game.start_run
function Game:start_run(args, ...)
    local ret = game_start_run_ref(self, args, ...)
    if args.savetext then
        local blind = G.GAME.blind.config.blind.key
        local cards = G.hand.cards;
        local jokers = G.jokers.cards
        G.E_MANAGER:add_event(Event({
            func = function()
                -- get the playing cards the user got in hand when loading into a round
                -- verify this only happen if the user is in a blind
                if blind ~= nil then
                    GameState.set_playing_cards(cards)
                    GameState.print_playing_cards()
                end

                -- add jokers the user got in hand when loading in a run
                GameState.set_jokers(jokers)
                GameState.print_jokers()
                return true
            end
        }))
    end
    return ret
end

-- reset state when going to main menu
local go_to_menu_ref = G.FUNCS.go_to_menu
function G.FUNCS.go_to_menu(e)
    local ret = go_to_menu_ref()
    GameState.reset()
    return ret
end

-- reset state when run is reset via 'r' key
local init_game_object_ref = Game.init_game_object
function Game:init_game_object()
    local ret = init_game_object_ref()
    GameState.reset()
    return ret
end

-- todo when the wheel is used, update the jokers


-- G.hand.cards
    -- Check for the following states
        -- Consumables
            -- Tarots
                -- Hanged Man
                -- Magician (Working on)
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
        -- Consumables
            -- Spectral
                -- Ectoplasm
                -- Ankhe
                -- Hex


