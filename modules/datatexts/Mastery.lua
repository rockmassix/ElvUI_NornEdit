local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local strjoin = strjoin
local format = format
local next = next

local GetCombatRatingBonus = GetCombatRatingBonus
local GetMasteryEffect = GetMasteryEffect
local GetSpecialization = C_SpecializationInfo.GetSpecialization or GetSpecialization
local GetSpecializationMasterySpells = C_SpecializationInfo.GetSpecializationMasterySpells or GetSpecializationMasterySpells
local CreateBaseTooltipInfo = CreateBaseTooltipInfo

local STAT_MASTERY = STAT_MASTERY
local CR_MASTERY = CR_MASTERY


local function OnEnter()
	DT.tooltip:ClearLines()

	local masteryRating, bonusCoeff = GetMasteryEffect()
	local masteryBonus = (GetCombatRatingBonus(CR_MASTERY) or 0) * (bonusCoeff or 0)

	local title = format('|cffFFFFFF%s: %.2f%%|r', STAT_MASTERY, masteryRating)
	if masteryBonus > 0 then
		title = format('%s |cffFFFFFF(%.2f%%|r |cff33ff33+%.2f%%|r|cffFFFFFF)|r', title, masteryRating - masteryBonus, masteryBonus)
	end

	DT.tooltip:AddLine(title)
	DT.tooltip:AddLine(' ')

	local spec = GetSpecialization()
	if spec then
		local spells = GetSpecializationMasterySpells(spec)
		local hasSpell = false
		for _, spell in next, spells do
			if hasSpell then
				DT.tooltip:AddLine(' ')
			else
				hasSpell = true
			end

			if E.Retail then
				local tooltipInfo = CreateBaseTooltipInfo('GetSpellByID', spell)
				tooltipInfo.append = true
				DT.tooltip:ProcessInfo(tooltipInfo)
			else
				DT.tooltip:AddSpellByID(spell)
			end
		end
	end

	DT.tooltip:Show()
end

local function OnEvent(self)
	local masteryRating = GetMasteryEffect()
	
	-- Custom format: "8K (45%) Mastery" instead of "Mastery: 45%"
	local masteryCombatRating = GetCombatRating(CR_MASTERY)
	local flatValue = math.floor((masteryCombatRating + 500) / 1000) * 1000
	local formattedValue = flatValue >= 1000000 and string.format("%.0fM", flatValue / 1000000) or 
	                      flatValue >= 1000 and string.format("%.0fK", flatValue / 1000) or 
	                      string.format("%.0f", flatValue)
	self.text:SetFormattedText('%s%s (%.0f%%) Mastery|r', E:RGBToHex(0.6, 0.3, 1), formattedValue, masteryRating)
end

DT:RegisterDatatext('NE:Mastery', nil, {E.Mists and 'COMBAT_RATING_UPDATE' or 'MASTERY_UPDATE'}, OnEvent, nil, nil, OnEnter, nil, "NE: Mastery")
