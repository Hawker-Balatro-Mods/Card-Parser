Balatest.TestPlay {
    name = 'pluto_count',
    category = { 'consumeable', 'planet', 'pluto', 'planet_count' },
    consumeables = { 'c_pluto' },
    no_auto_start = true,
    execute = function()
        Balatest.use(G.consumeables.cards[1])
    end,
    assert = function()
    end
}

Balatest.TestPlay {
    name = 'uranus_count',
    category = { 'consumeable', 'planet', 'uranus', 'planet_count' },
    consumeables = { 'c_uranus' },
    no_auto_start = true,
    execute = function()
        Balatest.use(G.consumeables.cards[1])
    end,
    assert = function()
        local level = GameState.hands["Two Pair"].level
        Balatest.assert_eq(2, level, string.format("Expected Pair level to be %d. Got %d", 2, level))
    end
}

Balatest.TestPlay {
    name = 'mercury_count',
    category = { 'consumeable', 'planet', 'mercury', 'planet_count' },
    consumeables = { 'c_mercury' },
    no_auto_start = true,
    execute = function()
        Balatest.use(G.consumeables.cards[1])
    end,
    assert = function()
        local level = GameState.hands["Pair"].level
        Balatest.assert_eq(2, level, string.format("Expected Pair level to be %d. Got %d", 2, level))
    end
}

Balatest.TestPlay {
    name = 'venus_count',
    category = { 'consumeable', 'planet', 'venus', 'planet_count' },
    consumeables = { 'c_venus' },
    no_auto_start = true,
    execute = function()
        Balatest.use(G.consumeables.cards[1])
    end,
    assert = function()
        local level = GameState.hands["Three of a Kind"].level
        Balatest.assert_eq(2, level, string.format("Expected Three of a Kind level to be %d. Got %d", 2, level))
    end
}

Balatest.TestPlay {
    name = 'saturn_count',
    category = { 'consumeable', 'planet', 'saturn', 'planet_count' },
    consumeables = { 'c_saturn' },
    no_auto_start = true,
    execute = function()
        Balatest.use(G.consumeables.cards[1])
    end,
    assert = function()
        local level = GameState.hands["Straight"].level
        Balatest.assert_eq(2, level, string.format("Expected Straight level to be %d. Got %d", 2, level))
    end
}

Balatest.TestPlay {
    name = 'jupiter_count',
    category = { 'consumeable', 'planet', 'jupiter', 'planet_count' },
    consumeables = { 'c_jupiter' },
    no_auto_start = true,
    execute = function()
        Balatest.use(G.consumeables.cards[1])
    end,
    assert = function()
        local level = GameState.hands["Flush"].level
        Balatest.assert_eq(2, level, string.format("Expected Flush level to be %d. Got %d", 2, level))
    end
}

Balatest.TestPlay {
    name = 'earth_count',
    category = { 'consumeable', 'planet', 'earth', 'planet_count' },
    consumeables = { 'c_earth' },
    no_auto_start = true,
    execute = function()
        Balatest.use(G.consumeables.cards[1])
    end,
    assert = function()
        local level = GameState.hands["Full House"].level
        Balatest.assert_eq(2, level, string.format("Expected Full House level to be %d. Got %d", 2, level))
    end
}

Balatest.TestPlay {
    name = 'mars_count',
    category = { 'consumeable', 'planet', 'mars', 'planet_count' },
    consumeables = { 'c_mars' },
    no_auto_start = true,
    execute = function()
        Balatest.use(G.consumeables.cards[1])
    end,
    assert = function()
        local level = GameState.hands["Four of a Kind"].level
        Balatest.assert_eq(2, level, string.format("Expected Four of a Kind level to be %d. Got %d", 2, level))
    end
}

Balatest.TestPlay {
    name = 'neptune_count',
    category = { 'consumeable', 'planet', 'neptune', 'planet_count' },
    consumeables = { 'c_neptune' },
    no_auto_start = true,
    execute = function()
        Balatest.use(G.consumeables.cards[1])
    end,
    assert = function()
        local level = GameState.hands["Straight Flush"].level
        Balatest.assert_eq(2, level, string.format("Expected Straight Flush level to be %d. Got %d", 2, level))
    end
}

Balatest.TestPlay {
    name = 'planet_x_count',
    category = { 'consumeable', 'planet', 'planet_x', 'planet_count' },
    consumeables = { 'c_planet_x' },
    no_auto_start = true,
    execute = function()
        Balatest.use(G.consumeables.cards[1])
    end,
    assert = function()
        local level = GameState.hands["Five of a Kind"].level
        Balatest.assert_eq(2, level, string.format("Expected Five of a Kind level to be %d. Got %d", 2, level))
    end
}

Balatest.TestPlay {
    name = 'ceres_count',
    category = { 'consumeable', 'planet', 'ceres', 'planet_count' },
    consumeables = { 'c_ceres' },
    no_auto_start = true,
    execute = function()
        Balatest.use(G.consumeables.cards[1])
    end,
    assert = function()
        local level = GameState.hands["Flush House"].level
        Balatest.assert_eq(2, level, string.format("Expected Flush House level to be %d. Got %d", 2, level))
    end
}

Balatest.TestPlay {
    name = 'eris_count',
    category = { 'consumeable', 'planet', 'eris', 'planet_count' },
    consumeables = { 'c_eris' },
    no_auto_start = true,
    execute = function()
        Balatest.use(G.consumeables.cards[1])
    end,
    assert = function()
        local level = GameState.hands["Flush Five"].level
        Balatest.assert_eq(2, level, string.format("Expected Flush Five level to be %d. Got %d", 2, level))
    end
}

-- eval Balatest.run_tests('card_parser', 'planet_count')