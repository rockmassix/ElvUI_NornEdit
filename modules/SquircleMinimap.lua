local ADDON_NAME = ...

local E, L, V, P, G = unpack(ElvUI)
local SM = E:NewModule("SquircleMap")
local MM = E:GetModule('Minimap')
local _G = _G

local function GetAsset(path)
  return ("Interface\\AddOns\\%s\\%s"):format(ADDON_NAME, path)
end

function SM:SkinMiniMap()
  local Minimap = _G.Minimap

  -- Apply mask (use extensionless path like original addon)
  Minimap:SetMaskTexture(GetAsset("media\\mask"))
  Minimap:SetHitRectInsets(0, 0, 0, 0)
  Minimap:SetClampRectInsets(0, 0, 0, 0)

  -- Border overlay
  local borderFrame = CreateFrame("Frame", nil, Minimap)
  borderFrame:SetFrameLevel(Minimap:GetFrameLevel() + 10)

  local borderTexture = borderFrame:CreateTexture(nil, "OVERLAY")
  borderTexture:SetTexture(GetAsset("media\\border.png"))
  borderTexture:SetAllPoints(borderFrame)
  borderTexture:SetBlendMode("BLEND")
  -- Trim edges slightly to avoid mip/bleed artifacts that can look like warping on some BLPs
  if borderTexture.SetTexCoord then
    borderTexture:SetTexCoord(0.002, 0.998, 0.002, 0.998)
  end

  local function UpdateBorderSize()
    local minimapSize = Minimap:GetWidth()
    local borderSize = minimapSize * 1.4
    borderFrame:SetSize(borderSize, borderSize)
    borderFrame:SetPoint("CENTER", Minimap, "CENTER", 0, 0)

    if Minimap.backdrop then
      Minimap.backdrop:Hide()
    end
  end

  hooksecurefunc(MM, "UpdateSettings", UpdateBorderSize)
  C_Timer.After(0.1, UpdateBorderSize)

  if Minimap.backdrop then
    Minimap.backdrop:Hide()
  end
end

function SM:Initialize()
  if not E.private.general.minimap.enable then return end
  self:SkinMiniMap()
end

E:RegisterModule(SM:GetName())

