local E = unpack(ElvUI)
if not E then return end

local SCB = E:NewModule("SimpleChatBackdrop")

-- Configuration
local BORDER_TEXTURE = "Interface\\AddOns\\ElvUI_NornEdit\\media\\chat\\border"
local BACKDROP_ALPHA = 0.4

-- Create transparent backdrop
local function CreateTransparentBackdrop(frame, alpha, insetValue)
    local backdrop = CreateFrame("Frame", nil, frame, "BackdropTemplate")
    backdrop:SetFrameStrata(frame:GetFrameStrata())
    backdrop:SetFrameLevel(frame:GetFrameLevel() - 1)
    backdrop:SetAllPoints(frame)
    backdrop:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = BORDER_TEXTURE,
        tile = true,
        tileEdge = true,
        tileSize = 8,
        edgeSize = 8,
        insets = {left = insetValue, right = insetValue, top = insetValue, bottom = insetValue},
    })
    
    -- Fix backdrop positioning for seamless edges
    if backdrop.Center then
        backdrop.Center:ClearAllPoints()
        backdrop.Center:SetPoint("TOPLEFT", backdrop.TopLeftCorner, "BOTTOMRIGHT", 0, 0)
        backdrop.Center:SetPoint("BOTTOMRIGHT", backdrop.BottomRightCorner, "TOPLEFT", 0, 0)
    end
    
    backdrop:SetBackdropColor(0, 0, 0, alpha)
    backdrop:SetBackdropBorderColor(0, 0, 0, alpha)
    backdrop:Show()
    
    return backdrop
end

-- Apply backdrop to a chat frame
local function ApplyChatBackdrop(chatFrame)
    if not chatFrame or chatFrame.NornEdit_ChatBackdrop then return end
    
    -- Create backdrop frame
    local backdrop = CreateFrame("Frame", nil, chatFrame, "BackdropTemplate")
    backdrop:SetFrameStrata(chatFrame:GetFrameStrata())
    backdrop:SetFrameLevel(chatFrame:GetFrameLevel() - 1)
    
    -- Position 4px wider on each side
    backdrop:SetPoint("TOPLEFT", chatFrame, "TOPLEFT", -4, 4)
    backdrop:SetPoint("BOTTOMRIGHT", chatFrame, "BOTTOMRIGHT", 4, -4)
    
    backdrop:SetBackdrop({
        bgFile = "Interface\\ChatFrame\\ChatFrameBackground",
        edgeFile = BORDER_TEXTURE,
        tile = true,
        tileEdge = true,
        tileSize = 8,
        edgeSize = 8,
        insets = {left = 4, right = 4, top = 2, bottom = 2},
    })
    
    -- Fix backdrop positioning for seamless edges
    if backdrop.Center then
        backdrop.Center:ClearAllPoints()
        backdrop.Center:SetPoint("TOPLEFT", backdrop.TopLeftCorner, "BOTTOMRIGHT", 0, 0)
        backdrop.Center:SetPoint("BOTTOMRIGHT", backdrop.BottomRightCorner, "TOPLEFT", 0, 0)
    end
    
    backdrop:SetBackdropColor(0, 0, 0, BACKDROP_ALPHA)
    backdrop:SetBackdropBorderColor(0, 0, 0, BACKDROP_ALPHA)
    backdrop:Show()
    
    chatFrame.NornEdit_ChatBackdrop = backdrop
end

-- Apply backdrop to chat tab
local function ApplyTabBackdrop(tab)
    
    
    -- Hide default tab textures
    if tab.Left then tab.Left:SetTexture(nil) end
    if tab.Middle then tab.Middle:SetTexture(nil) end
    if tab.Right then tab.Right:SetTexture(nil) end
    if tab.ActiveLeft then tab.ActiveLeft:SetTexture(nil) end
    if tab.ActiveMiddle then tab.ActiveMiddle:SetTexture(nil) end
    if tab.ActiveRight then tab.ActiveRight:SetTexture(nil) end
    
    -- Create backdrop for the tab
    tab.NornEdit_TabBackdrop = CreateTransparentBackdrop(tab, BACKDROP_ALPHA, 4)
    
    -- Adjust tab height
    tab:SetHeight(20)
    
    -- Adjust tab text padding
    if tab.Text then
        tab.Text:ClearAllPoints()
        tab.Text:SetPoint("LEFT", tab, "LEFT", 8, 0)
        tab.Text:SetPoint("RIGHT", tab, "RIGHT", -8, 0)
    end
    
    -- Adjust glow positioning
    if tab.glow then
        tab.glow:ClearAllPoints()
        tab.glow:SetPoint("BOTTOMLEFT", 8, 2)
        tab.glow:SetPoint("BOTTOMRIGHT", -8, 2)
    end
end

-- Apply backdrop to chat editbox
local function ApplyEditBoxBackdrop(editBox)
    if not editBox or editBox.NornEdit_EditBoxBackdrop then return end
    
    -- Hide default ElvUI textures
    if editBox.Left then editBox.Left:SetTexture(nil) end
    if editBox.Mid then editBox.Mid:SetTexture(nil) end
    if editBox.Right then editBox.Right:SetTexture(nil) end
    if editBox.FocusLeft then editBox.FocusLeft:SetTexture(nil) end
    if editBox.FocusMid then editBox.FocusMid:SetTexture(nil) end
    if editBox.FocusRight then editBox.FocusRight:SetTexture(nil) end
    
    -- Clear backdrop if SetBackdrop exists
    if editBox.SetBackdrop then
        editBox:SetBackdrop(nil)
        editBox:SetBackdropColor(0, 0, 0, 0)
        editBox:SetBackdropBorderColor(0, 0, 0, 0)
    end
    
    -- Create transparent backdrop for the editbox
    editBox.NornEdit_EditBoxBackdrop = CreateTransparentBackdrop(editBox, BACKDROP_ALPHA, 4)
    
    -- Hook SetTemplate to prevent ElvUI from reapplying its styling
    if editBox.SetTemplate then
        local originalSetTemplate = editBox.SetTemplate
        editBox.SetTemplate = function(self, template, glossTex, ignoreUpdates, forcePixelMode)
            -- Clear any backdrop ElvUI tries to apply
            if self.SetBackdrop then
                self:SetBackdrop(nil)
                self:SetBackdropColor(0, 0, 0, 0)
                self:SetBackdropBorderColor(0, 0, 0, 0)
            end
            
            if self.Left then self.Left:SetTexture(nil) end
            if self.Mid then self.Mid:SetTexture(nil) end
            if self.Right then self.Right:SetTexture(nil) end
            if self.FocusLeft then self.FocusLeft:SetTexture(nil) end
            if self.FocusMid then self.FocusMid:SetTexture(nil) end
            if self.FocusRight then self.FocusRight:SetTexture(nil) end
        end
    end
end

-- Apply to all chat windows
function SCB:StyleAllChats()
    for i = 1, NUM_CHAT_WINDOWS do
        local chatFrame = _G["ChatFrame" .. i]
        if chatFrame then
            ApplyChatBackdrop(chatFrame)
            
            local tab = _G["ChatFrame" .. i .. "Tab"]
            if tab then
                ApplyTabBackdrop(tab)
            end
            
            local editBox = _G["ChatFrame" .. i .. "EditBox"]
            if editBox then
                ApplyEditBoxBackdrop(editBox)
            end
        end
    end
end

-- Initialize module
function SCB:Initialize()
    -- Check if enabled
    if not E.private["NornEdit"] or not E.private["NornEdit"]["SimpleChatBackdrop"] then
        return
    end
    
    -- Apply with delay to ensure chat is ready
    C_Timer.After(1, function()
        self:StyleAllChats()
    end)
    
    -- Hook for new temporary chat windows
    hooksecurefunc("FCF_OpenTemporaryWindow", function()
        C_Timer.After(0.1, function()
            self:StyleAllChats()
        end)
    end)
end

-- Register module
E:RegisterModule(SCB:GetName())
