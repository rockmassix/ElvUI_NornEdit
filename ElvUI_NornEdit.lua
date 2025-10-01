local ADDON_NAME = ...

local function Print(msg)
  DEFAULT_CHAT_FRAME:AddMessage("|cff99ccffNorn UI|r: " .. tostring(msg))
end

-- Hardcoded configuration - no database needed
local config = {
  enabled = true,
  texture = ("Interface\\AddOns\\%s\\media\\border.blp"):format(ADDON_NAME),
  width = 256,  -- Increased width for bigger border
  height = 64,  -- Increased height for bigger border
  xOffset = 0,
  yOffset = 5,
  blend = "BLEND",
  strata = "HIGH",
}

-- Compatibility wrapper for addon load checks across client versions
local function IsElvUILoaded()
  if C_AddOns and C_AddOns.IsAddOnLoaded then
    return C_AddOns.IsAddOnLoaded("ElvUI")
  elseif IsAddOnLoaded then
    return IsAddOnLoaded("ElvUI")
  end
  return false
end

local function getOverlayParent(frame)
  if frame and frame.RaisedElementParent and frame.RaisedElementParent.IsObjectType and frame.RaisedElementParent:IsObjectType("Frame") then
    return frame.RaisedElementParent
  end
  return frame
end

local function applyOverlayToFrame(frame, frameName)
  if not config.enabled then
    return
  end
  if not frame or not frame.IsObjectType or not frame:IsObjectType("Frame") then
    return
  end
  if frame.ElvUI_SkinOverlay then
    -- already applied
    return
  end

  local parent = getOverlayParent(frame)
  if not parent then
    return
  end

  local overlay = parent:CreateTexture(nil, "OVERLAY")
  overlay:SetTexture(config.texture)
  overlay:SetBlendMode(config.blend or "BLEND")
  overlay:SetSize(config.width, config.height)
  overlay:SetPoint("CENTER", parent, "CENTER", config.xOffset, config.yOffset)
  overlay:Show()

  frame.ElvUI_SkinOverlay = overlay

  -- Keep on top
  if parent.SetFrameStrata and config.strata then
    parent:SetFrameStrata(config.strata)
  end
end

local function tryAttachByName(name)
  local f = _G[name]
  if f then
    applyOverlayToFrame(f, name)
    return true
  end
  return false
end

local function attachIndividual()
  tryAttachByName("ElvUF_Player")
  tryAttachByName("ElvUF_Target")
  tryAttachByName("ElvUF_Focus")
  tryAttachByName("ElvUF_Pet")
end

local function attachBoss()
  for i = 1, 8 do
    tryAttachByName("ElvUF_Boss" .. i)
  end
end

local function attachParty()
  -- ElvUI party uses a single group header with unit buttons 1..5
  for i = 1, 5 do
    tryAttachByName("ElvUF_PartyGroup1UnitButton" .. i)
  end
end

local function attachRaid()
  -- Target common ElvUI raid layout: Raid1 group headers 1..8 with unit buttons 1..5
  for groupIndex = 1, 8 do
    for unitIndex = 1, 5 do
      tryAttachByName("ElvUF_Raid1Group" .. groupIndex .. "UnitButton" .. unitIndex)
    end
  end
end

local function attachAll()
  attachIndividual()
  attachBoss()
  attachParty()
  attachRaid()
end

local driver = CreateFrame("Frame")
driver:RegisterEvent("PLAYER_ENTERING_WORLD")
driver:RegisterEvent("GROUP_ROSTER_UPDATE")
driver:RegisterEvent("PLAYER_TARGET_CHANGED")
driver:SetScript("OnEvent", function(self, event)
  if event == "PLAYER_ENTERING_WORLD" then
    if not IsElvUILoaded() then
      Print("ElvUI not loaded; overlay will attach when available.")
    end

    C_Timer.After(1.0, attachAll)

    if self.ticker then
      self.ticker:Cancel()
    end
    self.ticker = C_Timer.NewTicker(2.5, attachAll)
  else
    C_Timer.After(0.2, attachAll)
  end
end)
