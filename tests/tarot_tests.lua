-- #region Verify using cards within a pack does not hang the game 
local hang = assert(SMODS.load_file("tests/helpers/hang_test_helper.lua"))()

-- All these just need one highlighted card ('2S') before use.
hang.register_many(
    {
        'chariot', 'devil', 'empress', 'heirophant', 'justice', 'lovers',
        'magician', 'moon', 'strength', 'tower', 'star', 'sun', 'world',
    },
    'tarot',
    { highlight = { '2S' } }
)

-- Death needs a second card present so it has something to copy.
hang.register {
    key = 'death',
    card = 'c_death',
    set = 'tarot',
    highlight = { '2S', '2C' },
}
-- #endregion
