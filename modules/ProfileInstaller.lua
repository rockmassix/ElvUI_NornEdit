local E, L, V, P, G = unpack(ElvUI)
local EP = LibStub("LibElvUIPlugin-1.0")
local addon, ns = ...

-- Plugin Information
local MyPluginName = "Norn Edit"
local Version = C_AddOns.GetAddOnMetadata("ElvUI_NornEdit", "Version") or "0.3.7"

-- Create module
local mod = E:NewModule("NornEditInstaller")

-- Get the profile string importer
local PSI = ElvUI_NornEdit_ProfileImporter

-- Get profile strings
local function GetProfiles()
    return ElvUI_NornEdit_Profiles or {}
end

-- Function to setup ElvUI layout
local function SetupElvUI()
    local profiles = GetProfiles()
    
    -- Check if at least one ElvUI string is provided
    if (not profiles.ElvUI_Profile or profiles.ElvUI_Profile == "") and
       (not profiles.ElvUI_Global or profiles.ElvUI_Global == "") and
       (not profiles.ElvUI_Private or profiles.ElvUI_Private == "") then
        print("|cffe5cc80Norn|r Edit: No ElvUI profile strings found. Please add them to profiles/ElvUI.lua")
        return false
    end
    
    if not PSI then
        print("|cffe5cc80Norn|r Edit: Profile importer not loaded")
        return false
    end
    
    -- Import all ElvUI settings (profile + global + private)
    local success, results = PSI:ImportElvUIComplete(profiles)
    if not success then
        print("|cffe5cc80Norn|r Edit: ElvUI import failed")
        if type(results) == "table" then
            for key, value in pairs(results) do
                print("  " .. key .. ": " .. tostring(value))
            end
        end
        return false
    end
    
    -- Ensure NornEdit modules are enabled by default
    if not E.private["NornEdit"] then
        E.private["NornEdit"] = {}
    end
    E.private["NornEdit"]["SquircleMinimap"] = true
    E.private["NornEdit"]["minimapIcons"] = true
    E.private["NornEdit"]["SimpleChatBackdrop"] = true
    
    -- Update ElvUI
    E:StaggeredUpdateAll()
    
    return true
end

-- Function to setup Details
local function SetupDetails()
    if not C_AddOns.IsAddOnLoaded("Details") then
        return false, "Not loaded"
    end
    
    local profiles = GetProfiles()
    if not profiles.Details or profiles.Details == "" then
        return false, "No profile string"
    end
    
    if not PSI then
        return false, "Importer not loaded"
    end
    
    return PSI:ImportProfile("Details", profiles.Details)
end

-- Function to setup Plater
local function SetupPlater()
    if not C_AddOns.IsAddOnLoaded("Plater") then
        return false, "Not loaded"
    end
    
    local profiles = GetProfiles()
    if not profiles.Plater or profiles.Plater == "" then
        return false, "No profile string"
    end
    
    if not PSI then
        return false, "Importer not loaded"
    end
    
    return PSI:ImportProfile("Plater", profiles.Plater)
end

-- Function to setup WeakAuras
local function SetupWeakAuras()
    if not C_AddOns.IsAddOnLoaded("WeakAuras") then
        return false, "Not loaded"
    end
    
    local profiles = GetProfiles()
    if not profiles.WeakAuras or profiles.WeakAuras == "" then
        return false, "No profile string"
    end
    
    if not PSI then
        return false, "Importer not loaded"
    end
    
    -- Handle both single string and table of strings
    if type(profiles.WeakAuras) == "table" then
        for _, waString in ipairs(profiles.WeakAuras) do
            local success, err = PSI:ImportProfile("WeakAuras", waString)
            if not success then
                return false, err
            end
        end
        return true
    else
        return PSI:ImportProfile("WeakAuras", profiles.WeakAuras)
    end
end

-- Function executed when installation is complete
local function InstallComplete()
    if GetCVarBool("Sound_EnableMusic") then
        StopMusic()
    end
    
    -- Set version tracking
    E.db[MyPluginName] = E.db[MyPluginName] or {}
    E.db[MyPluginName].install_version = Version
    
    ReloadUI()
end

-- Installer Data Structure
local InstallerData = {
    Title = format("|cffe5cc80%s %s|r", MyPluginName, "Installation"),
    Name = MyPluginName,
    tutorialImage = "Interface\\AddOns\\ElvUI_NornEdit\\media\\logo.png",
    Pages = {
        [1] = function()
            PluginInstallFrame.SubTitle:SetFormattedText("Welcome to %s", MyPluginName)
            PluginInstallFrame.Desc1:SetText("This installation process will apply profiles for ElvUI and other supported addons.")
            PluginInstallFrame.Desc2:SetText("Click 'Continue' to begin the installation process.")
            PluginInstallFrame.Desc3:SetText("Click 'Skip Process' to exit without making changes.")
            PluginInstallFrame.Option1:Show()
            PluginInstallFrame.Option1:SetScript("OnClick", InstallComplete)
            PluginInstallFrame.Option1:SetText("Skip Process")
        end,
        [2] = function()
            PluginInstallFrame.SubTitle:SetText("ElvUI Profile")
            PluginInstallFrame.Desc1:SetText("Apply the Norn Edit ElvUI profile.")
            PluginInstallFrame.Desc2:SetText("This will import all ElvUI settings including frames, datatexts, and styling.")
            PluginInstallFrame.Desc3:SetText("Importance: |cff07D400High|r")
            PluginInstallFrame.Option1:Show()
            PluginInstallFrame.Option1:SetScript("OnClick", function()
                if SetupElvUI() then
                    PluginInstallStepComplete.message = "ElvUI Profile Applied"
                    PluginInstallStepComplete:Show()
                end
            end)
            PluginInstallFrame.Option1:SetText("Apply ElvUI Profile")
        end,
        [3] = function()
            PluginInstallFrame.SubTitle:SetText("Details (Optional)")
            
            if not C_AddOns.IsAddOnLoaded("Details") then
                PluginInstallFrame.Desc1:SetText("Details addon is not loaded.")
                PluginInstallFrame.Desc2:SetText("Enable Details to use this feature.")
                return
            end
            
            local profiles = GetProfiles()
            if not profiles.Details or profiles.Details == "" then
                PluginInstallFrame.Desc1:SetText("No Details profile string configured.")
                PluginInstallFrame.Desc2:SetText("Add a profile string to profiles/Details.lua to enable this.")
                return
            end
            
            PluginInstallFrame.Desc1:SetText("Apply the Norn Edit Details profile.")
            PluginInstallFrame.Desc2:SetText("This will configure your Details damage meter.")
            PluginInstallFrame.Option1:Show()
            PluginInstallFrame.Option1:SetScript("OnClick", function()
                local success, err = SetupDetails()
                if success then
                    PluginInstallStepComplete.message = "Details Profile Applied"
                    PluginInstallStepComplete:Show()
                else
                    PluginInstallStepComplete.message = "Details Failed: " .. tostring(err)
                    PluginInstallStepComplete:Show()
                end
            end)
            PluginInstallFrame.Option1:SetText("Apply Details Profile")
        end,
        [4] = function()
            PluginInstallFrame.SubTitle:SetText("Plater (Optional)")
            
            if not C_AddOns.IsAddOnLoaded("Plater") then
                PluginInstallFrame.Desc1:SetText("Plater addon is not loaded.")
                PluginInstallFrame.Desc2:SetText("Enable Plater to use this feature.")
                return
            end
            
            local profiles = GetProfiles()
            if not profiles.Plater or profiles.Plater == "" then
                PluginInstallFrame.Desc1:SetText("No Plater profile string configured.")
                PluginInstallFrame.Desc2:SetText("Add a profile string to profiles/Plater.lua to enable this.")
                return
            end
            
            PluginInstallFrame.Desc1:SetText("Apply the Norn Edit Plater profile.")
            PluginInstallFrame.Desc2:SetText("This will configure your Plater nameplates.")
            PluginInstallFrame.Option1:Show()
            PluginInstallFrame.Option1:SetScript("OnClick", function()
                local success, err = SetupPlater()
                if success then
                    PluginInstallStepComplete.message = "Plater Profile Applied"
                    PluginInstallStepComplete:Show()
                else
                    PluginInstallStepComplete.message = "Plater Failed: " .. tostring(err)
                    PluginInstallStepComplete:Show()
                end
            end)
            PluginInstallFrame.Option1:SetText("Apply Plater Profile")
        end,
        [5] = function()
            PluginInstallFrame.SubTitle:SetText("WeakAuras (Optional)")
            
            if not C_AddOns.IsAddOnLoaded("WeakAuras") then
                PluginInstallFrame.Desc1:SetText("WeakAuras addon is not loaded.")
                PluginInstallFrame.Desc2:SetText("Enable WeakAuras to use this feature.")
                return
            end
            
            local profiles = GetProfiles()
            if not profiles.WeakAuras or profiles.WeakAuras == "" then
                PluginInstallFrame.Desc1:SetText("No WeakAuras profile strings configured.")
                PluginInstallFrame.Desc2:SetText("Add profile strings to profiles/WeakAuras.lua to enable this.")
                return
            end
            
            PluginInstallFrame.Desc1:SetText("Import Norn Edit WeakAuras.")
            PluginInstallFrame.Desc2:SetText("This will import configured WeakAuras.")
            PluginInstallFrame.Option1:Show()
            PluginInstallFrame.Option1:SetScript("OnClick", function()
                local success, err = SetupWeakAuras()
                if success then
                    PluginInstallStepComplete.message = "WeakAuras Imported"
                    PluginInstallStepComplete:Show()
                else
                    PluginInstallStepComplete.message = "WeakAuras Failed: " .. tostring(err)
                    PluginInstallStepComplete:Show()
                end
            end)
            PluginInstallFrame.Option1:SetText("Import WeakAuras")
        end,
        [6] = function()
            PluginInstallFrame.SubTitle:SetText("Installation Complete")
            PluginInstallFrame.Desc1:SetText("You have completed the installation process.")
            PluginInstallFrame.Desc2:SetText("Please click 'Finished' to reload your UI and apply all changes.")
            PluginInstallFrame.Option1:Show()
            PluginInstallFrame.Option1:SetScript("OnClick", InstallComplete)
            PluginInstallFrame.Option1:SetText("Finished")
        end,
    },
    StepTitles = {
        [1] = "Welcome",
        [2] = "ElvUI",
        [3] = "Details",
        [4] = "Plater",
        [5] = "WeakAuras",
        [6] = "Complete",
    },
    StepTitlesColor = {1, 1, 1},
    StepTitlesColorSelected = {0, 179/255, 1},
    StepTitleWidth = 200,
    StepTitleButtonWidth = 180,
    StepTitleTextJustification = "RIGHT",
}

-- Create unique table for plugin
P[MyPluginName] = {}

-- Initialize function
function mod:Initialize()
    -- Check if installation is needed
    local needsInstall = false
    
    -- Check if ElvUI install is complete
    if E.private.install_complete then
        -- Check if version tracking exists
        local versionExists = E.db[MyPluginName] and E.db[MyPluginName].install_version
        
        -- Only install if version tracking doesn't exist (first install)
        if not versionExists then
            needsInstall = true
        end
    end
    
    -- Initiate installation process if needed
    if needsInstall then
        E:GetModule("PluginInstaller"):Queue(InstallerData)
    end
end

-- Export InstallerData for main module
ElvUI_NornEdit_InstallerData = InstallerData

-- Register module
E:RegisterModule(mod:GetName())
