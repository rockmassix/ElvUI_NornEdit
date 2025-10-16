local ADDON_NAME = ...

local E, L, V, P, G = unpack(ElvUI)
local SM = E:NewModule("SquircleMap")
local MM = E:GetModule('Minimap')
local _G = _G

-- Utility function to get asset path
local function GetAsset(path)
  return ("Interface\\AddOns\\%s\\%s"):format(ADDON_NAME, path)
end

-- Get config from ElvUI database
local function GetMinimapConfig()
  local cfg = E.private["NornEdit"]
  if cfg and cfg.minimap then
    return cfg.minimap
  end
  return P["NornEdit"].minimap
end

function SM:SkinMiniMap()
  local Minimap = _G.Minimap
  
  if not Minimap then
    return
  end

  -- Check if already skinned to avoid duplicate work
  if Minimap.NornEdit_Skinned then
    return
  end

  local config = GetMinimapConfig()

  -- Apply mask using config
  Minimap:SetMaskTexture(GetAsset(config.mask))
  Minimap:SetHitRectInsets(0, 0, 0, 0)
  Minimap:SetClampRectInsets(0, 0, 0, 0)

  -- Border overlay
  local borderFrame = CreateFrame("Frame", nil, Minimap)
  borderFrame:SetFrameLevel(Minimap:GetFrameLevel() + 10)

  local borderTexture = borderFrame:CreateTexture(nil, "OVERLAY")
  borderTexture:SetTexture(GetAsset(config.texture))
  borderTexture:SetAllPoints(borderFrame)
  borderTexture:SetBlendMode("BLEND")
  -- Trim edges slightly to avoid mip/bleed artifacts that can look like warping on some BLPs
  if borderTexture.SetTexCoord then
    borderTexture:SetTexCoord(0.002, 0.998, 0.002, 0.998)
  end
  
  -- Mark as skinned to prevent duplicate processing
  Minimap.NornEdit_Skinned = true

  local function UpdateBorderSize()
    -- Use config values
    borderFrame:SetSize(config.width or 212, config.height or 212)
    borderFrame:SetPoint("CENTER", Minimap, "CENTER", 0, 0)

    if Minimap.backdrop then
      Minimap.backdrop:Hide()
    end
  end

  hooksecurefunc(MM, "UpdateSettings", UpdateBorderSize)
  C_Timer.After(0.1, UpdateBorderSize)

end

function SM:Initialize()
  if not E.private.general.minimap.enable then return end
  if not E.private["NornEdit"] or not E.private["NornEdit"]["SquircleMinimap"] then return end
  self:SkinMiniMap()
end

E:RegisterModule(SM:GetName())

