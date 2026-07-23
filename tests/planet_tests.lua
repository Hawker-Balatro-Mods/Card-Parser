-- #region Verify using a planet card increases the correct level hand
local level = assert(SMODS.load_file("tests/helpers/planet_level_test_helper.lua"))()
level.register_many {
    { key = 'pluto',   card = 'c_pluto',   hand = 'High Card' },
    { key = 'mercury', card = 'c_mercury', hand = 'Pair' },
    { key = 'uranus', card = 'c_uranus', hand = 'Two Pair' },
    { key = 'venus', card = 'c_venus', hand = 'Three of a Kind' },
    { key = 'saturn', card = 'c_saturn', hand = 'Straight' },
    { key = 'jupiter', card = 'c_jupiter', hand = 'Flush' },
    { key = 'earth', card = 'c_earth', hand = 'Full House' },
    { key = 'mars', card = 'c_mars', hand = 'Four of a Kind' },
    { key = 'neptune', card = 'c_neptune', hand = 'Straight Flush' },
    { key = 'planet_x', card = 'c_planet_x', hand = 'Five of a Kind' },
    { key = 'ceres', card = 'c_ceres', hand = 'Flush House' },
    { key = 'eris', card = 'c_eris', hand = 'Flush Five' },
}
-- #endregion

-- eval Balatest.run_tests('card_parser', 'planet_level')