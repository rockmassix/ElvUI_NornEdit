local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local min = min
local format = format
local strjoin = strjoin

local BreakUpLargeNumbers = BreakUpLargeNumbers
local GetCombatRating = GetCombatRating
local GetCombatRatingBonus = GetCombatRatingBonus
local GetSpellCritChance = GetSpellCritChance
local GetCritChance = GetCritChance
local GetRangedCritChance = GetRangedCritChance

local CRIT_ABBR = CRIT_ABBR

local MELEE_CRIT_CHANCE = MELEE_CRIT_CHANCE
local MAX_SPELL_SCHOOLS = MAX_SPELL_SCHOOLS or 7
local CR_CRIT_MELEE = CR_CRIT_MELEE
local CR_CRIT_SPELL = CR_CRIT_SPELL
local CR_CRIT_RANGED = CR_CRIT_RANGED
local CR_CRIT_TOOLTIP = CR_CRIT_TOOLTIP

local meleeCrit, rangedCrit, ratingIndex = 0, 0

local function OnEnter()
	DT.tooltip:ClearLines()

	if E.Classic then
		DT.tooltip:AddLine(format('|cffFFFFFF%s:|r %.2f%%', MELEE_CRIT_CHANCE, meleeCrit))
	else
		local critical = GetCombatRating(ratingIndex)

		DT.tooltip:AddLine(format('|cffFFFFFF%s:|r |cffFFFFFF%.2f%%|r', MELEE_CRIT_CHANCE, meleeCrit))
		DT.tooltip:AddDoubleLine(format(CR_CRIT_TOOLTIP, BreakUpLargeNumbers(critical) , GetCombatRatingBonus(ratingIndex)))
	end

	DT.tooltip:Show()
end

local function OnEvent(self)
	local spellCrit, critChance

	local holySchool = 2 -- start at 2 to skip physical damage
	local minCrit = GetSpellCritChance(holySchool)
	for i = (holySchool + 1), MAX_SPELL_SCHOOLS do
		spellCrit = GetSpellCritChance(i)
		minCrit = min(minCrit, spellCrit)
	end

	spellCrit = minCrit
	rangedCrit = GetRangedCritChance()
	meleeCrit = GetCritChance()

	if (spellCrit >= rangedCrit and spellCrit >= meleeCrit) then
		critChance = spellCrit
		ratingIndex = CR_CRIT_SPELL
	elseif (rangedCrit >= meleeCrit) then
		critChance = rangedCrit
		ratingIndex = CR_CRIT_RANGED
	else
		critChance = meleeCrit
		ratingIndex = CR_CRIT_MELEE
	end

	-- Custom format: "16K (25%) Crit" instead of "Crit: 25%"
	local critical = GetCombatRating(ratingIndex)
	local flatValue = math.floor((critical + 500) / 1000) * 1000
	local formattedValue = flatValue >= 1000000 and string.format("%.0fM", flatValue / 1000000) or 
	                      flatValue >= 1000 and string.format("%.0fK", flatValue / 1000) or 
	                      string.format("%.0f", flatValue)
	self.text:SetFormattedText('%s%s (%.0f%%) Crit|r', E:RGBToHex(1, 0, 0), formattedValue, critChance)
end

DT:RegisterDatatext('NE:Crit', nil, { 'UNIT_STATS', 'UNIT_AURA', 'PLAYER_DAMAGE_DONE_MODS'}, OnEvent, nil, nil, OnEnter, nil, "NE: Crit")
