local E, L, V, P, G = unpack(ElvUI)
local EP = LibStub("LibElvUIPlugin-1.0")
local addon, ns = ...

-- Plugin Information
local MyPluginName = "Norn Edit"
local Version = C_AddOns.GetAddOnMetadata("ElvUI_NornEdit", "Version") or "0.3.7"

-- Create module
local mod = E:NewModule("NornEditInstaller")

-- Profile Data (loaded from profiles/elvui.lua)
local ProfileData = ElvUI_NornEdit_ProfileData or {
    -- Fallback if profile data file is not loaded
    profileKeys = {},
    profiles = {},
    private = {},
}

-- Function to setup the layout
local function SetupLayout()
    -- Apply the profile data
    if ProfileData.profileKeys then
        -- Ensure E.data.profileKeys exists
        if not E.data.profileKeys then
            E.data.profileKeys = {}
        end
        for character, profile in pairs(ProfileData.profileKeys) do
            E.data.profileKeys[character] = profile
        end
    end
    
    if ProfileData.profiles then
        -- Ensure E.data.profiles exists
        if not E.data.profiles then
            E.data.profiles = {}
        end
        for profileName, profileData in pairs(ProfileData.profiles) do
            E.data.profiles[profileName] = profileData
        end
    end
    
    if ProfileData.private then
        -- Private settings are global in ElvUI - replace with Norn Edit settings
        -- Check if private data has profile structure or direct settings
        if ProfileData.private["Norn Edit"] then
            -- Private data is structured with profile names - replace global private
            for key, value in pairs(ProfileData.private["Norn Edit"]) do
                E.private[key] = value
            end
        else
            -- Private data is direct settings (current structure)
            for key, value in pairs(ProfileData.private) do
                E.private[key] = value
            end
        end
    end
    
    -- Ensure NornEdit modules are enabled by default
    if not E.private["NornEdit"] then
        E.private["NornEdit"] = {}
    end
    E.private["NornEdit"]["SquircleMinimap"] = true
    E.private["NornEdit"]["minimapIcons"] = true
    
    -- Delay global settings application to avoid SetFrameStrata errors
    C_Timer.After(0.1, function()
        if ProfileData.global then
            -- Global settings are account-wide in ElvUI
            -- Ensure E.global exists
            if not E.global then
                E.global = {}
            end
            for key, value in pairs(ProfileData.global) do
                E.global[key] = value
            end
        end
    end)
    
    -- Set current profile
    local currentProfile = ProfileData.profileKeys and ProfileData.profileKeys[E.myname.." - "..E.myrealm]
    if currentProfile then
        E.data:SetProfile(currentProfile)
    else
        -- If no profile key mapping, use the first available profile
        local firstProfile = next(ProfileData.profiles)
        if firstProfile then
            E.data:SetProfile(firstProfile)
            -- Also add this character to the profileKeys for future use
            if ProfileData.profileKeys then
                ProfileData.profileKeys[E.myname.." - "..E.myrealm] = firstProfile
            end
        end
    end
    
    -- Update ElvUI
    E:StaggeredUpdateAll()
    
    -- Show completion message
    PluginInstallStepComplete.message = "Layout Set"
    PluginInstallStepComplete:Show()
end

-- Function executed when installation is complete
local function InstallComplete()
    if GetCVarBool("Sound_EnableMusic") then
        StopMusic()
    end
    
    -- Set version tracking
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
            PluginInstallFrame.SubTitle:SetFormattedText("Welcome to the installation for %s.", MyPluginName)
            PluginInstallFrame.Desc1:SetText("This installation process will guide you through applying the Norn Edit layout to your current ElvUI profile. If you want to be able to go back to your original settings then create a new profile before going through this installation process.")
            PluginInstallFrame.Desc2:SetText("Please press the continue button if you wish to go through the installation process, otherwise click the 'Skip Process' button.")
            PluginInstallFrame.Option1:Show()
            PluginInstallFrame.Option1:SetScript("OnClick", InstallComplete)
            PluginInstallFrame.Option1:SetText("Skip Process")
        end,
        [2] = function()
            PluginInstallFrame.SubTitle:SetText("Apply Layout")
            PluginInstallFrame.Desc1:SetText("This will apply the Norn Edit layout to your current ElvUI profile.")
            PluginInstallFrame.Desc2:SetText("Importance: |cff07D400High|r")
            PluginInstallFrame.Option1:Show()
            PluginInstallFrame.Option1:SetScript("OnClick", SetupLayout)
            PluginInstallFrame.Option1:SetText("Apply Norn Edit Layout")
        end,
        [3] = function()
            PluginInstallFrame.SubTitle:SetText("Installation Complete")
            PluginInstallFrame.Desc1:SetText("You have completed the installation process.")
            PluginInstallFrame.Desc2:SetText("Please click the button below in order to finalize the process and automatically reload your UI.")
            PluginInstallFrame.Option1:Show()
            PluginInstallFrame.Option1:SetScript("OnClick", InstallComplete)
            PluginInstallFrame.Option1:SetText("Finished")
        end,
    },
    StepTitles = {
        [1] = "Welcome",
        [2] = "Apply Layout",
        [3] = "Installation Complete",
    },
    StepTitlesColor = {1, 1, 1},
    StepTitlesColorSelected = {0, 179/255, 1},
    StepTitleWidth = 200,
    StepTitleButtonWidth = 180,
    StepTitleTextJustification = "RIGHT",
}

-- Options table for ElvUI config
local function InsertOptions()
    E.Options.args.NornEditInstaller = {
        order = 100,
        type = "group",
        name = format("|cffe5cc80%s|r", MyPluginName),
        args = {
            header1 = {
                order = 1,
                type = "header",
                name = MyPluginName,
            },
            description1 = {
                order = 2,
                type = "description",
                name = format("%s is a layout installer for ElvUI.", MyPluginName),
            },
            spacer1 = {
                order = 3,
                type = "description",
                name = "\n\n\n",
            },
            header2 = {
                order = 4,
                type = "header",
                name = "Installation",
            },
            description2 = {
                order = 5,
                type = "description",
                name = "The installation guide should pop up automatically after you have completed the ElvUI installation. If you wish to re-run the installation process for this layout then please click the button below.",
            },
            spacer2 = {
                order = 6,
                type = "description",
                name = "",
            },
            install = {
                order = 7,
                type = "execute",
                name = "Install",
                desc = "Run the installation process.",
                func = function() 
                    E:GetModule("PluginInstaller"):Queue(InstallerData)
                    E:ToggleOptions()
                end,
            },
        },
    }
end

-- Create unique table for plugin
P[MyPluginName] = {}

-- Initialize function
function mod:Initialize()
    -- Check if installation is needed
    local needsInstall = false
    
    -- Check if ElvUI install is complete
    if E.private.install_complete then
        -- Check if "Norn Edit" profile already exists
        local nornEditProfileExists = E.data.profiles and E.data.profiles["Norn Edit"]
        
        -- Check if version tracking exists
        local versionExists = E.db[MyPluginName] and E.db[MyPluginName].install_version
        
        -- Only install if profile doesn't exist AND version tracking doesn't exist
        if not nornEditProfileExists and not versionExists then
            needsInstall = true
        end
    end
    
    -- Initiate installation process if needed
    if needsInstall then
        E:GetModule("PluginInstaller"):Queue(InstallerData)
    end
    
    -- Options are handled by the main module to avoid conflicts
end

-- Export InstallerData for main module
ElvUI_NornEdit_InstallerData = InstallerData

-- Register module
E:RegisterModule(mod:GetName())
