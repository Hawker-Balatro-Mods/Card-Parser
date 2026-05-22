local bit = require("bit")
local Converter = {}

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
function Converter.compileHand(jokers, cards)
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
		joinTables(binary, intToBinary(0, 1))

		--sell value (1+16)
		joinTables(binary, sellToBinary(joker))
	end

	--num of play cards (16b)
	joinTables(binary, intToBinary(#cards, 16))

	--num of selected cards (3b) [!]
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

	--more with flint and shit [!]

	--remove trailing 0s
	while binary[#binary] == false do table.remove(binary, #binary) end
	
	print("URL: " .. binaryToBase64(binary))
end


--Card based functions
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

	if(card.base_cost == 20) then --legendary jokers use a slighly different table
		ypos = 8
		xpos = xpos + 3	
	end
	
	local bin = intToBinary(ypos, 4)
	joinTables(bin, intToBinary(xpos, 4))
	return bin
end

function sellToBinary(card)
	if(math.floor(card.base_cost/2)	 == card.sell_cost ) then return{false} end;
	return intToBinary(card.sell_cost*2+1, 17)
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
		if 1, hand lvl-1[?]					(16b)
	}
		
		
	The_Eye disables or handcount != 0	(1b)
	if 1, foreach hand type {
		The_Eye played the round?		(1b)
		played amt != 0					(1b)
		if 1, played amt				(16b)
	}
		
	remove trailing 0s
	conv to b64
					
]]