-- #region Verify using cards within a pack does not hang the game 
local hang = assert(SMODS.load_file("tests/helpers/hang_test_helper.lua"))()
 
-- No highlight or joker needed.
hang.register_many(
    {
        'black_hole', 'familiar', 'grim', 'immolate', 'incantation',
        'ouija', 'sigil', 'soul', 'wraith',
    },
    'spectral'
)
 
-- Needs a joker on board.
hang.register_many(
    { 'ankh', 'ectoplasm', 'hex' },
    'spectral',
    { jokers = { 'j_joker' } }
)
 
-- Needs a highlighted card.
hang.register_many(
    { 'aura', 'cryptid', 'deja_vu', 'medium', 'trance' },
    'spectral',
    { highlight = { '2S' } }
)
-- #endregion