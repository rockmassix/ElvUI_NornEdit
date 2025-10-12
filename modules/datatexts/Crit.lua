local E = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

-- Optimized imports - only what we need
local GetCombatRating = GetCombatRating
local GetCritChance = GetCritChance

-- Constants
local CR_CRIT_MELEE = CR_CRIT_MELEE
local CRIT_COLOR = "|cffe01c1c" -- Red

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
    local critChance = GetCritChance()
    local critRating = GetCombatRating(CR_CRIT_MELEE)
    local formattedValue = FormatNumber(critRating)
    
    self.text:SetFormattedText('%s%s (%.0f%%) Crit|r', CRIT_COLOR, formattedValue, critChance)
end

-- Simplified tooltip
local function OnEnter()
    DT.tooltip:ClearLines()
    DT.tooltip:AddLine("|cffFFFFFFCrit:|r |cffFFFFFF" .. GetCritChance() .. "%|r")
    DT.tooltip:AddLine("|cffFFFFFFRating:|r " .. GetCombatRating(CR_CRIT_MELEE))
    DT.tooltip:Show()
end

-- Register the Crit datatext (no ApplySettings = no customization tab)
DT:RegisterDatatext('NE:Crit', nil, {'UNIT_STATS', 'UNIT_AURA', 'PLAYER_DAMAGE_DONE_MODS'}, OnEvent, nil, nil, OnEnter, nil, "NE: Crit")