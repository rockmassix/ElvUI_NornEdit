local E = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

-- Optimized imports - only what we need
local GetCombatRating = GetCombatRating
local GetCombatRatingBonus = GetCombatRatingBonus

-- Constants
local CR_VERSATILITY_DAMAGE_DONE = CR_VERSATILITY_DAMAGE_DONE
local VERSA_COLOR = "|cffbfbfbf" -- Silver

-- Optimized number formatting
local function FormatNumber(value)
    local rounded = math.floor((value + 500) / 1000) * 1000
    if rounded >= 1000000 then
        return ("%.0fM"):format(rounded / 1000000)
    elseif rounded >= 1000 then
        return ("%.0fK"):format(rounded / 1000)
    else
        return ("%.0f"):format(rounded)
    end
end

local function OnEvent(self)
    local versatilityBonus = GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE)
    local versatilityRating = GetCombatRating(CR_VERSATILITY_DAMAGE_DONE)
    local formattedValue = FormatNumber(versatilityRating)
    
    self.text:SetFormattedText('%s%s (%.0f%%) Versa|r', VERSA_COLOR, formattedValue, versatilityBonus)
end

-- Simplified tooltip
local function OnEnter()
    DT.tooltip:ClearLines()
    DT.tooltip:AddLine("|cffFFFFFFVersatility:|r |cffFFFFFF" .. GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) .. "%|r")
    DT.tooltip:AddLine("|cffFFFFFFRating:|r " .. GetCombatRating(CR_VERSATILITY_DAMAGE_DONE))
    DT.tooltip:Show()
end

-- Minimal ApplySettings to prevent db errors
local function ApplySettings()
    local db = E.db.datatexts.panels and E.db.datatexts.panels.Stats
    if db then
        db.decimalLength = db.decimalLength or 0
        db.NoLabel = db.NoLabel or false
    end
end

-- Register the Versatility datatext
DT:RegisterDatatext('NE:Versatility', nil, {'UNIT_STATS', 'UNIT_AURA', 'PLAYER_DAMAGE_DONE_MODS'}, OnEvent, nil, nil, OnEnter, nil, "NE: Versatility", ApplySettings)