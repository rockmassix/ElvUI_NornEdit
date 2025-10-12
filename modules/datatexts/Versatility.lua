local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local format = format
local strjoin = strjoin

local GetCombatRating = GetCombatRating
local GetCombatRatingBonus = GetCombatRatingBonus
local BreakUpLargeNumbers = BreakUpLargeNumbers

local CR_VERSATILITY_DAMAGE_DONE = CR_VERSATILITY_DAMAGE_DONE


local function OnEnter()
	DT.tooltip:ClearLines()

	local versatilityRating = GetCombatRating(CR_VERSATILITY_DAMAGE_DONE)
	local versatilityBonus = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE)

	DT.tooltip:AddLine(format('|cffFFFFFFVersatility:|r |cffFFFFFF%.2f%%|r', versatilityBonus))
	DT.tooltip:AddDoubleLine(format('Rating: %s', BreakUpLargeNumbers(versatilityRating)), format('Bonus: %.2f%%', versatilityBonus))

	DT.tooltip:Show()
end

local function OnEvent(self)
	local versatilityBonus = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE)
	
	-- Custom format: "6K (12%) Versa" instead of "Versatility: 12%"
	local versatilityRating = GetCombatRating(CR_VERSATILITY_DAMAGE_DONE)
	local flatValue = math.floor((versatilityRating + 500) / 1000) * 1000
	local formattedValue = flatValue >= 1000000 and string.format("%.0fM", flatValue / 1000000) or 
	                      flatValue >= 1000 and string.format("%.0fK", flatValue / 1000) or 
	                      string.format("%.0f", flatValue)
	self.text:SetFormattedText('%s%s (%.0f%%) Versa|r', E:RGBToHex(0.7, 0.7, 0.7), formattedValue, versatilityBonus)
end

DT:RegisterDatatext('NE:Versatility', nil, { 'UNIT_STATS', 'UNIT_AURA', 'PLAYER_DAMAGE_DONE_MODS'}, OnEvent, nil, nil, OnEnter, nil, "NE: Versatility")
