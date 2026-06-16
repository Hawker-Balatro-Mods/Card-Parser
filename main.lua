print("Card Parser mod loaded")

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

    -- Update # of hands played when a poker hand is played
    if context.press_play then
        local text, _ = G.FUNCS.get_poker_hand_info(G.hand.highlighted)
        GameState.update_hands_played(text)

    end

    -- reset hands played per round to 0 when round is over
    if context.end_of_round and context.game_over == false then
        print("end of round")
        for _, hand in pairs(GameState.hands) do
            hand.played_this_round = 0
        end
    end

    -- Update level of each hand
    if context.poker_hand_changed then
        local hand_key = context.scoring_name
        local new_level = context.new_level

         G.E_MANAGER:add_event(Event({
            func = function()
                GameState.hands[hand_key].level = new_level;
                GameState.print_hand_data(hand_key)
                return true
            end
        }))
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

                -- get the levels of each hand (and round if applicable)
                for handName, handData in pairs(GameState.hands) do
                    local source = G.GAME.hands[handName]
                    handData.level = source.level
                    handData.played = source.played
                    if blind ~= nil then
                        handData.played_this_round = source.played_this_round
                    end
                end
                GameState.print_hands_data()
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

