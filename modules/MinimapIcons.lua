local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

-- Icon mapping for each datatext type
local ICON_MAP = {
    ["Location"] = "poi-town",
    ["NE:FPS"] = "poi-scrapper",
    ["NE:MS"] = "FlightMaster",
    ["NE:Dura"] = "Repair",
    ["Time"] = "ChromieTime-32x32",
    ["Bags"] = "VignetteLoot",
}

-- Store icon frames for cleanup
local iconFrames = {}

-- Configuration
local ICON_SIZE = 24
local ICON_SPACING = 5

-- Clean up existing icons
local function CleanupIcons()
    for _, iconFrame in pairs(iconFrames) do
        if iconFrame then
            iconFrame:Hide()
            iconFrame:SetParent(nil)
        end
    end
    wipe(iconFrames)
end

-- Create icon for a datatext
local function CreateIcon(datatextFrame, datatextName)
    if not datatextFrame or not datatextFrame.text then
        return
    end
    
    local iconName = ICON_MAP[datatextName]
    if not iconName then
        return
    end
    
    -- Create icon frame
    local iconFrame = CreateFrame("Frame", nil, datatextFrame)
    iconFrame:SetSize(ICON_SIZE, ICON_SIZE)
    iconFrame:SetPoint("LEFT", datatextFrame.text, "RIGHT", ICON_SPACING, 0)
    iconFrame:SetFrameLevel(datatextFrame:GetFrameLevel() + 1)
    
    -- Create icon texture
    local icon = iconFrame:CreateTexture(nil, "ARTWORK")
    icon:SetAllPoints()
    
    -- Try to set the atlas, with fallback for errors
    local success = pcall(function()
        icon:SetAtlas(iconName, true)
    end)
    
    if not success then
        -- Fallback: try as texture file
        icon:SetTexture("Interface\\AddOns\\ElvUI\\Core\\Media\\Textures\\White")
        icon:SetVertexColor(1, 1, 1, 0.5)
    end
    
    iconFrame:Show()
    
    -- Store reference
    table.insert(iconFrames, iconFrame)
    
    return iconFrame
end

-- Find and add icons to Minimap panel datatexts
local function AddIconsToMinimapPanel()
    -- Check if module is enabled
    if not E.private["NornEdit"] or not E.private["NornEdit"]["minimapIcons"] then
        return
    end
    
    -- Clean up any existing icons first
    CleanupIcons()
    
    -- Get the Minimap panel configuration
    local panelConfig = E.db.datatexts.panels["Minimap"]
    if not panelConfig or not panelConfig.enable then
        return
    end
    
    -- Get the actual panel frame
    local panelFrame = DT.RegisteredPanels["Minimap"]
    if not panelFrame then
        return
    end
    
    -- Iterate through each datatext point (1-6)
    for i = 1, panelConfig.numPoints or 6 do
        local datatextName = panelConfig[i]
        if datatextName and datatextName ~= "" then
            -- Find the datatext frame
            local datatextFrame = panelFrame.dataPanels[i]
            if datatextFrame then
                CreateIcon(datatextFrame, datatextName)
            end
        end
    end
end

-- Initialize the module
local function Initialize()
    -- Check if enabled
    if not E.private["NornEdit"] or not E.private["NornEdit"]["minimapIcons"] then
        return
    end
    
    -- Wait for DataTexts to be fully loaded
    if not DT.Initialized then
        C_Timer.After(1, Initialize)
        return
    end
    
    -- Add icons with a slight delay to ensure frames are ready
    C_Timer.After(0.5, AddIconsToMinimapPanel)
    
    -- Hook panel updates to refresh icons
    hooksecurefunc(DT, 'LoadDataTexts', function()
        C_Timer.After(0.1, AddIconsToMinimapPanel)
    end)
end

-- Start initialization on PLAYER_ENTERING_WORLD
local eventFrame = CreateFrame("Frame")
eventFrame:RegisterEvent("PLAYER_ENTERING_WORLD")
eventFrame:SetScript("OnEvent", function(self, event)
    if event == "PLAYER_ENTERING_WORLD" then
        self:UnregisterEvent("PLAYER_ENTERING_WORLD")
        Initialize()
    end
end)

