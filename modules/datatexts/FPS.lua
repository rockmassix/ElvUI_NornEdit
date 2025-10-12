local E = unpack(ElvUI)
local DT = E:GetModule('DataTexts')

-- Optimized imports - only what we need
local IsControlKeyDown = IsControlKeyDown
local IsShiftKeyDown = IsShiftKeyDown
local ReloadUI = ReloadUI
local ResetCPUUsage = ResetCPUUsage
local collectgarbage = collectgarbage

local statusColors = {
	'|cff0CD809', -- Green (good)
	'|cffE8DA0F', -- Yellow (fair)
	'|cffFF9000', -- Orange (poor)
	'|cffD80909'  -- Red (bad)
}

local enteredFrame = false

local function StatusColor(fps)
	return statusColors[fps >= 30 and 1 or (fps >= 20 and fps < 30) and 2 or (fps >= 10 and fps < 20) and 3 or 4]
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

local function OnEnter()
	DT.tooltip:ClearLines()
	enteredFrame = true

	local fps = E.FPS
	if fps.rate then
		DT.tooltip:AddDoubleLine("FPS", format('%d', fps.rate), .69, .31, .31, .84, .75, .65)
		
		if IsShiftKeyDown() then
			DT.tooltip:AddDoubleLine("FPS Average:", format('%d', fps.average), .69, .31, .31, .84, .75, .65)
			DT.tooltip:AddDoubleLine("FPS Lowest:", format('%d', fps.low), .69, .31, .31, .84, .75, .65)
			DT.tooltip:AddDoubleLine("FPS Highest:", format('%d', fps.high), .69, .31, .31, .84, .75, .65)
		end
	end

	DT.tooltip:AddLine(' ')
	DT.tooltip:AddLine("(Shift Click) Collect Garbage")
	DT.tooltip:AddLine("(Ctrl & Shift Click) Toggle CPU Profiling")
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

		local fps = E.FPS.rate or 0
		self.text:SetFormattedText('%s%d|r fps', StatusColor(fps), fps)

		if not enteredFrame then
			return
		else
			OnEnter()
		end
	end
end

-- Register the FPS datatext
DT:RegisterDatatext('NE:FPS', nil, 'MODIFIER_STATE_CHANGED', OnEvent, OnUpdate, OnClick, OnEnter, OnLeave, "NE: FPS")
