local ADDON_NAME = ...
local E, L, V, P, G = unpack(ElvUI)
local NE = E:NewModule("NornEdit_SharedMedia")

-- Check if LibSharedMedia-3.0 is available
local LSM = LibStub("LibSharedMedia-3.0", true)
if not LSM then
    return -- Exit if LibSharedMedia-3.0 is not available
end

-- Utility function to get asset path
local function GetAsset(path)
    return ("Interface\\AddOns\\%s\\%s"):format(ADDON_NAME, path)
end

function NE:Initialize()
    -- Check if SharedMedia is enabled in settings
    if not E.private["NornEdit"]["SharedMedia"] then
        return
    end
    
    -- Register fonts
    LSM:Register("font", "Gilroy Bold", GetAsset("media\\font\\Gilroy-Bold.ttf"))
    LSM:Register("font", "Gilroy Regular", GetAsset("media\\font\\Gilroy-Regular.ttf"))
    LSM:Register("font", "Naowh", GetAsset("media\\font\\Naowh.ttf"))
    LSM:Register("font", "Albertus Bold", GetAsset("media\\font\\Albertusnova-bold.ttf"))
    
    -- Register statusbars
    LSM:Register("statusbar", "Norn", GetAsset("media\\statusbar\\Norn.tga"))
    LSM:Register("statusbar", "Norn Back", GetAsset("media\\statusbar\\Norn2.tga"))
    LSM:Register("statusbar", "Norn Half", GetAsset("media\\statusbar\\NornHalf.tga"))
    LSM:Register("statusbar", "Grey", GetAsset("media\\statusbar\\Grey.tga"))
    
    -- Register borders
    LSM:Register("border", "borderish", GetAsset("media\\background\\borderish.tga"))
    
    -- Print confirmation
    if DEFAULT_CHAT_FRAME then
        DEFAULT_CHAT_FRAME:AddMessage("|cffe5cc80Norn|r Edit: SharedMedia registrations completed")
    end
end

-- Make the module available globally for other modules
ElvUI_NornEdit_SharedMedia = NE
