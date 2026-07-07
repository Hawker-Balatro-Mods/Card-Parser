local bit = require("bit")
local Converter = {}
local OrderedHandNames = {
	"Flush Five",
	"Flush House",
	"Five of a Kind",
	"Straight Flush",
	"Four of a Kind",
	"Full House",
	"Flush",
	"Straight",
	"Three of a Kind",
	"Two Pair",
	"Pair",
	"High Card"
}
local OrderedPlanetNames = {
	"c_eris",
	"c_ceres",
	"c_planet_x",
	"c_neptune",
	"c_mars",
	"c_earth",
	"c_jupiter",
	"c_saturn",
	"c_venus",
	"c_uranus",
	"c_mercury",
	"c_pluto"
}

-- Each handler returns a number to encode, or nil for "default/inactive" jokers
local jokerHandlers = {
	j_acrobat = function(card)
		local active = ((G.GAME.current_round.hands_left == 1 and not next(G.play.cards)) or
		                (G.GAME.current_round.hands_left == 0 and next(G.play.cards))) and
		                card.ability.extra
		if not active then return nil end
		return 1
	end,

	j_ancient = function(card)
		local suits = {"Hearts", "Clubs", "Diamonds", "Spades"}
		for index, suit in ipairs(suits) do
			if suit == card.joker_display_values.ancient_card_suit then
				return index - 1
			end
		end
		return 0
	end,

	j_blue_joker = function(card)
		local cards_in_deck = (G.deck and G.deck.cards) and #G.deck.cards or 52
		-- despite the website asking for cards remaining, we must calculate this ourselves
		-- due to a calculator bug / semantic error
		return cards_in_deck - 52
	end,

	j_bootstraps = function(card)
		local multOf5 = math.floor((G.GAME.dollars + (G.GAME.dollar_buffer or 0)) / card.ability.extra.dollars)
		if multOf5 == 0 then return nil end
		return multOf5
	end,

	j_bull = function(card)
		local money = math.max(0, G.GAME.dollars) or 0
		if money == 0 then return nil end
		return money
	end,

	j_caino = function(card)
		if card.ability.caino_xmult == 1 then return nil end
		return card.ability.caino_xmult - 1
	end,

	j_campfire = function(card)
		if card.ability.x_mult == 1 then return nil end
		return (card.ability.x_mult - 1) / 0.25
	end,

	j_castle = function (card)
		if card.ability.extra.chips == 0 then return nil end
		return math.floor(card.ability.extra.chips / 3)
	end,

	j_ceremonial = function (card)
		if card.ability.mult == 0 then return nil end
		return card.ability.mult
	end,

	j_constellation = function (card)
		if card.ability.x_mult == 1 then return nil end
		return math.floor((card.ability.x_mult - 1) / .1)
	end,

	j_dusk = function (card)
		local active = G.GAME.current_round.hands_left <= 1;
		if not active then return nil end
		return 1
	end,

	j_erosion = function (card)
		local count = G.playing_cards and (G.GAME.starting_deck_size - #G.playing_cards) or 0
		if count == 0 then return nil end
		return count
		
	end,

	j_flash = function (card)
		local mult = card.ability.mult;
		if mult == 0 then return nil end 
		return math.floor(mult/2)
	end,

	j_fortune_teller = function (card)
		local count = card.joker_display_values.mult;
		if count == 0 then return nil end
		return count
	end,

	j_glass = function (card)
		local mult = card.ability.x_mult;
		if mult == 1 then return nil end
		return math.floor((mult - 1) / .75);
	end,

	j_green_joker = function (card)
		local mult = card.ability.mult
		if mult == 0 then return nil end
		return mult
	end,

	j_hit_the_road = function (card)
		local mult = card.ability.x_mult
		if mult == 1 then return nil end
		return math.floor((mult - 1) / .5);
	end,

	j_hologram = function (card)
		local mult = card.ability.x_mult
		if mult == 1 then return nil end
		return math.floor((mult - 1) / .25);
	end,

	j_ice_cream = function (card)
		local chips = card.ability.extra.chips
		return math.floor((100 - chips) / 5)
	end,

	j_popcorn = function (card)
		return math.floor((20 - card.ability.mult)/4)
	end,

	j_steel_joker = function (card)
		if card.joker_display_values.x_mult == 1 then return nil end
		return math.floor((card.joker_display_values.x_mult - 1) / .2)
	end,

	j_stencil = function (card)
		local mult = card.ability.x_mult
		if mult == 1 then return nil end
		return mult - 1
	end,
	
	j_wee = function(card)
		if card.ability.extra.chips == 0 then return nil end
		return card.ability.extra.chips / 8
	end,
}

--General functions
function joinTables(pre, post)
	for _, v in ipairs(post) do table.insert(pre, v) end
end

function intToBinary(num, bits)
	local value = {}
	for i = 0, bits-1 do
		table.insert(value, (bit.band(num, 2^i) > 0))
	end
	return value
end

function signedIntToBinary(num, bits)
	local value = {}
	if(num > 0) then
		joinTables(value, {false})
		joinTables(value, intToBinary(num, bits-1))
	else
		joinTables(value, {true})
		joinTables(value, intToBinary(num*-1, bits-1))		
	end

	return value
end

function binaryToBase64(bitsarray)
	local b64 = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789-_"

	while #bitsarray % 6 ~= 0 do table.insert(bitsarray, false) end

	local finalChars = {}

	for i = 1, #bitsarray/6 do
		local byteSubsec = {unpack(bitsarray, (i-1)*6+1, i*6)}
		local byteIndex = 0

		for j=1, 6 do byteIndex = (byteIndex * 2) + (byteSubsec[j] and 1 or 0) end
		
		table.insert(finalChars, string.sub(b64, byteIndex+1, byteIndex+1))
	end
	
	if #finalChars%4 == 1 then table.insert(finalChars, "A") end
	return table.concat(finalChars)
end


--Main function
function Converter.compileHand(GameState, copy)
	-- no point of compiling the hand if we're not copying the url
	if not copy then
		return
	end
	local jokers = GameState.jokers
	local cards = GameState.playing_cards
	local blind_key = GameState.blind_key
	local using_plasma_deck = GameState.using_plasma_deck
	local hands = GameState.hands
	local observatory = GameState.observatory_voucher_obtained
	local planets = GameState.planets

	local binary = {}

	--num of jokers (16b)
	joinTables(binary, intToBinary(#jokers, 16))
	
	--foreach joker
	for _, joker in ipairs(jokers) do

		--sprite pos (8b)
		joinTables(binary, spritePosToBinary(joker))

		--edition (1+2b)
		joinTables(binary, editionToBinary(joker))

		--value (1+16b) [!]
		joinTables(binary, jokerScalingToBinary(joker))

		--sell value (1+16)
		joinTables(binary, sellToBinary(joker))
	end

	--num of play cards (16b)
	joinTables(binary, intToBinary(#cards, 16))

	--num of selected cards (3b)
	joinTables(binary, intToBinary(0, 3))

	--foreach card
	for _, card in ipairs(cards) do
		--suit (2b)
		joinTables(binary, suitToBinary(card))

		--rank (4b)
		joinTables(binary, intToBinary(card.base.id - 2, 4))

		--edition (1+2b)
		joinTables(binary, editionToBinary(card))

		--enhancement (3b)
		joinTables(binary, enhancementToBinary(card))
		
		--seal (1b)
		joinTables(binary, {card.seal == "Red"})
	end

	--flint active (1b)
	joinTables(binary, {blind_key == "bl_flint"})
	
	--plasma (1b)
	joinTables(binary, {using_plasma_deck})

	--foreach hand type
	for _, handName in ipairs(OrderedHandNames) do
		--hand level (1+16b)
		joinTables(binary, handLevelToBinary(hands[handName]))
	end

	--observatory (1b)
	joinTables(binary, {observatory})

	if(observatory) then
		--foreach planet type, amt in consumanles (1+16b)
		for _, planetName in ipairs(OrderedPlanetNames) do
			if(planets[planetName].count == 0) then
				joinTables(binary, {false})
			else 
				joinTables(binary, intToBinary(planets[planetName].count*2+1, 17))
			end
		end
	end

	--extra hand data? (1b)
	local nonzerohand = false
	for _, handName in ipairs(OrderedHandNames) do
		if(hands[handName].played > 0 or hands[handName].played_this_round > 0) then nonzerohand = true end
	end
	joinTables(binary, {nonzerohand})

	if(nonzerohand) then
		--for each hand type
		for _, handName in ipairs(OrderedHandNames) do
			--played this round? (1b)
			joinTables(binary, {hands[handName].played_this_round > 0})

			--played hands of this type this run (1+16b)
			joinTables(binary, {hands[handName].played > 0})
			if(hands[handName].played > 0) then
				joinTables(binary, intToBinary(hands[handName].played, 16))
			end
		end
	end	
	
	--remove trailing 0s
	while binary[#binary] == false do table.remove(binary, #binary) end
	
	-- Copies the calculator url to clipboard
	local url = "https://efhiii.github.io/balatro-calculator/?h=" .. binaryToBase64(binary)
	sendTraceMessage("URL: " .. url, "CardParserTraceLogger")
	if G.F_LOCAL_CLIPBOARD then
        G.CLIPBOARD = url 
    else
        love.system.setClipboardText(url)
    end 
end


--Card functions
function suitToBinary(card)
	local suit = card.base.suit
	local suitIndex = {
		["Hearts"] = 0,
		["Clubs"] = 1,
		["Diamonds"] = 2,
		["Spades"] = 3,
	}
	return intToBinary(suitIndex[suit], 2)
end

function enhancementToBinary(card)
	local enh = card.ability.effect
	local enhIndex = {
		["Base"] = 0,
		["Lucky Card"] = 1,
		["Glass Card"] = 2,
		["Bonus Card"] = 3,
		["Mult Card"] = 4,
		["Steel Card"] = 5,
		["Stone Card"] = 6,
		["Wild Card"] = 7
	}
	return intToBinary(enhIndex[enh], 3)
end


--Card/Joker functions
function editionToBinary(card)
	if(card.debuff) then return {true,true,true} end
	if(card.edition == nil) then return {false} end
	local edi = card.edition.type

	if(edi == "negative") then return {false} end

	local ediIndex = {
		["foil"] = 0,
		["holo"] = 1,
		["polychrome"] = 2
	}
	return intToBinary(ediIndex[edi]*2+1, 3)
end


--Joker functions
function spritePosToBinary(card)
	local ypos = card.children.center.sprite_pos.y
	local xpos = card.children.center.sprite_pos.x

	if(card.base_cost == 20) then --legendary jokers use a slightly different table
		ypos = 8
		xpos = xpos
	end

	if(card.config.center_key == "j_wee") then
		ypos = 4 
		xpos = 0
	end
	
	local bin = intToBinary(ypos, 4)
	joinTables(bin, intToBinary(xpos, 4))
	return bin
end

function sellToBinary(card)
	if(math.floor(card.base_cost/2)	 == card.sell_cost ) then return {false} end;
	return intToBinary(card.sell_cost*2+1, 17)
end

local function encodeJokerScalingValue(v, bits)
	local result = {true}
	joinTables(result, signedIntToBinary(v, bits or 16))
	return result
end

function jokerScalingToBinary(card)
	local handler = jokerHandlers[card.config.center_key]
	if not handler then return {false} end

	local value = handler(card)
	if value == nil then return {false} end

	return encodeJokerScalingValue(value, 16)
end

--Hand functions
function handLevelToBinary(hand)
	if(hand.level == 1) then return {false} end
	return intToBinary(hand.level*2+1, 17)
end

function handPlayedStatusToBinary(hand)
	if(not hand.played_this_round and hand.played == 0) then return {false} end

end

return Converter

--[[
	# of joker 							(16b)
	
	foreach joker {
		x pos of art in jokers.png			(4b)
		y pos of art in jokers.png			(4b)
		edition [foil/holo/poly/debuff]?	(1b)
		if 1, edition id					(2b)
		Value of joker [ie scaling] != 0?	(1b)
		if 1, value							(16b)
		sell val of joker != normal?		(1b)
		if 1, sell val 						(16b)
		}
		
	num of play cards					(16b)
	num of selected cards				(3b)
	
	foreach card [selected first] {
		suit [hdcs]							(2b)
		value [rank - 2]					(4b)
		edition [foil/holo/poly/debuff]?	(1b)
		if 1, edition id					(2b)
		enhancement							(3b)
		redseal?							(1b)
	}
	
	the flint?							(1b)
	plasma deck?						(1b)
	
	foreach hand type {
		hand lvl != 1?						(1b)
		if 1, hand lvl						(16b)
	}
	
	
	observatory?						(1b)
		foreach planet card {
			non-zero amt in consum?			(1b)	
			if 1, amt in consum				(16b)
		}
	.
		
	not all hands zeroed out?			(1b)
	if 1, foreach hand type {
		played this round?			(1b)
		played amt != 0				(1b)
			if 1, played amt		(16b)
	}

	remove trailing 0s
	conv to b64
					
]]