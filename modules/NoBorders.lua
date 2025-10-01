local E, L, V, P, G = unpack(ElvUI)
if not E then return end

-- Always-on border removal for ElvUI elements
-- Adapted from dlecina/ElvUI_NoBorders (reduced; options removed; always enabled)

local unpack, getmetatable = unpack, getmetatable
local hooksecurefunc = hooksecurefunc
local RAID_CLASS_COLORS = RAID_CLASS_COLORS

local backdropr, backdropg, backdropb, backdropa = 0, 0, 0, 1
local borderr, borderg, borderb = 0, 0, 0

local function GetTemplate(template, isUnitFrameElement)
  backdropa = 1

  if template == "ClassColor" then
    local color = (CUSTOM_CLASS_COLORS and CUSTOM_CLASS_COLORS[E.myclass]) or RAID_CLASS_COLORS[E.myclass]
    borderr, borderg, borderb = color.r, color.g, color.b
    backdropr, backdropg, backdropb = unpack(E.media.backdropcolor)
  elseif template == "Transparent" then
    borderr, borderg, borderb = unpack(isUnitFrameElement and E.media.unitframeBorderColor or E.media.bordercolor)
    backdropr, backdropg, backdropb, backdropa = unpack(E.media.backdropfadecolor)
  else
    borderr, borderg, borderb = unpack(isUnitFrameElement and E.media.unitframeBorderColor or E.media.bordercolor)
    backdropr, backdropg, backdropb = unpack(E.media.backdropcolor)
  end
end

local function CustomSetTemplate(frame, template, glossTex, ignoreUpdates, forcePixelMode, isUnitFrameElement, isNamePlateElement, noScale)
  GetTemplate(template, isUnitFrameElement)

  if template ~= "NoBackdrop" then
    frame:SetBackdropColor(backdropr, backdropg, backdropb, backdropa)
    if not E.PixelMode and not frame.forcePixelMode then
      if frame.iborder then
        frame.iborder:SetBackdropBorderColor(0, 0, 0, 0)
      end
      if frame.oborder then
        frame.oborder:SetBackdropBorderColor(0, 0, 0, 0)
      end
    end
  end

  frame:SetBackdropBorderColor(0, 0, 0, 0)
  frame.ignoreBorderColors = true

  if isUnitFrameElement and template ~= "Transparent" then
    frame:SetBackdropColor(0, 0, 0, 0)
  end
end

local function addapi(object)
  if not object.isNornNoBordersHooked then
    local mt = getmetatable(object).__index
    hooksecurefunc(mt, "SetTemplate", CustomSetTemplate)
    object.isNornNoBordersHooked = true
  end
end

local handled = { ["Frame"] = true }
local object = CreateFrame("Frame")
addapi(object)

object = EnumerateFrames()
while object do
  if not object:IsForbidden() and not handled[object:GetObjectType()] then
    addapi(object)
    handled[object:GetObjectType()] = true
  end
  object = EnumerateFrames(object)
end



