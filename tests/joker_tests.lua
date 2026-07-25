-- eval Balatest.run_tests()
-- eval Balatest.run_tests('card_parser', 'tarot')
-- Purpose: Verify Blueprint and Brainstorm are represented as their own
-- joker IDs in the calculator rather than the joker they are copying.

-- Steps:
-- 1. Start with Blueprint, Mystic Summit, and Brainstorm.
-- 2. Start a blind.
-- 3. Assert that GameState contains the following joker ids:
--    - j_blueprint
--    - j_brainstorm
--    - j_mystic_summit

-- Manual:
-- 1. Open the generated calculator link.
-- 2. Verify Blueprint and Brainstorm appear correctly.

Balatest.TestPlay {
    name = 'blueprint_brainstorm_copy',
    category = { 'joker', 'external_mod' },
    no_auto_start = true,
    jokers = { 'j_blueprint', 'j_mystic_summit', 'j_brainstorm' },
    execute = function()
    end,
    assert = function()
       local held_joker_ids = {}
       local expected = {
           j_blueprint = false,
           j_brainstorm = false,
           j_mystic_summit = false,
       }
       for _, joker in ipairs(GameState.jokers) do
           local id = joker.config.center_key
           table.insert(held_joker_ids, id)   
           if expected[id] ~= nil then
               expected[id] = true
           end
       end
       for id, found in pairs(expected) do
           Balatest.assert(
               found,
               ("Expected %s to be a joker in GameState. Got %s")
                   :format(id, table.concat(held_joker_ids, ", "))
           )
       end
    end
}

-- Verify Banner counts discards correctly in calculator
-- Steps:
-- 1. Start with Banner
-- 2. Start a blind.
-- 3. Assert the discard amount is 4

-- Manual:
-- 1. Copy anf open the generated calculator link.
-- 2. Verify Banner joker is there and discard count is 4
Balatest.TestPlay {
    name = 'banner_discard',
    category = { 'joker' },
    no_auto_start = true,
    jokers = { 'j_banner' },
    discards = 4,
    execute = function()
        Balatest.start_round()
    end,
    assert = function()
       local discards = G.GAME.current_round.discards_left
       Balatest.assert_eq(discards, 4, "Expected 4 discards left. Got " .. discards)
	end
}

-- Purpose: Verify Madness removes a joker when a blind is selected
-- Steps:
-- 1. Start with Madness and Square Joker.
-- 2. Start a blind.
-- 3. Assert that the game state only has Madness as a joker

-- Manual:
-- 1. Open the generated calculator link.
-- 2. Verify only Madness is a joker
Balatest.TestPlay {
    name = 'madness_removal',
    category = { 'joker' },
    no_auto_start = true,
    jokers = { 'j_madness', 'j_square' },
    execute = function()
        Balatest.start_round()
    end,
    assert = function()
       local held_joker_ids = {}
       local has_madness = false

       for _, joker in ipairs(GameState.jokers) do
           local id = joker.config.center_key
           table.insert(held_joker_ids, id)
           if id == 'j_madness' then
               has_madness = true
           end
       end
       local count = #held_joker_ids
       local joker_str = table.concat(held_joker_ids, ", ")
       Balatest.assert_eq(count, 1, "Expected 1 joker in GameSate. Got "..count.." ("..joker_str..")")
       Balatest.assert(has_madness, "Expected madness joker (j_madness) to be in GameState. Got " .. joker_str)
    end
}

