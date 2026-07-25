-- Shared helper for "using this planet card levels up the right hand" tests.
-- Require this from any test file, then call .register / .register_many.
--
-- opts fields:
--   key            (string)  e.g. 'pluto'        -> test name becomes 'pluto_count'
--   card           (string)  e.g. 'c_pluto'      -> the consumeable key
--   hand           (string)  e.g. 'High Card'    -> key into GameState.hands
--   seed           (string, optional) -> defaults to DEFAULT_SEED below
--   expected_level (number, optional) -> defaults to 2 (level after one use)

local M = {}

M.DEFAULT_SEED = "HK4FE57E"
M.DEFAULT_EXPECTED_LEVEL = 2

function M.register(opts)
    local expected_level = opts.expected_level or M.DEFAULT_EXPECTED_LEVEL

    Balatest.TestPlay {
        name = opts.key .. '_count',
        seed = opts.seed or M.DEFAULT_SEED,
        category = { 'consumeable', 'planet', opts.key, 'planet_level' },
        consumeables = { opts.card },
        no_auto_start = true,
        execute = function()
            Balatest.start_round()
            Balatest.end_round()
            Balatest.cash_out()
            Balatest.open(function() return G.shop_booster.cards[2] end)
            Balatest.use(G.consumeables.cards[1])
        end,
        assert = function()
            local level = GameState.hands[opts.hand].level
            Balatest.assert_eq(
                expected_level,
                level,
                string.format("Expected %s level to be %d. Got %d", opts.hand, expected_level, level)
            )
        end
    }
end

-- Convenience: register a whole list of { key, card, hand, ... } tables at once.
function M.register_many(list)
    for _, opts in ipairs(list) do
        M.register(opts)
    end
end

return M