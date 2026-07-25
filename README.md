# Card Parser
Card Parser converts current Balatro state (hand, jokers, consumables, boss, etc.) into a link that can be opened directly in [EFHII's Balatro Calculator](https://efhiii.github.io/balatro-calculator/), allowing analysis of the current state of the run without manually entering cards.

<img width="300" height="169" alt="demo" src="https://github.com/user-attachments/assets/4b15edd1-0153-49a4-8353-272d46000d5c" />

## Installation
1. Download [**Steamodded**](https://github.com/Steamodded/smods/releases)
2. Download [**Lovely**](https://github.com/ethangreen-dev/lovely-injector/releases)
3. Download the `Card.Parser` zip found in the [latest release](https://github.com/Hawker-Balatro-Mods/Card-Parser/releases/latest)
4. Extract the contents into your `Mods` folder  
   - Windows path: `%AppData%/Balatro/Mods`

## How to use
1. Start/Continue a run
1. Press the `Copy calculator url` button
1. Open the copied link in your web browser.

### Config
<img width="1919" height="1079" alt="card parser config menu" src="https://github.com/user-attachments/assets/9b3e7aeb-fe63-4f11-82fd-01555aa28e30" />
If **Automatically copy url every event** is enabled, you won't need to press Copy calculator URL. The URL will automatically be copied to your clipboard after every game action.

## Contact (Discord)
- Hawker - `blckhawker`
- Possessed - `possessedhood416`

## Feedback
- If you found a bug or have any ideas for improvement, please open a GitHub issue and/or contact us on Discord in the [Balatro server](https://discord.gg/Kt5AvmCTjY).
- If possible, include your log file when reporting bugs. It makes debugging much easier.
  - Windows: `%AppData%/Balatro/Mods/lovely/log`

## Contribution
- Open pull requests against the `develop` branch. Do not target `main`.
- Add a description of your changes to `CHANGELOG.md` under the `Unreleased` section.
- `main` is reserved for production releases and should not be used for development.
- Please send us a message on Discord after opening your PR so we don't miss it.

### Balatest
[Balatest](https://github.com/BakersDozenBagels/Balatest/) is a unit testing framework for Balatro mods. While it is not required to contribute, installing it is **strongly recommended** so you can run the test suite locally.

When fixing a bug or adding a feature, include a corresponding unit test. This helps prevent regressions and reduces the amount of manual testing needed before releases. 

Add comments above each test describing its purpose and the steps it performs. This makes it easier for future contributors to understand what the test is validating and why it exists.
**Example**
```lua
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
```