local InputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local RobloxGui = CoreGui:WaitForChild("RobloxGui")
local Panel3D = require(RobloxGui.Modules.VR.Panel3D)
local VRHub = require(RobloxGui.Modules.VR.VRHub)

local UserGuiModule = {}
UserGuiModule.ModuleName = "UserGui"
UserGuiModule.KeepVRTopbarOpen = false
UserGuiModule.VRIsExclusive = false
UserGuiModule.VRClosesNonExclusive = false
VRHub:RegisterModule(UserGuiModule)

local userGuiPanel = Panel3D.Get(UserGuiModule.ModuleName)
userGuiPanel:SetType(Panel3D.Type.Fixed)
userGuiPanel:ResizeStuds(4, 4, 128)
userGuiPanel:SetVisible(false)

VRHub.ModuleOpened.Event:connect(function(moduleName)
	if moduleName ~= UserGuiModule.ModuleName then
		local module = VRHub:GetModule(moduleName)
		if module.VRClosesNonExclusive and userGuiPanel:IsVisible() then
			UserGuiModule:SetVisible(false)
		end
	end
end)

function UserGuiModule:SetVisible(visible)
	userGuiPanel:SetVisible(visible)
	if visible then
		local headLook = Panel3D.GetHeadLookXZ(true)
		userGuiPanel.localCF = headLook * CFrame.Angles(math.rad(5), 0, 0) * CFrame.new(0, 0, 5)
		VRHub:FireModuleOpened(UserGuiModule.ModuleName)
	else
		VRHub:FireModuleClosed(UserGuiModule.ModuleName)
	end

	local success, msg = pcall(function()
		CoreGui:SetUserGuiRendering(true, visible and userGuiPanel:GetPart() or nil, Enum.NormalId.Front)
	end)
end

local function OnVREnabled(prop)
	if prop == 'VREnabled' then
		local guiPart = nil
		if InputService.VREnabled then
			if userGuiPanel.isVisible then
				guiPart = userGuiPanel:GetPart()
			end
		else
			userGuiPanel:SetVisible(false)
		end
		local success, msg = pcall(function()
			CoreGui:SetUserGuiRendering(InputService.VREnabled, guiPart, Enum.NormalId.Front)
		end)
	end
end
InputService.Changed:connect(OnVREnabled)
spawn(function() OnVREnabled("VREnabled") end)

return UserGuiModule