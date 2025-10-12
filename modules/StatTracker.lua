local ADDON_NAME = ...
local E, L, V, P, G = unpack(ElvUI)
local NE = E:NewModule("NornEdit_StatTracker")

-- Constants
local FONT_PATH = "Interface\\AddOns\\ElvUI_NornEdit\\media\\font\\Albertus-Nova-Bold.ttf"
local FONT_SIZE = 14
local FRAME_WIDTH = 150
local FRAME_HEIGHT = 50
local FRAME_SPACING = 150
local TOTAL_WIDTH = 600

-- Stat colors (hex format)
local STAT_COLORS = {
    Crit = "e01c1c",
    Haste = "0ed59b", 
    Mastery = "9256ff",
    Versa = "bfbfbf"
}

-- Stat configuration with optimized data structure
local STATS = {
    {name = "Crit", color = STAT_COLORS.Crit, rating = CR_CRIT_MELEE, getPercent = GetCritChance},
    {name = "Haste", color = STAT_COLORS.Haste, rating = CR_HASTE_MELEE, getPercent = GetHaste},
    {name = "Mastery", color = STAT_COLORS.Mastery, rating = CR_MASTERY, getPercent = GetMastery},
    {name = "Versa", color = STAT_COLORS.Versa, rating = CR_VERSATILITY_DAMAGE_DONE, getPercent = function() return GetCombatRatingBonus(CR_VERSATILITY_DAMAGE_DONE) end}
}

-- Module state
local statTrackerFrame = nil
local statFrames = {}
local isInCombat = false

-- Optimized number formatting
local function FormatNumber(value)
    if value >= 1000000 then
        return ("%.0fM"):format(value / 1000000)
    elseif value >= 1000 then
        return ("%.0fK"):format(value / 1000)
    else
        return ("%.0f"):format(value)
    end
end

-- Create stat tracker frames
local function CreateStatTracker()
    if statTrackerFrame then return end
    
    -- Main container frame
    statTrackerFrame = CreateFrame("Frame", "NornEdit_StatTracker", UIParent)
    statTrackerFrame:SetSize(TOTAL_WIDTH, FRAME_HEIGHT)
    statTrackerFrame:SetPoint("BOTTOM", UIParent, "BOTTOM", 0, 0)
    statTrackerFrame:SetFrameStrata("MEDIUM")
    statTrackerFrame:SetFrameLevel(1)
    
    -- Create individual stat frames
    for i, stat in ipairs(STATS) do
        local statFrame = CreateFrame("Frame", nil, statTrackerFrame)
        statFrame:SetSize(FRAME_WIDTH, FRAME_HEIGHT)
        statFrame:SetPoint("LEFT", statTrackerFrame, "LEFT", (i-1) * FRAME_SPACING, 0)
        
        -- Create and configure text
        local text = statFrame:CreateFontString(nil, "OVERLAY")
        text:SetAllPoints()
        text:SetFont(FONT_PATH, FONT_SIZE)
        text:SetJustifyH("CENTER")
        text:SetJustifyV("MIDDLE")
        text:SetShadowOffset(1, -1)
        text:SetShadowColor(0, 0, 0, 0.8)
        
        statFrame.text = text
        statFrames[i] = statFrame
    end
end

-- Update stat display (optimized)
local function UpdateStats()
    if not statTrackerFrame or not statTrackerFrame:IsShown() then return end
    
    for i, stat in ipairs(STATS) do
        local statFrame = statFrames[i]
        if statFrame then
            local flatValue = GetCombatRating(stat.rating)
            local percentage = stat.getPercent()
            
            -- Round up to nearest thousand and format
            local roundedValue = math.ceil(flatValue / 1000) * 1000
            local formattedValue = FormatNumber(roundedValue)
            
            -- Set text with optimized string formatting
            statFrame.text:SetText(("|cff%s%s: %s (%.0f%%)|r"):format(
                stat.color, stat.name, formattedValue, percentage))
        end
    end
end

-- Combat state management
local function SetCombatState(inCombat)
    if isInCombat == inCombat then return end
    isInCombat = inCombat
    
    if statTrackerFrame then
        if inCombat then
            statTrackerFrame:Show()
            UpdateStats()
        else
            statTrackerFrame:Hide()
        end
    end
end

-- Optimized event handler
local function OnEvent(self, event, ...)
    if event == "PLAYER_REGEN_DISABLED" then
        SetCombatState(true)
    elseif event == "PLAYER_REGEN_ENABLED" then
        SetCombatState(false)
    elseif isInCombat and (event == "UNIT_STATS" or event == "UNIT_AURA" or event == "PLAYER_DAMAGE_DONE_MODS") then
        UpdateStats()
    end
end

-- Module initialization
function NE:Initialize()
    if not E.private["NornEdit"]["StatTracker"] then
        return
    end
    
    CreateStatTracker()
    
    -- Register only necessary events
    statTrackerFrame:RegisterEvent("PLAYER_REGEN_DISABLED")
    statTrackerFrame:RegisterEvent("PLAYER_REGEN_ENABLED")
    statTrackerFrame:RegisterEvent("UNIT_STATS")
    statTrackerFrame:RegisterEvent("UNIT_AURA")
    statTrackerFrame:RegisterEvent("PLAYER_DAMAGE_DONE_MODS")
    statTrackerFrame:SetScript("OnEvent", OnEvent)
    
    -- Start hidden
    statTrackerFrame:Hide()
    
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cffe5cc80Norn|r Edit: Stat Tracker loaded")
    end
end

-- Make module available globally
ElvUI_NornEdit_StatTracker = NE