local E = unpack(ElvUI)
if not E then return end

local PSI = {}

-- Import ElvUI profile using Distributor
-- Can handle profile, global, or private strings
function PSI:ImportElvUI(profileString, profileName)
    if not E.Distributor then
        return false, "ElvUI Distributor not available"
    end
    
    profileName = profileName or "Norn Edit"
    
    local D = E.Distributor
    local ProfileType, _, data = D:Decode(profileString)
    
    if not data or type(data) ~= "table" then
        return false, "Failed to decode ElvUI profile string"
    end
    
    -- Import the profile with the specified name
    -- ProfileType will be "profile", "global", or "private"
    D:SetImportedProfile(ProfileType, profileName, data, true)
    
    return true, ProfileType
end

-- Import all ElvUI settings (profile + global + private)
function PSI:ImportElvUIComplete(profiles)
    local results = {}
    local profileName = "Norn Edit"
    
    -- Import profile settings (db.profiles)
    if profiles.ElvUI_Profile and profiles.ElvUI_Profile ~= "" then
        local success, typeOrErr = self:ImportElvUI(profiles.ElvUI_Profile, profileName)
        if success then
            results.profile = "Success (" .. tostring(typeOrErr) .. ")"
        else
            results.profile = "Failed: " .. tostring(typeOrErr)
            return false, results
        end
    end
    
    -- Import global settings (db.global)
    if profiles.ElvUI_Global and profiles.ElvUI_Global ~= "" then
        local success, typeOrErr = self:ImportElvUI(profiles.ElvUI_Global, profileName)
        if success then
            results.global = "Success (" .. tostring(typeOrErr) .. ")"
        else
            results.global = "Failed: " .. tostring(typeOrErr)
            return false, results
        end
    end
    
    -- Import private settings (db.private)
    if profiles.ElvUI_Private and profiles.ElvUI_Private ~= "" then
        local success, typeOrErr = self:ImportElvUI(profiles.ElvUI_Private, profileName)
        if success then
            results.private = "Success (" .. tostring(typeOrErr) .. ")"
        else
            results.private = "Failed: " .. tostring(typeOrErr)
            return false, results
        end
    end
    
    return true, results
end

-- Import Details profile
function PSI:ImportDetails(profileString)
    if not _detalhes then
        return false, "Details addon not loaded"
    end
    
    -- Details uses its own import system
    -- The import string should be applied via Details' import function
    local success, errorMsg = pcall(function()
        _detalhes:ApplyProfile(profileString, "Norn Edit")
    end)
    
    if not success then
        return false, "Details import failed: " .. tostring(errorMsg)
    end
    
    return true
end

-- Import Plater profile
function PSI:ImportPlater(profileString)
    if not Plater then
        return false, "Plater addon not loaded"
    end
    
    -- Plater uses its own import system
    local success, errorMsg = pcall(function()
        Plater.ImportProfileString(profileString)
    end)
    
    if not success then
        return false, "Plater import failed: " .. tostring(errorMsg)
    end
    
    return true
end

-- Import WeakAuras
function PSI:ImportWeakAuras(profileString)
    if not WeakAuras then
        return false, "WeakAuras addon not loaded"
    end
    
    -- WeakAuras uses ImportString for encoded strings
    local success, errorMsg = pcall(function()
        WeakAuras.ImportString(profileString)
    end)
    
    if not success then
        return false, "WeakAuras import failed: " .. tostring(errorMsg)
    end
    
    return true
end

-- Main import function
function PSI:ImportProfile(addon, profileString)
    if not profileString or profileString == "" then
        return false, "Profile string is empty"
    end
    
    if addon == "ElvUI" then
        return self:ImportElvUI(profileString)
    elseif addon == "Details" then
        return self:ImportDetails(profileString)
    elseif addon == "Plater" then
        return self:ImportPlater(profileString)
    elseif addon == "WeakAuras" then
        return self:ImportWeakAuras(profileString)
    end
    
    return false, "Unknown addon: " .. tostring(addon)
end

-- Check if addon is available
function PSI:IsAddonAvailable(addon)
    if addon == "ElvUI" then
        return E ~= nil
    elseif addon == "Details" then
        return _detalhes ~= nil
    elseif addon == "Plater" then
        return Plater ~= nil
    elseif addon == "WeakAuras" then
        return WeakAuras ~= nil
    end
    return false
end

-- Export the module globally
ElvUI_NornEdit_ProfileImporter = PSI

