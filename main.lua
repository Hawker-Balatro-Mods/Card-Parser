print("Card Parser mod loaded")
cardparse_mod = SMODS.current_mod;
config = cardparse_mod.config

-- variable to hold data for transfer to calculator
GameState = assert(SMODS.load_file('game_state.lua'))()

-- Object to get calculator url
Converter = assert(SMODS.load_file('converter.lua'))()

-- Config menu
assert(SMODS.load_file('ui/config_ui.lua'))()

-- button callbacks
assert(SMODS.load_file('ui/button_callbacks.lua'))()

-- Show copy button
assert(SMODS.load_file('ui/sidebar_ui.lua'))()

SMODS.current_mod.calculate = function(self, context)
    -- Check if in a blind
    if context.setting_blind then
        GameState.blind_key = G.GAME.blind.config.blind.key;
        print("Current blind: " .. GameState.blind_key)
        Converter.compileHand(GameState, config.automatic_url_copy)
    end

    -- get when a joker is added to the slot
    -- get when a planet is added to a consumable slot
    if context.card_added then
        local card = context.card
        if not card then return end
        G.E_MANAGER:add_event(Event({
            func = function()
                if card.ability.set == "Joker" then
                    GameState.add_joker(card)
                    GameState.print_jokers()
                    
                elseif GameState.planets[card.config.center_key] then
                    GameState.add_planet(card);
                    GameState.print_planets()
                end
                Converter.compileHand(GameState, config.automatic_url_copy)
                return true
            end
        }))
    end

    -- Get the playing cards the user got in hand when starting a blind
    -- if the user has not used a hand yet, overwrite the playing cards
    -- otherwise, append the new cards to the playing cards
    if context.hand_drawn or context.other_drawn then
        if G.GAME.selected_back.effect.center.key == "b_plasma" then
            GameState.using_plasma_deck = true
            print("Using plasma deck")
            Converter.compileHand(GameState, config.automatic_url_copy)
        end
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
				Converter.compileHand(GameState, config.automatic_url_copy)
                return true
            end
        }))
    end

    -- remove playing cards when they are used in a hand
    if context.press_play then
        local cards = G.hand.highlighted
        GameState.remove_playing_cards(cards)
        Converter.compileHand(GameState, config.automatic_url_copy)
    end

    -- remove playing cards when they are used in a discard
    if context.pre_discard then
        local cards = context.full_hand
        G.E_MANAGER:add_event(Event({
            func = function()
                GameState.remove_playing_cards(cards)
                Converter.compileHand(GameState, config.automatic_url_copy)
                return true
            end
        }))
    end

    -- remove a joker/planet when being sold
    if context.selling_card then
        local card = context.card;
        if card.ability.set == "Joker" then
            GameState.remove_joker(card)
            GameState.print_jokers()
            Converter.compileHand(GameState, config.automatic_url_copy)

        elseif GameState.planets[card.config.center_key] then
            GameState.remove_planet(card)
            GameState.print_planets()
            Converter.compileHand(GameState, config.automatic_url_copy)
        end
    end

    -- Update # of hands played when a poker hand is played
    if context.press_play then
        local text, _ = G.FUNCS.get_poker_hand_info(G.hand.highlighted)
        GameState.update_hands_played(text)
        Converter.compileHand(GameState, config.automatic_url_copy)
    end

    -- reset hands played per round to 0 when round is over
    -- set blind key to null
    if context.end_of_round and context.game_over == false then
        print("end of round")
        for _, hand in pairs(GameState.hands) do
            hand.played_this_round = 0
        end
        GameState.blind_key = nil
        Converter.compileHand(GameState, config.automatic_url_copy)
    end

    -- Update level of each hand
    if context.poker_hand_changed then
        local hand_key = context.scoring_name
        local new_level = context.new_level

         G.E_MANAGER:add_event(Event({
            func = function()
                GameState.hands[hand_key].level = new_level;
                GameState.print_hand_data(hand_key)
                Converter.compileHand(GameState, config.automatic_url_copy)
                return true
            end
        }))
    end

    -- Check if uer is buy observatory voucher
    if context.buying_card and context.card.config.center_key == "v_observatory" then
        GameState.observatory_voucher_obtained = true;
        print("Observatory voucher obtained")
        Converter.compileHand(GameState, config.automatic_url_copy)
    end

    -- Remove a planet consumable when used
    if context.using_consumeable and GameState.is_planet(context.consumeable) then
        GameState.remove_planet(context.consumeable)
        GameState.print_planets()
        Converter.compileHand(GameState, config.automatic_url_copy)
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

                -- check if the user has the observatory voucher
                if G.GAME.used_vouchers["v_observatory"] then
                    GameState.observatory_voucher_obtained = true;
                    print("Observatory voucher obtained")
                end

                if blind ~= nil then
                    GameState.set_playing_cards(cards)
                    GameState.print_playing_cards()

                    -- check if the player is playing a blind
                    GameState.blind_key = blind
                    print(GameState.blind_key .. " is active")
                end

                -- check if user is playing plasma deck
                if G.GAME.selected_back.effect.center.key == "b_plasma" then
                    GameState.using_plasma_deck = true
                    print("Using plasma deck")
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
                Converter.compileHand(GameState, config.automatic_url_copy)
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

