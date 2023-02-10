-- config
local config = {
	["WeaponMods"] = {
		["AlwaysAuto"] = false,
		["NoEqDelay"] = false,
		["NoRecoil"] = false,
		["NoSpread"] = false,
		["NoReload"] = false,
		["GunFirerate"] = false,
		["KnifeFirerate"] = false,
		["GunFirerateValue"] = .15,
		["KnifeFirerateValue"] = .1,
	},
	["SilentAim"] = {
		["Toggle"] = false,
		["AlwaysHit"] = false,
		["VisibleCheck"] = true,
		["AimPart"] = "Head",
		["Distance"] = 175,
	},
	["Esp"] = {
		["Toggle"] = false,
		["Names"] = true,
		["Boxes"] = true,
		["Tracers"] = true,
		["EnemyColor"] = Color3.new(255, 0, 0),
	}
}
-- services
local inputService = game:GetService("UserInputService")
local logService = game:GetService("LogService")
local players = game:GetService("Players")
local repStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
-- objects
local camera = workspace.CurrentCamera
local player = players.LocalPlayer
-- modules
local clientRayCast, gunModule = require(repStorage.GunSystem.Raycast), require(repStorage.GunSystem.GunClientAssets.Modules.Gun)
-- variables
local nearestPlr, weaponDataCache
local uiLibrary = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/jLn0n/scripts/main/libraries/linoria-lib-ui.lua"))()
local espLibrary = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/jLn0n/scripts/main/libraries/kiriot22-esp-library.lua"))()
local refs = table.create(0)
local weaponSettings = table.create(0)
local oldLogCache = logService:GetLogHistory()
local gunModuleFuncNamesToHook = {"Equip", "Fire", "Reload"}
local plrPartsList = (function()
	local plrParts = table.create(0)
	for _, object in ipairs(player.Character:GetChildren()) do
		if not object:IsA("BasePart") then continue end
		table.insert(plrParts, object.Name)
	end
	return plrParts
end)()
-- functions
local function getAimPartName()
	return (config.SilentAim.AimPart == "Random" and plrPartsList[math.random(1, #plrPartsList)] or config.SilentAim.AimPart)
end

local function checkPlr(plrArg)
	local plrChar = plrArg.Character
	local plrHumanoid, charPartName = (plrChar and plrChar:FindFirstChildWhichIsA("Humanoid")), getAimPartName()

	return plrArg ~= player and (plrArg.Neutral or plrArg.TeamColor ~= player.TeamColor) and (plrChar and (plrHumanoid and plrHumanoid.Health ~= 0) and not plrChar:FindFirstChildWhichIsA("ForceField")), plrChar:FindFirstChild(charPartName)
end

local function inLineOfSite(originPos, ...)
	return #camera:GetPartsObscuringTarget({originPos}, {camera, player.Character, workspace.Hitboxes, ...}) == 0
end

local function getNearestPlrByCursor()
	local nearestPlrData = {aimPart = nil, dist = math.huge}

	for _, plr in ipairs(players:GetPlayers()) do
		local passed, plrTPart = checkPlr(plr)
		if not (passed and plrTPart) then continue end
		local viewportPoint, onScreen = camera:WorldToViewportPoint(plrTPart.Position)
		local isVisible = inLineOfSite(plrTPart.Position, plr.Character)
		local fovDist = (inputService:GetMouseLocation() - Vector2.new(viewportPoint.X, viewportPoint.Y)).Magnitude

		if (not config.SilentAim.VisibleCheck or (onScreen and isVisible)) and ((fovDist <= config.SilentAim.Distance) and (fovDist < nearestPlrData.dist)) then
			nearestPlrData.character = plr.Character
			nearestPlrData.aimPart = plrTPart
			nearestPlrData.dist = fovDist
		end
	end
	return (nearestPlrData.aimPart and nearestPlrData or nil)
end

local function shallowCopy(tableArg)
	local tCopy = table.clone(tableArg)

	for index, value in pairs(tableArg) do
		if typeof(value) == "table" then
			tCopy[index] = table.clone(value)
		else
			tCopy[value] = value
		end
	end
	return tCopy
end

local function mergeTable(table1, table2)
	for key, value in pairs(table2) do
		if typeof(value) == "table" and typeof(table1[key] or false) == "table" then
			mergeTable(table1[key], value)
		else
			table1[key] = value
		end
	end
	return table1
end

local function initValueUpdater(objName, func)
	local objThingy = uiLibrary.Toggles[objName] or uiLibrary.Options[objName]
	local tableParent, tableName do
		local configPaths = string.split(objName, ".")
		local currentTable = config
		tableName = configPaths[#configPaths]
		for index = 1, #configPaths do
			currentTable = currentTable[configPaths[index]]
			if index == #configPaths - 1 then
				tableParent = currentTable
				break
			end
		end
	end

	objThingy:SetValue(tableParent[tableName]);
	objThingy:OnChanged(function()
		tableParent[tableName] = objThingy.Value
		if func then return func(tableParent[tableName]) end
	end)
end
-- ui init
local mainWindow = uiLibrary:CreateWindow("no-scope-arcade-gui.lua | Made by: jLn0n")
local mainTab = mainWindow:AddTab("Main")

local tabbox1 = mainTab:AddLeftTabbox("sAimTabbox")
local tabbox2 = mainTab:AddLeftTabbox("weaponModsTabbox")
local tabbox3 = mainTab:AddRightTabbox("espTabbox")
local tabbox4 = mainTab:AddRightTabbox("creditsTabbox")

local silentAimTab = tabbox1:AddTab("Silent Aim")
local weaponModsTab = tabbox2:AddTab("Weapon Mods")
local espTab = tabbox3:AddTab("ESP Settings")
local creditsTab = tabbox4:AddTab("Credits")

silentAimTab:AddToggle("SilentAim.Toggle", {Text = "Toggle"})
silentAimTab:AddToggle("SilentAim.AlwaysHit", {Text = "Always Hit"})
silentAimTab:AddToggle("SilentAim.VisibleCheck", {Text = "Visibility Check"})
silentAimTab:AddDropdown("SilentAim.AimPart", {Text = "Aim Part", Values = (function()
	table.insert(plrPartsList, 1, "Random")
	task.defer(table.remove, plrPartsList, 1)
	return plrPartsList
end)()})
silentAimTab:AddSlider("SilentAim.Distance", {Text = "Distance", Default = 1, Min = 1, Max = 1000, Rounding = 0})

weaponModsTab:AddToggle("WeaponMods.AlwaysAuto", {Text = "Always Auto"})
weaponModsTab:AddToggle("WeaponMods.NoEqDelay", {Text = "No Equip Delay"})
weaponModsTab:AddToggle("WeaponMods.NoRecoil", {Text = "No Recoil"})
weaponModsTab:AddToggle("WeaponMods.NoReload", {Text = "No Reload"})
weaponModsTab:AddToggle("WeaponMods.NoSpread", {Text = "No Spread"})
weaponModsTab:AddToggle("WeaponMods.GunFirerate", {Text = "Toggle Gun Firerate"})
weaponModsTab:AddSlider("WeaponMods.GunFirerateValue", {Text = "Gun Firerate", Default = 0, Min = .1, Max = 1, Rounding = 2})
weaponModsTab:AddToggle("WeaponMods.KnifeFirerate", {Text = "Toggle Knife Firerate"})
weaponModsTab:AddSlider("WeaponMods.KnifeFirerateValue", {Text = "Knife Firerate", Default = 0, Min = .05, Max = 1, Rounding = 2})

espTab:AddToggle("Esp.Toggle", {Text = "Toggle"})
espTab:AddToggle("Esp.Boxes", {Text = "Boxes"})
espTab:AddToggle("Esp.Names", {Text = "Names"})
espTab:AddToggle("Esp.Tracers", {Text = "Tracers"})
espTab:AddLabel("Enemy Color"):AddColorPicker("Esp.EnemyColor", {Default = Color3.new()})

creditsTab:AddLabel("Linoria Hub for Linoria UI Library")
creditsTab:AddLabel("Kiriot22 for the ESP Library")
for objThingyName in pairs(mergeTable(uiLibrary.Toggles, uiLibrary.Options)) do
	initValueUpdater(objThingyName, (objThingyName == "Esp.Toggle" and function(value)
		espLibrary:Toggle(value)
	end or nil))
end
-- esp init
espLibrary.TeamColor = false
espLibrary.Overrides.GetColor = function()
	return config.Esp.EnemyColor
end
-- main
for _, connection in ipairs(getconnections(logService.MessageOut)) do
	connection:Disable()
end

for _, funcName in ipairs(gunModuleFuncNamesToHook) do
	local funcCache = rawget(gunModule, funcName)

	if not (funcCache and typeof(funcCache) == "function") then continue end
	rawset(gunModule, funcName, function(weaponData)
		weaponDataCache = ((not weaponDataCache or weaponDataCache.Name ~= weaponData.Name) and shallowCopy(weaponData) or weaponDataCache)
		weaponData = mergeTable(weaponData, weaponSettings)
		return funcCache(weaponData)
	end)
end

runService.Heartbeat:Connect(function()
	nearestPlr = getNearestPlrByCursor()
	espLibrary.Boxes, espLibrary.Names, espLibrary.Tracers = config.Esp.Boxes, config.Esp.Names, config.Esp.Tracers

	if weaponDataCache then
		weaponSettings.Range = 9e6
		weaponSettings.Automatic = (config.WeaponMods.AlwaysAuto and true or weaponDataCache.Automatic)
		weaponSettings.EquipTime = (config.WeaponMods.NoEqDelay and 0 or weaponDataCache.EquipTime)
		weaponSettings.FireRate = (
			((weaponDataCache.Name == "Knife" and config.WeaponMods.KnifeFirerate) and config.WeaponMods.KnifeFirerateValue)
			or ((weaponDataCache.Name ~= "Knife" and config.WeaponMods.GunFirerate) and config.WeaponMods.GunFirerateValue)
			or weaponDataCache.FireRate
		)
		weaponSettings.RecoilMult = (config.WeaponMods.NoRecoil and 0 or weaponDataCache.RecoilMult)
		weaponSettings.ReloadTime = (config.WeaponMods.NoReload and 0 or weaponDataCache.ReloadTime)
		weaponSettings.Spread = (config.WeaponMods.NoSpread and 0 or weaponDataCache.Spread)
	end
end)

refs.__namecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
	local args = {...}
	local namecallMethod = getnamecallmethod()

	if not checkcaller() then
		if self.Name == "RemoteEvent" and namecallMethod == "FireServer" then
			if args[1] == "Bullet" and ((config.SilentAim.Toggle and config.SilentAim.AlwaysHit) and nearestPlr) then
				args[2] = nearestPlr.character
				args[3] = nearestPlr.aimPart
				args[4] = nearestPlr.aimPart.Position
			end
		elseif (self == logService and namecallMethod == "GetLogHistory") then
			return oldLogCache
		elseif (self == player and (namecallMethod == "Kick" or namecallMethod == "kick")) then
			return task.wait(9e9)
		end
	end
	return refs.__namecall(self, unpack(args))
end))

refs.gunRaycast = clientRayCast.Raycast
clientRayCast.Raycast = function(self, rayOrigin, rayDirection)
	if config.SilentAim.Toggle and nearestPlr then
		rayOrigin = camera.CFrame.Position
		rayDirection = ((nearestPlr.aimPart.Position - rayOrigin).Unit * 5e3)
	end
	return refs.gunRaycast(self, rayOrigin, rayDirection)
end

task.defer(uiLibrary.Notify, uiLibrary, "no-scope-arcade-gui.lua is now loaded!", 2.5)
