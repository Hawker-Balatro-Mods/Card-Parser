-- Shared helper for "does using this consumable in a shop pack hang the game" tests.
-- Require this from any test file, then call .register on your own list of cards.

-- opts fields:
--   key       (string)        e.g. 'chariot'      -> test name becomes 'chariot_hang'
--   card      (string)        e.g. 'c_chariot'    -> the consumeable key
--   set       ('tarot'|'spectral'|...) -> used as the first category tag
--   seed      (string, optional) -> defaults to DEFAULT_SEED below
--   jokers    (table, optional)  -> passed straight through as the `jokers` field
--   highlight (table, optional)  -> cards to highlight before using the consumeable

local M = {}

M.DEFAULT_SEED = "VESXE5DM"

function M.register(opts)
    local test = {
        name = opts.key .. '_hang',
        seed = opts.seed or M.DEFAULT_SEED,
        consumeables = { opts.card },
        category = { opts.set, 'consumable', 'hang', opts.key },
        no_auto_start = true,
        execute = function()
            Balatest.start_round()
            Balatest.end_round()
            Balatest.cash_out()
            Balatest.open(function() return G.shop_booster.cards[2] end)
            if opts.highlight then
                Balatest.highlight(opts.highlight)
            end
            Balatest.use(G.consumeables.cards[1])
        end
    }
    if opts.jokers then
        test.jokers = opts.jokers
    end
    Balatest.TestPlay(test)
end

-- Convenience: register the same options for a whole list of card keys at once.
-- shared_opts is anything register() accepts except `key`/`card`, applied to every entry.
function M.register_many(keys, set, shared_opts)
    shared_opts = shared_opts or {}
    for _, key in ipairs(keys) do
        local opts = { key = key, card = 'c_' .. key, set = set }
        for k, v in pairs(shared_opts) do
            opts[k] = v
        end
        M.register(opts)
    end
end

return M