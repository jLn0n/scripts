-- NOT RECOMMENDED TO USE
--[[
	Info:
	Hey im jLn0n, u may know me as mengcap_CLEETUS or YEETED_CLEETUS on roblox, im not the original creator of the known
	leaked fe stand script, I made this script on 6/2/2021 from scratch because the leaked FE stand script is messy and
	patched by roblox, if the stand is gone or not showing when executed first on ur executor please rejoin and execute
	it again. Please read the things that I've written below to guide you using the script.

	Hats Needed: (Required! Please wear them after u bought them.)
	Head -      FREE: https://www.roblox.com/catalog/617605556 (can be changed)
	Left Arm -  FREE: https://www.roblox.com/catalog/63690008
	Left Leg -  FREE: https://www.roblox.com/catalog/48474294  (bundle: https://www.roblox.com/bundles/282)
	Right Arm - FREE: https://www.roblox.com/catalog/62234425
	Right Leg - FREE: https://www.roblox.com/catalog/62724852  (bundle: https://www.roblox.com/bundles/239)
	Torso -     40R$: https://www.roblox.com/catalog/29532720  (full torso part)
	Torso1 -    FREE: https://www.roblox.com/catalog/48474313  (if u don't have robux, not needed when u have the full torso part)
	Torso2 -    FREE: https://www.roblox.com/catalog/451220849 (if u don't have robux, not needed when u have the full torso part)

	Keybinds:
	Q - Summon / Unsummon stand
	E - Barrage
	R - HeavyPunch
	T - Universal Barrage (barrages player that ur mouse is aiming at)
	F - Time Stop
	Z - Stand Jump
	G - Stand Idle Menance thingy

	TODO's: (* - unfinished | x - finished)
	* Custom player animations
	* Fling support
	* Make dmgPlayer function damaging customizable
--]]
-- // SETTINGS
local HeadName = "MediHood" -- you can find the name of ur desired head by using dex or viewing it with btroblox (chrome extension)
local HeadOffset = CFrame.new(Vector3.new(0, .125, .25)) -- offsets the desired head
local RemoveHeadMesh = false -- removes the mesh of the desired head when enabled
local StarterStandoCFrame = CFrame.new(Vector3.new(-1.75, 1.65, 2.5)) -- the starting position of the stand
local EnableChats = false -- enables character chatting when a action was enabled / changed
local NerfHitDamages = false -- nerfs the damage from the stand, if u will have a stand fight just enable this lol (player damaging only works on prison life)
local UseBuiltinNetless = true -- enables builtin netless when enabled, if u want to use ur own netless just disable this, execute ur netless script first and this script
-- // SERVICES
local GuiService = game:GetService("GuiService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RepStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
-- // OBJECTS
local Player = Players.LocalPlayer
local Mouse = Player:GetMouse()
local Character = Player.Character
local Humanoid = Character.Humanoid
local HRP = Character.HumanoidRootPart
local ChatMakeMsg, ShootEvent, ReloadEvent, ItemHandler, TeamEvent = RepStorage.DefaultChatSystemChatEvents.SayMessageRequest
-- // VARIABLES
_G.Connections = _G.Connections or {}
local rad, sin, cos, floor, RandomObj = math.rad, math.sin, math.cos, math.floor, Random.new(os.clock())
local HatParts = {
	["Head"] = Character:FindFirstChild(HeadName),
	["Left Arm"] = Character:FindFirstChild("Pal Hair"),
	["Left Leg"] = Character:FindFirstChild("Pink Hair"),
	["Right Arm"] = Character:FindFirstChild("Hat1"),
	["Right Leg"] = Character:FindFirstChild("Kate Hair"),
	["Torso1"] = Character:FindFirstChild("Robloxclassicred"),
	["Torso2"] = Character:FindFirstChild("LavanderHair"),
	["Torso"] = Character:FindFirstChild("SeeMonkey")
}
local StandStates = {
	["Enabled"] = true,
	["AbilityState"] = "Idle",
	["IsTimeStopMode"] = false,
	["CanUpdateStates"] = true,
	["CanUpdateStates2"] = true,
}
local StandKeybinds = {
	[Enum.KeyCode.E] = "Barrage",
	[Enum.KeyCode.R] = "HeavyPunch",
	[Enum.KeyCode.T] = "UnivBarrage",
	[Enum.KeyCode.F] = "TimeStop",
	[Enum.KeyCode.G] = "MenanceIdle",
	[Enum.KeyCode.Z] = "StandoJump"
}
local StandoCFrame = StarterStandoCFrame
local anim, animSpeed = 0, 0
local rayParams, raycastedPlr, univBrgeTargetPlr, univBrgeTPlrHRP
-- // MAIN
assert(not Character:FindFirstChild("StandCharacter"), [[["FE-STAND.LUA"]: Please reset to be able to run the script again!]])
assert(Humanoid.RigType == Enum.HumanoidRigType.R6, [[["FE-STAND.LUA"]: Sorry, This script will only work on R6 character rig only!]])
for _, connection in ipairs(_G.Connections) do connection:Disconnect() end _G.Connections = {}
local StandCharacter = game:GetObjects("rbxassetid://6843243348")[1]
local StandoHRP = StandCharacter.HumanoidRootPart
local ColorCE = Lighting:FindFirstChild("TimeStopCCE") or Instance.new("ColorCorrectionEffect")
StandCharacter.Name, StandCharacter.Parent = "StandCharacter", Character
ColorCE.Name, ColorCE.Parent = "TimeStopCCE", Lighting
ShootEvent, ReloadEvent, ItemHandler, TeamEvent =
	(game.PlaceId == 155615604 and RepStorage.ShootEvent or nil),
	(game.PlaceId == 155615604 and RepStorage.ReloadEvent or nil),
	(game.PlaceId == 155615604 and workspace.Remote.ItemHandler or nil),
	(game.PlaceId == 155615604 and workspace.Remote.TeamEvent or nil) -- idot thinking
rayParams = RaycastParams.new()
rayParams.FilterType, rayParams.FilterDescendantsInstances, Mouse.TargetFilter = Enum.RaycastFilterType.Blacklist, {Character}, Character

for _, object in ipairs(StandCharacter:GetChildren()) do if object:IsA("BasePart") then object.Transparency = 1 end end
for PartName, object in pairs(HatParts) do
	if object.Handle:FindFirstChildWhichIsA("Weld") then object.Handle:FindFirstChildWhichIsA("Weld"):Destroy() end
	if PartName == "Head" and RemoveHeadMesh then
		object.Handle:FindFirstChildWhichIsA("SpecialMesh"):Destroy()
	elseif PartName ~= "Head" then
		object.Handle:FindFirstChildWhichIsA("SpecialMesh"):Destroy()
	end
end

local initMotor = function(motor)
	return {
		Object = motor,
		CFrame = motor.Transform,
		Cache = motor.Transform
	}
end

local Motors = {
	["Neck"] = initMotor(StandCharacter.Torso.Neck),
	["RS"] = initMotor(StandCharacter.Torso["Right Shoulder"]),
	["LS"] = initMotor(StandCharacter.Torso["Left Shoulder"]),
	["RH"] = initMotor(StandCharacter.Torso["Right Hip"]),
	["LH"] = initMotor(StandCharacter.Torso["Left Hip"]),
	["RJoint"] = initMotor(StandoHRP.RootJoint),
}

local setUpdateState = function(boolean) StandStates.CanUpdateStates, StandStates.CanUpdateStates2 = boolean, boolean end
local createMessage = function(msg) ChatMakeMsg:FireServer((EnableChats and msg) and msg, "All") end
local onCharacterRemoved = function()
	for _, connection in ipairs(_G.Connections) do connection:Disconnect() end _G.Connections = {}
	for _, object in pairs(HatParts) do
		if object and object:FindFirstChild("Handle") then
			object.Handle.Velocity = Vector3.new()
		end
	end
end

local anchorPlrs = function(arg1)
	for _, plr in ipairs(Players:GetPlayers()) do
		local plrChar = plr.Character or plr.CharacterAdded:Wait()
		if plr ~= Player then
			for _, object in ipairs(plrChar:GetChildren()) do
				if object:IsA("BasePart") then
					object.Anchored = arg1
				end
			end
		end
	end
end

local getPlrFromBasePart = function(instance)
	local PlrInstance = Players:GetPlayerFromCharacter(instance.Parent:IsA("Model") and instance.Parent
		or (instance.Parent:IsA("Accessory") or instance.Parent:IsA("Tool")) and instance.Parent.Parent
		or nil
	)
	return PlrInstance ~= Player and PlrInstance
end

local dmgPlayer = function(targetPlr, damage)
	if targetPlr and game.PlaceId == 155615604 then
		ItemHandler:InvokeServer(workspace.Prison_ITEMS.giver["Remington 870"].ITEMPICKUP)
		local aFuckingGun = Player.Backpack["Remington 870"]
		local remote_args = {
			[1] = {
				[1] = {
					["RayObject"] = Ray.new(aFuckingGun.Muzzle.Position, targetPlr.Character.Head.Position),
					["Distance"] = (HRP.Position - targetPlr.Character.HumanoidRootPart.Position).Magnitude,
					["Cframe"] = targetPlr.Character.Head.CFrame,
					["Hit"] = targetPlr.Character.Head
				},
				[2] = {
					["RayObject"] = Ray.new(aFuckingGun.Muzzle.Position, targetPlr.Character.Head.Position),
					["Distance"] = (HRP.Position - targetPlr.Character.HumanoidRootPart.Position).Magnitude,
					["Cframe"] = targetPlr.Character.Head.CFrame,
					["Hit"] = targetPlr.Character.Head
				},
				[3] = {
					["RayObject"] = Ray.new(aFuckingGun.Muzzle.Position, targetPlr.Character.Head.Position),
					["Distance"] = (HRP.Position - targetPlr.Character.HumanoidRootPart.Position).Magnitude,
					["Cframe"] = targetPlr.Character.Head.CFrame,
					["Hit"] = targetPlr.Character.Head
				},
				[4] = {
					["RayObject"] = Ray.new(aFuckingGun.Muzzle.Position, targetPlr.Character.Head.Position),
					["Distance"] = (HRP.Position - targetPlr.Character.HumanoidRootPart.Position).Magnitude,
					["Cframe"] = targetPlr.Character.Head.CFrame,
					["Hit"] = targetPlr.Character.Head
				},
				[5] = {
					["RayObject"] = Ray.new(aFuckingGun.Muzzle.Position, targetPlr.Character.Head.Position),
					["Distance"] = (HRP.Position - targetPlr.Character.HumanoidRootPart.Position).Magnitude,
					["Cframe"] = targetPlr.Character.Head.CFrame,
					["Hit"] = targetPlr.Character.Head
				},
			},
			[2] = aFuckingGun
		}
		TeamEvent:FireServer("Medium stone grey")
		ShootEvent:FireServer(table.unpack(remote_args))
		ReloadEvent:FireServer(aFuckingGun)
		TeamEvent:FireServer("Bright orange")
	end
end

local HeavyPunch = function()
	StandStates.AbilityState = "HeavyPunch"
	setUpdateState(false)
	StandoCFrame = CFrame.new(Vector3.new(0, .25, -2.25))
	Humanoid.WalkSpeed = 9.625
	createMessage("MUDAAAAA!!")
	Motors.Neck.CFrame = Motors.Neck.Cache * CFrame.Angles(0, 0, -rad(20))
	Motors.LS.CFrame = Motors.LS.Cache * CFrame.Angles(-rad(3.5), 0, 0)
	Motors.RS.CFrame = Motors.RS.Cache * CFrame.Angles(-rad(25), 0, rad(15))
	Motors.RJoint.CFrame = Motors.RJoint.Cache * CFrame.Angles(rad(7.25), 0, -rad(30))
	wait(.375)
	Motors.Neck.CFrame = Motors.Neck.Cache * CFrame.Angles(-rad(15), 0, rad(12.5))
	Motors.LS.CFrame = Motors.LS.Cache * CFrame.Angles(-rad(3.5), 0, 0)
	Motors.RS.CFrame = Motors.RS.Cache * CFrame.new(Vector3.new(.825, 0, -.25)) * CFrame.Angles(-rad(15), rad(30), rad(120))
	Motors.RJoint.CFrame = Motors.RJoint.Cache * CFrame.Angles(rad(7.25), 0, rad(20))
	dmgPlayer(raycastedPlr)
	wait(.65)
	StandStates.AbilityState = "Idle"
	setUpdateState(true)
	StandoCFrame = StarterStandoCFrame
	Humanoid.WalkSpeed = 16
end

local UnivBarrage = function()
	StandStates.AbilityState = "UnivBarrage"
	setUpdateState(false)
	univBrgeTargetPlr = getPlrFromBasePart(Mouse.Target) or nil
	if univBrgeTargetPlr and univBrgeTargetPlr.Character:FindFirstChild("HumanoidRootPart") then
		univBrgeTPlrHRP = univBrgeTargetPlr.Character.HumanoidRootPart
		wait(.3)
		dmgPlayer(univBrgeTargetPlr)
		wait(3.375) -- just waits 'till its done yielding
	end
	if StandStates.AbilityState == "UnivBarrage" then
		StandStates.AbilityState = "Idle"
		setUpdateState(true)
	end
end

local TimeStop = function()
	StandStates.AbilityState = "TimeStop"
	StandStates.CanUpdateStates = false
	StandoCFrame = CFrame.new(Vector3.new(0, .25, -1.75))
	HRP.Anchored = true
	ColorCE.Enabled = true
	createMessage("ZA WARUDOOOOO!")
	for _, animObj in pairs(Humanoid:GetPlayingAnimationTracks()) do animObj:Stop() end
	Motors.Neck.CFrame = Motors.Neck.Cache * CFrame.Angles(rad(40), 0, 0)
	Motors.LS.CFrame = Motors.LS.Cache * CFrame.new(Vector3.new(0, .5, .25)) * CFrame.Angles(rad(90), 0, -rad(45))
	Motors.RS.CFrame = Motors.RS.Cache * CFrame.new(Vector3.new(0, .5, .25)) * CFrame.Angles(rad(90), 0, rad(45))
	Motors.RJoint.CFrame = Motors.RJoint.Cache * CFrame.Angles(rad(7.25), 0, 0)
	wait(.55)
	Motors.Neck.CFrame = Motors.Neck.Cache * CFrame.Angles(-rad(15), 0, 0)
	Motors.LS.CFrame = Motors.LS.Cache * CFrame.new(Vector3.new(0, .5, .25)) * CFrame.Angles(rad(90), 0, -rad(140))
	Motors.RS.CFrame = Motors.RS.Cache * CFrame.new(Vector3.new(0, .5, .25)) * CFrame.Angles(rad(90), 0, rad(140))
	Motors.RJoint.CFrame = Motors.RJoint.Cache * CFrame.Angles(rad(7.25), 0, 0)
	for _ = 1, 10 do
		ColorCE.Saturation -= .1
		ColorCE.Contrast += .1
		wait(.025)
	end
	wait(.15)
	Humanoid.WalkSpeed = 25
	StandStates.IsTimeStopMode = true
	anchorPlrs(true)
	settings():GetService("NetworkSettings").IncomingReplicationLag = math.huge
	HRP.Anchored = false
	Humanoid:ChangeState("Freefall")
	StandoCFrame = StarterStandoCFrame
	StandStates.AbilityState = "Idle"
	wait(8)
	for _ = 1, 10 do
		ColorCE.Saturation += .1
		ColorCE.Contrast -= .1
		wait(.025)
	end
	Humanoid.WalkSpeed = 16
	ColorCE.Enabled = false
	StandStates.CanUpdateStates = true
	StandStates.IsTimeStopMode = false
	anchorPlrs(false)
	settings():GetService("NetworkSettings").IncomingReplicationLag = 0
end

local StandoJump = function()
	StandStates.AbilityState = "StandoJump"
	setUpdateState(false)
	StandoCFrame = CFrame.new(Vector3.new(0, 2, 3.25))
	Motors.Neck.CFrame = Motors.Neck.Cache * CFrame.Angles(-rad(25), 0, 0)
	Motors.RS.CFrame = Motors.RS.Cache * CFrame.Angles(-rad(5), 0, -rad(15))
	Motors.LS.CFrame = Motors.LS.Cache * CFrame.Angles(-rad(5), 0, rad(15))
	Motors.RH.CFrame = Motors.RH.Cache * CFrame.Angles(0, rad(2.5), -rad(7.5))
	Motors.LH.CFrame = Motors.LH.Cache * CFrame.Angles(0, rad(2.5), rad(7.5))
	Motors.RJoint.CFrame = Motors.RJoint.Cache * CFrame.Angles(rad(25), 0, 0)
	HRP.Velocity = Vector3.new(0, 150, 0) + (HRP.CFrame.LookVector * 115)
	for _ = 1, 5 do Humanoid:ChangeState("Jumping") end
	wait(.1)
	Humanoid.FreeFalling:Wait()
	StandStates.AbilityState = "Idle"
	StandoCFrame = StarterStandoCFrame
	setUpdateState(true)
	HRP.Velocity = Vector3.new()
end

local MenanceIdleAnim = function()
	for _, animObj in pairs(Humanoid:GetPlayingAnimationTracks()) do animObj:Stop() end
	StandStates.AbilityState = "MenanceIdle"
	setUpdateState(false)
	HRP.Anchored = true
	StandoCFrame = CFrame.new(Vector3.new(0, 0, 1.25)) * CFrame.Angles(0, rad(180), 0)
	wait(.125)
	setUpdateState(true)
end

_G.Connections[#_G.Connections + 1] = UIS.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Keyboard and not UIS:GetFocusedTextBox() and not GuiService.MenuIsOpen then
		if input.KeyCode == Enum.KeyCode.Q and StandStates.CanUpdateStates and StandStates.AbilityState ~= "MenanceIdle" then
			StandStates.Enabled = not StandStates.Enabled
			if StandStates.Enabled then
				createMessage("FE STAND!")
				StandStates.AbilityState = "Idle"
				Humanoid.WalkSpeed = 16
				HRP.Anchored = false
				StandoCFrame = StarterStandoCFrame
			end
		elseif StandStates.Enabled and (StandStates.CanUpdateStates or (StandStates.CanUpdateStates2 and StandStates.IsTimeStopMode)) then
			if StandStates.AbilityState == "Idle" and StandKeybinds[input.KeyCode] and StandStates.AbilityState ~= StandKeybinds[input.KeyCode] then
				if StandKeybinds[input.KeyCode] == "Barrage" then
					StandStates.AbilityState = "Barrage"
					setUpdateState(false)
					Humanoid.WalkSpeed = 9.275
					StandoCFrame = CFrame.new(Vector3.new(0, .25, -2.25))
					createMessage("MUDA! (bunch of barrages lol)")
				elseif StandKeybinds[input.KeyCode] == "HeavyPunch" then
					HeavyPunch()
				elseif StandKeybinds[input.KeyCode] == "UnivBarrage" then
					UnivBarrage()
				elseif StandKeybinds[input.KeyCode] == "StandoJump" then
					StandoJump()
				elseif StandKeybinds[input.KeyCode] == "MenanceIdle" then
					MenanceIdleAnim()
				elseif StandKeybinds[input.KeyCode] == "TimeStop" and not StandStates.IsTimeStopMode then
					TimeStop()
				end
			elseif StandStates.AbilityState ~= "Idle" and StandKeybinds[input.KeyCode] then
				StandStates.AbilityState = "Idle"
				Humanoid.WalkSpeed = 16
				HRP.Anchored = false
				StandoCFrame = StarterStandoCFrame
			end
		end
	end
end)

_G.Connections[#_G.Connections + 1] = UIS.InputEnded:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Keyboard and not UIS:GetFocusedTextBox() and not GuiService.MenuIsOpen then
		if StandKeybinds[input.KeyCode] == "Barrage" and StandStates.AbilityState == "Barrage" then
			StandStates.AbilityState = "Idle"
			setUpdateState(true)
			Humanoid.WalkSpeed = 16
			StandoCFrame = StarterStandoCFrame
		end
	end
end)

_G.Connections[#_G.Connections + 1] = RunService.Stepped:Connect(function()
	anim = (anim % 100) + animSpeed / 10

	for _, object in ipairs(StandCharacter:GetDescendants()) do if object:IsA("BasePart") then object.CanCollide = false end end
	for _, motor in pairs(Motors) do motor.Object.Transform = motor.Object.Transform:Lerp(motor.CFrame, .675) end

	if StandStates.Enabled then
		if StandStates.AbilityState == "Idle" then
			animSpeed = .325
			Motors.Neck.CFrame = Motors.Neck.Cache * CFrame.Angles(rad(5) + -cos(anim) * .05, 0, 0)
			Motors.LS.CFrame = Motors.LS.Cache * CFrame.new(Vector3.new(-.1875, .205, -.335)) * CFrame.Angles(rad(87.25), -rad(2.675) + cos(anim) * .0425, -rad(3.675) + cos(anim) * .0225)
			Motors.LH.CFrame = Motors.LH.Cache * CFrame.Angles(0, 0, rad(2.5) * cos(anim) * .5)
			Motors.RS.CFrame = Motors.RS.Cache * CFrame.new(Vector3.new(.1825, .345, -.335)) * CFrame.Angles(rad(87.25), rad(2.425) + -cos(anim) * .0455, rad(3.675) + -cos(anim) * .0225)
			Motors.RH.CFrame = Motors.RH.Cache * CFrame.new(Vector3.new(.325 + cos(anim) * .075, 0, 0)) * CFrame.Angles(0, 0, -rad(10) + sin(anim) * .1)
			Motors.RJoint.CFrame = Motors.RJoint.Cache * CFrame.new(Vector3.new(0, 0, -cos(anim) * .105)) * CFrame.Angles(0, 0, rad(7.5))
		elseif StandStates.AbilityState == "MenanceIdle" then
			animSpeed = .325
			Motors.Neck.CFrame = Motors.Neck.Cache * CFrame.Angles(rad(15) + cos(anim) * .0325, 0, rad(22.5))
			Motors.LS.CFrame = Motors.LS.Cache * CFrame.Angles(rad(6), -rad(6.5) + cos(anim) * .075, -rad(4) + sin(anim) * .05)
			Motors.LH.CFrame = Motors.LH.Cache * CFrame.Angles(0, cos(anim) * .035, -rad(3.5))
			Motors.RS.CFrame = Motors.RS.Cache * CFrame.Angles(-rad(3.5), cos(anim) * .03, cos(anim) * .05)
			Motors.RH.CFrame = Motors.RH.Cache * CFrame.new(Vector3.new(.25 + cos(anim) * .05, 0, 0)) * CFrame.Angles(0, 0, -rad(10) + sin(anim) * .05)
			Motors.RJoint.CFrame = Motors.RJoint.Cache * CFrame.new(Vector3.new(cos(anim) * .0125, 0, 0))
		elseif StandStates.AbilityState == "Barrage" or StandStates.AbilityState == "UnivBarrage" then
			animSpeed = 5
			Motors.Neck.CFrame = Motors.Neck.Cache * CFrame.Angles(rad(7.5) + -cos(anim) * .025, 0, 0)
			Motors.LS.CFrame = Motors.LS.Cache * CFrame.new(Vector3.new(-1 - sin(anim) * 1.5, .5, .325 + -sin(anim) * .25)) * CFrame.Angles(rad(90), 0, -rad(77.5))
			Motors.RS.CFrame = Motors.RS.Cache * CFrame.new(Vector3.new(1 - sin(anim) * 1.5, .5, .325 + sin(anim) * .25)) * CFrame.Angles(rad(90), 0, rad(77.5))
			Motors.RJoint.CFrame = Motors.RJoint.Cache
			if StandStates.AbilityState == "UnivBarrage" and univBrgeTargetPlr and univBrgeTargetPlr.Character.Humanoid.Health == 0 then
				univBrgeTargetPlr, univBrgeTPlrHRP = nil, nil
				StandStates.AbilityState = "Idle"
				setUpdateState(true)
			end
		end
	else
		StandoCFrame = CFrame.new(Vector3.new(1000, 1000 + RandomObj:NextInteger(1, 100), 1000))
	end

	local rayResult = workspace:Raycast(HRP.Position, HRP.CFrame.LookVector * 3.8, rayParams)
	if rayResult then
		local hitPart = rayResult.Instance
		local rayTargetPlr = getPlrFromBasePart(hitPart)
		if rayTargetPlr then
			local rTrgPlrChar = rayTargetPlr.Character
			local rTrgPlrHRP = rTrgPlrChar.HumanoidRootPart
			local plrDistFromTrgPlr = floor((HRP.Position - rTrgPlrHRP.Position).magnitude)
			raycastedPlr = (plrDistFromTrgPlr < 5 and rayTargetPlr or nil)
		end
	end
end)

_G.Connections[#_G.Connections + 1] = RunService.Heartbeat:Connect(function()
	StandoHRP.CFrame = (
		(StandStates.AbilityState == "UnivBarrage" and univBrgeTargetPlr and univBrgeTPlrHRP) and univBrgeTPlrHRP.CFrame * CFrame.new(Vector3.new(0, .45, 3.865))
		or HRP.CFrame * StandoCFrame
	)
	for PartName, object in pairs(HatParts) do
		if object and object:FindFirstChild("Handle") then
			object.Handle.LocalTransparencyModifier = (Character.Head.LocalTransparencyModifier == 1 and .5 or Character.Head.LocalTransparencyModifier)
			if PartName == "Torso1" then
				object.Handle.CFrame = StandCharacter.Torso.CFrame * CFrame.new(Vector3.new(.5, 0, 0)) * CFrame.Angles(rad(90), 0, 0)
			elseif PartName == "Torso2" then
				object.Handle.CFrame = StandCharacter.Torso.CFrame * CFrame.new(Vector3.new(-.5, 0, 0)) * CFrame.Angles(rad(90), 0, 0)
			elseif PartName == "Torso" then
				object.Handle.CFrame = StandCharacter.Torso.CFrame * CFrame.Angles(rad(90), 0, 0)
			elseif PartName == "Head" then
				object.Handle.CFrame = StandCharacter.Head.CFrame * HeadOffset
			else
				object.Handle.CFrame = StandCharacter[PartName].CFrame * CFrame.Angles(rad(90), 0, 0)
			end
		end
	end
end)

if UseBuiltinNetless then
	-- // SERVICES
	local NetworkClient = game:GetService("NetworkClient")
	-- // MAIN
	_G.Connections[#_G.Connections + 1] = RunService.Stepped:Connect(function()
		settings().Physics.AllowSleep = false
		settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.DefaultAuto
		settings().Physics.ThrottleAdjustTime = 0 / 1 / 0
		NetworkClient:SetOutgoingKBPSLimit(math.huge)

		for _, object in pairs(HatParts) do
			if object and object:FindFirstChild("Handle") then
				object.Handle.CanCollide = false
				object.Handle.Massless = true
				object.Handle.Velocity = Vector3.new(-25.05, -25.05, -25.05)
				object.Handle.RotVelocity = Vector3.new()
			end
		end
	end)
end

_G.Connections[#_G.Connections + 1] = Humanoid.Died:Connect(onCharacterRemoved)
_G.Connections[#_G.Connections + 1] = Player.CharacterRemoving:Connect(onCharacterRemoved)
