local E = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

-- Optimized imports - only what we need
local GetCombatRating = GetCombatRating
local GetMasteryEffect = GetMasteryEffect

-- Constants
local CR_MASTERY = CR_MASTERY
local MASTERY_COLOR = "|cff9256ff" -- Purple

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
    local masteryRating = GetMasteryEffect()
    local masteryCombatRating = GetCombatRating(CR_MASTERY)
    local formattedValue = FormatNumber(masteryCombatRating)
    
    self.text:SetFormattedText('%s%s (%.0f%%) Mastery|r', MASTERY_COLOR, formattedValue, masteryRating)
end

-- Simplified tooltip
local function OnEnter()
    DT.tooltip:ClearLines()
    DT.tooltip:AddLine("|cffFFFFFFMastery:|r |cffFFFFFF" .. GetMasteryEffect() .. "%|r")
    DT.tooltip:AddLine("|cffFFFFFFRating:|r " .. GetCombatRating(CR_MASTERY))
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

-- Register the Mastery datatext
DT:RegisterDatatext('NE:Mastery', nil, {'MASTERY_UPDATE'}, OnEvent, nil, nil, OnEnter, nil, "NE: Mastery", ApplySettings)