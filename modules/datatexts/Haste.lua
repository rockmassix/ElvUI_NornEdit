local E = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

-- Optimized imports - only what we need
local GetCombatRating = GetCombatRating
local GetHaste = GetHaste

-- Constants
local CR_HASTE_MELEE = CR_HASTE_MELEE
local HASTE_COLOR = "|cff0ed59b" -- Teal

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
    local haste = GetHaste()
    local hasteRating = GetCombatRating(CR_HASTE_MELEE)
    local formattedValue = FormatNumber(hasteRating)
    
    self.text:SetFormattedText('%s%s (%.0f%%) Haste|r', HASTE_COLOR, formattedValue, haste)
end

-- Simplified tooltip
local function OnEnter()
    DT.tooltip:ClearLines()
    DT.tooltip:AddLine("|cffFFFFFFHaste:|r |cffFFFFFF" .. GetHaste() .. "%|r")
    DT.tooltip:AddLine("|cffFFFFFFRating:|r " .. GetCombatRating(CR_HASTE_MELEE))
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

-- Register the Haste datatext
DT:RegisterDatatext('NE:Haste', nil, {'UNIT_STATS', 'UNIT_SPELL_HASTE', 'UNIT_AURA'}, OnEvent, nil, nil, OnEnter, nil, "NE: Haste", ApplySettings)