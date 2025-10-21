local ADDON_NAME = ...
local E, L, V, P, G = unpack(ElvUI)
local EP = LibStub("LibElvUIPlugin-1.0")
local NE = E:NewModule("NornEdit")

-- Media module will be initialized by Media.lua

local function Print(msg)
  DEFAULT_CHAT_FRAME:AddMessage("|cffe5cc80Norn|r Edit: " .. tostring(msg))
end

-- Initialize ElvUI private settings
P["NornEdit"] = {
  SquircleMinimap = true, -- Default enabled
  minimapIcons = true, -- Default enabled
  SimpleChatBackdrop = true, -- Default enabled
  overlay = {
    enabled = true,
    texture = "media\\border.blp",
    width = 256,
    height = 64,
    xOffset = 0,
    yOffset = 4,
    blend = "BLEND",
    strata = "HIGH",
  },
  minimap = {
    width = 212,
    height = 212,
    texture = "media\\border2.blp",
    mask = "media\\mask",
  }
}
V["NornEdit"] = {}

-- Utility function to get asset path
local function GetAsset(path)
  return ("Interface\\AddOns\\%s\\%s"):format(ADDON_NAME, path)
end

-- Module utility method
function NE:GetAsset(path)
  return GetAsset(path)
end

-- Get config with validation
local function GetConfig()
  local cfg = E.private["NornEdit"]
  if not cfg or not cfg.overlay then
    return P["NornEdit"]
  end
  return cfg
end

-- Simple ElvUI check
local function IsElvUILoaded()
  if C_AddOns and C_AddOns.IsAddOnLoaded then
    return C_AddOns.IsAddOnLoaded("ElvUI")
  elseif IsAddOnLoaded then
    return IsAddOnLoaded("ElvUI")
  end
  return false
end

-- Get overlay parent frame
local function getOverlayParent(frame)
  if frame and frame.RaisedElementParent and frame.RaisedElementParent.IsObjectType and frame.RaisedElementParent:IsObjectType("Frame") then
    return frame.RaisedElementParent
  end
  return frame
end

-- Clean up overlay from frame
local function removeOverlayFromFrame(frame)
  if frame and frame.NornEdit_Overlay then
    local overlay = frame.NornEdit_Overlay
    if overlay and overlay.Hide then
      overlay:Hide()
    end
    if overlay and overlay.SetTexture then
      overlay:SetTexture(nil)
    end
    frame.NornEdit_Overlay = nil
  end
end

-- Apply overlay to frame
local function applyOverlayToFrame(frame, skipVisibility)
  local cfg = GetConfig()
  if not cfg.overlay.enabled or not frame or not frame:IsObjectType("Frame") then
    return
  end
  
  -- Skip visibility check for boss, raid, party, and focus frames
  if not skipVisibility and not frame:IsVisible() then
    return
  end
  
  if frame.NornEdit_Overlay then
    return -- already applied
  end

  local parent = getOverlayParent(frame)
  if not parent then
    return
  end

  -- Validate config values
  local texturePath = GetAsset(cfg.overlay.texture)
  local width = cfg.overlay.width or 256
  local height = cfg.overlay.height or 64
  local xOffset = cfg.overlay.xOffset or 0
  local yOffset = cfg.overlay.yOffset or 4
  local blend = cfg.overlay.blend or "BLEND"
  local strata = cfg.overlay.strata or "HIGH"

  local texture = parent:CreateTexture(nil, "OVERLAY")
  texture:SetTexture(texturePath)
  texture:SetBlendMode(blend)
  texture:SetSize(width, height)
  texture:SetPoint("CENTER", parent, "CENTER", xOffset, yOffset)
  texture:Show()

  frame.NornEdit_Overlay = texture

  -- Keep on top
  if parent.SetFrameStrata and strata then
    parent:SetFrameStrata(strata)
  end
  
  -- Hook cleanup when frame is hidden (don't overwrite existing scripts)
  if not frame.NornEdit_OverlayHooked then
    frame:HookScript("OnHide", function(self)
      if self.NornEdit_Overlay then
        removeOverlayFromFrame(self)
      end
    end)
    frame.NornEdit_OverlayHooked = true
  end
end

-- Try to attach overlay to frame by name
local function tryAttachByName(name)
  local f = _G[name]
  if f then
    -- Skip visibility check for boss, raid, party, and focus frames
    local skipVisibility = string.find(name, "Boss") or string.find(name, "Raid") or string.find(name, "Party") or string.find(name, "Focus")
    applyOverlayToFrame(f, skipVisibility)
    return true
  end
  return false
end

-- Attach overlays to all frame types
local function attachAll()
  if not IsElvUILoaded() then
    return
  end
  
  -- Individual frames
  tryAttachByName("ElvUF_Player")
  tryAttachByName("ElvUF_Target")
  tryAttachByName("ElvUF_Focus")
  tryAttachByName("ElvUF_Pet")
  
  -- Boss frames
  for i = 1, 8 do
    tryAttachByName("ElvUF_Boss" .. i)
  end
  
  -- Party frames
  for i = 1, 5 do
    tryAttachByName("ElvUF_PartyGroup1UnitButton" .. i)
  end
  
  -- Raid frames
  for groupIndex = 1, 8 do
    for unitIndex = 1, 5 do
      tryAttachByName("ElvUF_Raid1Group" .. groupIndex .. "UnitButton" .. unitIndex)
    end
  end
end

-- Global cleanup function
local function cleanupAllOverlays()
  local frameNames = {
    "ElvUF_Player", "ElvUF_Target", "ElvUF_Focus", "ElvUF_Pet"
  }
  
  for _, name in ipairs(frameNames) do
    local frame = _G[name]
    if frame then
      removeOverlayFromFrame(frame)
    end
  end
  
  for i = 1, 8 do
    local frame = _G["ElvUF_Boss" .. i]
    if frame then
      removeOverlayFromFrame(frame)
    end
  end
  
  for i = 1, 5 do
    local frame = _G["ElvUF_PartyGroup1UnitButton" .. i]
    if frame then
      removeOverlayFromFrame(frame)
    end
  end
  
  for groupIndex = 1, 8 do
    for unitIndex = 1, 5 do
      local frame = _G["ElvUF_Raid1Group" .. groupIndex .. "UnitButton" .. unitIndex]
      if frame then
        removeOverlayFromFrame(frame)
      end
    end
  end
end

-- Make cleanup available as module method
function NE:CleanupOverlays()
  cleanupAllOverlays()
end

-- Main event driver
local driver = CreateFrame("Frame")
local ticker = nil

driver:RegisterEvent("PLAYER_ENTERING_WORLD")
driver:RegisterEvent("GROUP_ROSTER_UPDATE")
driver:RegisterEvent("PLAYER_TARGET_CHANGED")
driver:RegisterEvent("PLAYER_FOCUS_CHANGED")
driver:RegisterEvent("UNIT_PET")
driver:RegisterEvent("PLAYER_LOGOUT")
driver:SetScript("OnEvent", function(self, event)
  if event == "PLAYER_ENTERING_WORLD" then
    if not IsElvUILoaded() then
      Print("ElvUI not loaded; overlay will attach when available.")
      return
    end

    C_Timer.After(0.5, function()
      attachAll()
      Print("Initial overlay attachment completed")
    end)

    -- Simple periodic check every 2 seconds
    if ticker then
      ticker:Cancel()
    end
    ticker = C_Timer.NewTicker(2.0, attachAll)
    
  elseif event == "PLAYER_LOGOUT" then
    -- Clean up ticker on logout
    if ticker then
      ticker:Cancel()
      ticker = nil
    end
  elseif event == "PLAYER_FOCUS_CHANGED" then
    C_Timer.After(0.05, function()
      tryAttachByName("ElvUF_Focus")
    end)
  elseif event == "UNIT_PET" then
    C_Timer.After(0.05, function()
      tryAttachByName("ElvUF_Pet")
    end)
  else
    C_Timer.After(0.05, function()
      attachAll()
    end)
  end
end)

-- Configuration System
local function ConfigTable()
  E.Options.args.NornEdit = {
    order = 100,
    type = "group",
    name = "|cffe5cc80Norn|r Edit",
    args = {
      header1 = {
        order = 1,
        type = "header",
        name = "|cffe5cc80Norn|r Edit Configuration",
      },
      description1 = {
        order = 2,
        type = "description",
        name = "Configure Norn Edit features and modules.",
      },
      spacer1 = {
        order = 3,
        type = "description",
        name = "\n",
      },
      squircleminimap = {
        order = 4,
        type = "toggle",
        name = "Squircle Minimap",
        desc = "Enable the squircle minimap border and mask.",
        get = function(info) return E.private["NornEdit"]["SquircleMinimap"] end,
        set = function(info, value) 
          E.private["NornEdit"]["SquircleMinimap"] = value
          E:StaticPopup_Show("PRIVATE_RL")
        end,
      },
      minimapIcons = {
        order = 5,
        type = "toggle",
        name = "Minimap Icons",
        desc = "Show icons next to Minimap datatext panel entries.",
        get = function(info) return E.private["NornEdit"]["minimapIcons"] end,
        set = function(info, value) 
          E.private["NornEdit"]["minimapIcons"] = value
          E:StaticPopup_Show("PRIVATE_RL")
        end,
      },
      simpleChatBackdrop = {
        order = 6,
        type = "toggle",
        name = "Simple Chat Backdrop",
        desc = "Apply transparent backdrop to chat frames and tabs.",
        get = function(info) return E.private["NornEdit"]["SimpleChatBackdrop"] end,
        set = function(info, value)
          E.private["NornEdit"]["SimpleChatBackdrop"] = value
          E:StaticPopup_Show("PRIVATE_RL")
        end,
      },
      spacer2 = {
        order = 7,
        type = "description",
        name = "\n",
      },
      header2 = {
        order = 8,
        type = "header",
        name = "Profile Installer",
      },
      description2 = {
        order = 9,
        type = "description",
        name = "Install the Norn Edit layout profile.",
      },
      install = {
        order = 10,
        type = "execute",
        name = "Install Profile",
        desc = "Run the profile installation process.",
        func = function() 
          local InstallerData = ElvUI_NornEdit_InstallerData
          if InstallerData then
            E:GetModule("PluginInstaller"):Queue(InstallerData)
            E:ToggleOptions()
          end
        end,
      },
    },
  }
end

function NE:Initialize()
  if EP then
    EP:RegisterPlugin(ADDON_NAME, ConfigTable)
  end
end

local function InitializeCallback()
  NE:Initialize()
end

E:RegisterModule(NE:GetName(), InitializeCallback)

