local E, L, V, P, G = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

local GetNetStats = GetNetStats
local GetNetIpTypes = GetNetIpTypes
local GetAvailableBandwidth = GetAvailableBandwidth
local GetBackgroundLoadingStatus = GetBackgroundLoadingStatus
local GetDownloadedPercentage = GetDownloadedPercentage
local GetFileStreamingStatus = GetFileStreamingStatus
local InCombatLockdown = InCombatLockdown
local IsControlKeyDown = IsControlKeyDown
local IsShiftKeyDown = IsShiftKeyDown
local ReloadUI = ReloadUI
local ResetCPUUsage = ResetCPUUsage
local collectgarbage = collectgarbage

local GetCVarBool = C_CVar.GetCVarBool

local UNKNOWN = UNKNOWN

local statusColors = {
	'|cff0CD809', -- Green (good)
	'|cffE8DA0F', -- Yellow (fair)
	'|cffFF9000', -- Orange (poor)
	'|cffD80909'  -- Red (bad)
}

local enteredFrame, db = false
local bandwidthString = '%.2f Mbps'
local percentageString = '%.2f%%'
local homeLatencyString = '%d ms'

local function StatusColor(ping)
	return statusColors[ping < 150 and 1 or (ping >= 150 and ping < 300) and 2 or (ping >= 300 and ping < 500) and 3 or 4]
end

local function OnClick()
	local shiftDown, ctrlDown = IsShiftKeyDown(), IsControlKeyDown()
	if shiftDown and ctrlDown then
		E:SetCVar('scriptProfile', E:GetCVarBool('scriptProfile') and 0 or 1)
		ReloadUI()
	elseif shiftDown and not ctrlDown then
		collectgarbage('collect')
		ResetCPUUsage()
	end
end

local function OnEnter(_, slow)
	if not db.showTooltip then return end
	local isShiftDown = IsShiftKeyDown()

	DT.tooltip:ClearLines()
	enteredFrame = true

	local _, _, homePing, worldPing = GetNetStats()
	local ipTypes = {'IPv4', 'IPv6'}
	
	DT.tooltip:AddDoubleLine(L["Home Latency:"], format(homeLatencyString, homePing), .69, .31, .31, .84, .75, .65)
	DT.tooltip:AddDoubleLine(L["World Latency:"], format(homeLatencyString, worldPing), .69, .31, .31, .84, .75, .65)

	if GetCVarBool('useIPv6') then
		local ipTypeHome, ipTypeWorld = GetNetIpTypes()
		DT.tooltip:AddDoubleLine(L["Home Protocol:"], ipTypes[ipTypeHome or 0] or UNKNOWN, .69, .31, .31, .84, .75, .65)
		DT.tooltip:AddDoubleLine(L["World Protocol:"], ipTypes[ipTypeWorld or 0] or UNKNOWN, .69, .31, .31, .84, .75, .65)
	end

	local Downloading = GetFileStreamingStatus() ~= 0 or GetBackgroundLoadingStatus() ~= 0
	if Downloading then
		DT.tooltip:AddDoubleLine(L["Bandwidth"] , format(bandwidthString, GetAvailableBandwidth()), .69, .31, .31, .84, .75, .65)
		DT.tooltip:AddDoubleLine(L["Download"] , format(percentageString, GetDownloadedPercentage() * 100), .69, .31, .31, .84, .75, .65)
	end

	DT.tooltip:AddLine(' ')
	DT.tooltip:AddLine(L["(Shift Click) Collect Garbage"])
	DT.tooltip:AddLine(L["(Ctrl & Shift Click) Toggle CPU Profiling"])
	DT.tooltip:Show()
end

local function OnLeave()
	enteredFrame = false
end

local function OnEvent(self, event)
	if event == 'MODIFIER_STATE_CHANGED' then
		OnEnter(self)
	end
end

local wait = 0
local function OnUpdate(self, elapsed)
	if wait < 1 then
		wait = wait + elapsed
	else
		wait = 0

		local _, _, homePing, worldPing = GetNetStats()
		-- Show home latency as primary, world latency in parentheses
		local primaryLatency = homePing
		local secondaryLatency = worldPing
		local primaryColor = StatusColor(primaryLatency)
		local secondaryColor = StatusColor(secondaryLatency)

		if db.NoLabel then
			self.text:SetFormattedText('%s%d|r (%s%d|r) ms', primaryColor, primaryLatency, secondaryColor, secondaryLatency)
		else
			self.text:SetFormattedText('%s%d|r (%s%d|r) ms', primaryColor, primaryLatency, secondaryColor, secondaryLatency)
		end

		if not enteredFrame then
			return
		elseif InCombatLockdown() then
			-- Reduce tooltip updates in combat
			return
		else
			OnEnter(self)
		end
	end
end

local function ApplySettings(self)
	if not db then
		db = E.global.datatexts.settings[self.name]
	end
end

-- Register the MS datatext
DT:RegisterDatatext('NE:MS', nil, 'MODIFIER_STATE_CHANGED', OnEvent, OnUpdate, OnClick, OnEnter, OnLeave, "NE: MS", nil, ApplySettings)
