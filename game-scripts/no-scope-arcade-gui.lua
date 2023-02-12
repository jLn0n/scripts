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
		["Enabled"] = false,
		["AlwaysHit"] = false,
		["VisibleCheck"] = true,
		["AimPart"] = "Head",
		["FovDist"] = 175,
	},
	["Esp"] = {
		["Enabled"] = false,
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
local nearestPlr
local uiLibrary = loadstring(game:HttpGetAsync("https://github.com/shlexware/Rayfield/blob/main/source?raw=true"))()
local espLibrary = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/jLn0n/scripts/main/libraries/kiriot22-esp-library.lua"))()
local refs = table.create(0)
local weaponSettings, weaponDataCache = table.create(0), nil
local oldLogCache = logService:GetLogHistory()
local gunModuleFuncNamesToHook = {"Equip", "Fire", "Reload"}
local charPartsList = {"Head", "UpperTorso", "Random"}
-- functions
local function getAimPartName()
	return (config.SilentAim.AimPart == "Random" and charPartsList[math.random(1, #charPartsList - 1)] or config.SilentAim.AimPart)
end

local function checkPlr(plrArg)
	local plrChar = plrArg.Character
	local plrHumanoid, charPartName = (plrChar and plrChar:FindFirstChildWhichIsA("Humanoid")), getAimPartName()

	return plrArg ~= player and (plrArg.Neutral or plrArg.TeamColor ~= player.TeamColor) and (plrChar and (plrHumanoid and plrHumanoid.Health ~= 0) and not plrChar:FindFirstChildWhichIsA("ForceField")), (plrChar and plrChar:FindFirstChild(charPartName))
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

		if (not config.SilentAim.VisibleCheck or (onScreen and isVisible)) and ((fovDist <= config.SilentAim.FovDist) and (fovDist < nearestPlrData.dist)) then
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
		if typeof(value) ~= "table" then continue end
		tCopy[index] = shallowCopy(value)
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

local function bindFunction(funcValue, ...)
	local args = {...}
	return function(...) return funcValue(..., unpack(args)) end
end

local function onValueUpdate(value, objName, func)
	local configName, configParent do
		local configPaths = string.split(objName, ".")
		local currentTable = config
		configName = configPaths[#configPaths]

		for index = 1, #configPaths do
			currentTable = currentTable[configPaths[index]]

			if index == #configPaths - 1 then
				configParent = currentTable
				break
			end
		end
	end

	configParent[configName] = value
	if func then return func(configParent[configName]) end
end
-- ui init
local mainWindow = uiLibrary:CreateWindow({
	Name = "no-scope-arcade-gui.lua",
	LoadingTitle = "No Scope Arcade GUI",
	LoadingSubtitle = "by jLn0n#1464",
})

local aimingTab = mainWindow:CreateTab("Aiming")
local gameModsTab = mainWindow:CreateTab("Modifications")
local visualsTab = mainWindow:CreateTab("Visuals")
local miscTab = mainWindow:CreateTab("Misceleanous")

aimingTab:CreateSection("Silent Aim")
aimingTab:CreateToggle({
	Name = "Enabled",
	CurrentValue = config.SilentAim.Enabled,
	Callback = bindFunction(onValueUpdate, "SilentAim.Enabled"),
})
aimingTab:CreateToggle({
	Name = "Always Hit",
	CurrentValue = config.SilentAim.AlwaysHit,
	Callback = bindFunction(onValueUpdate, "SilentAim.AlwaysHit"),
})
aimingTab:CreateToggle({
	Name = "Visible Check",
	CurrentValue = config.SilentAim.VisibleCheck,
	Callback = bindFunction(onValueUpdate, "SilentAim.VisibleCheck"),
})
aimingTab:CreateDropdown({
	Name = "Aiming Part",
	Options = charPartsList,
	CurrentOption = config.SilentAim.AimPart,
	Callback = bindFunction(onValueUpdate, "SilentAim.AimPart"),
})
aimingTab:CreateSlider({
	Name = "FOV Distance",
	Range = {0, 1000},
	Increment = 5,
	Suffix = "FOV",
	CurrentValue = config.SilentAim.FovDist,
	Callback = bindFunction(onValueUpdate, "SilentAim.FovDist"),
})

gameModsTab:CreateSection("Weapon Mods")
gameModsTab:CreateToggle({
	Name = "Always Auto",
	CurrentValue = config.WeaponMods.AlwaysAuto,
	Callback = bindFunction(onValueUpdate, "WeaponMods.AlwaysAuto"),
})
gameModsTab:CreateToggle({
	Name = "No Equip Delay",
	CurrentValue = config.WeaponMods.NoEqDelay,
	Callback = bindFunction(onValueUpdate, "WeaponMods.NoEqDelay"),
})
gameModsTab:CreateToggle({
	Name = "No Recoil",
	CurrentValue = config.WeaponMods.NoRecoil,
	Callback = bindFunction(onValueUpdate, "WeaponMods.NoRecoil"),
})
gameModsTab:CreateToggle({
	Name = "No Reload",
	CurrentValue = config.WeaponMods.NoReload,
	Callback = bindFunction(onValueUpdate, "WeaponMods.NoReload"),
})
gameModsTab:CreateToggle({
	Name = "No Spread",
	CurrentValue = config.WeaponMods.NoSpread,
	Callback = bindFunction(onValueUpdate, "WeaponMods.NoSpread"),
})
gameModsTab:CreateToggle({
	Name = "Gun Firerate",
	CurrentValue = config.WeaponMods.GunFirerate,
	Callback = bindFunction(onValueUpdate, "WeaponMods.GunFirerate"),
})
gameModsTab:CreateSlider({
	Name = "Gun Firerate Value",
	Range = {.1, 1},
	Increment = .05,
	Suffix = "Firerate",
	CurrentValue = config.WeaponMods.GunFirerateValue,
	Callback = bindFunction(onValueUpdate, "WeaponMods.GunFirerateValue"),
})
gameModsTab:CreateToggle({
	Name = "Knife Firerate",
	CurrentValue = config.WeaponMods.KnifeFirerate,
	Callback = bindFunction(onValueUpdate, "WeaponMods.KnifeFirerate"),
})
gameModsTab:CreateSlider({
	Name = "Knife Firerate Value",
	Range = {.05, 1},
	Increment = .05,
	Suffix = "Firerate",
	CurrentValue = config.WeaponMods.KnifeFirerateValue,
	Callback = bindFunction(onValueUpdate, "WeaponMods.KnifeFirerateValue"),
})

visualsTab:CreateSection("ESP")
visualsTab:CreateToggle({
	Name = "Enable",
	CurrentValue = config.Esp.Enabled,
	Callback = bindFunction(onValueUpdate, "Esp.Enabled", function(value)
		espLibrary:Toggle(value)
	end),
})
visualsTab:CreateToggle({
	Name = "Boxes",
	CurrentValue = config.Esp.Boxes,
	Callback = bindFunction(onValueUpdate, "Esp.Boxes"),
})
visualsTab:CreateToggle({
	Name = "Names",
	CurrentValue = config.Esp.Names,
	Callback = bindFunction(onValueUpdate, "Esp.Names"),
})
visualsTab:CreateToggle({
	Name = "Tracers",
	CurrentValue = config.Esp.Tracers,
	Callback = bindFunction(onValueUpdate, "Esp.Tracers"),
})
visualsTab:CreateColorPicker({
	Name = "Enemy Color",
	Color = config.Esp.EnemyColor,
	Callback = bindFunction(onValueUpdate, "Esp.EnemyColor")
})

miscTab:CreateSection("Credits")
miscTab:CreateLabel("Rayfield Interface Suite for their sleek and hot UI Library")
miscTab:CreateLabel("Kiriot22 for the simple yet elegant ESP Library.")
miscTab:CreateLabel("Friendship broke with Linoria UI, because very confusing to use")
miscTab:CreateLabel("jLn0n (me) for wasting my time unpatching this script")
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
	espLibrary.Boxes, espLibrary.Names, espLibrary.Tracers =
		config.Esp.Boxes,
		config.Esp.Names,
		config.Esp.Tracers
end)

runService.RenderStepped:Connect(function()
	if not weaponDataCache then return end
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
	--weaponSettings.ReloadType = (not config.WeaponMods.NoRecoil and weaponDataCache.ReloadType or nil)
	weaponSettings.Spread = (config.WeaponMods.NoSpread and 0 or weaponDataCache.Spread)

	if config.WeaponMods.NoReload and weaponDataCache.Name ~= "Knife" then
		weaponSettings.CanFire = true
		weaponSettings.Ammo = weaponDataCache.ClipSize
	end
end)

refs.__namecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
	local args = {...}
	local namecallMethod = getnamecallmethod()

	if not checkcaller() then
		if self.IsA(self, "RemoteEvent") and namecallMethod == "FireServer" then
			if (self.Name == "RemoteEvent" and args[1] == "Bullet") and ((config.SilentAim.Enabled and config.SilentAim.AlwaysHit) and nearestPlr) then
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
	if (config.SilentAim.Enabled and not config.SilentAim.AlwaysHit) and nearestPlr then
		rayDirection = ((nearestPlr.aimPart.Position - rayOrigin).Unit * 5e3)
	end
	return refs.gunRaycast(self, rayOrigin, rayDirection)
end

uiLibrary:Notify({
	Title = "no-scope-arcade-gui.lua",
	Content = "Loaded!",
	Duration = 2.5,
})
