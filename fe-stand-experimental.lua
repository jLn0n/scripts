-- NOT RECOMENDED TO USE
--[[
	Info:
	Hey im jLn0n, u may know me as mengcap_CLEETUS or YEETED_CLEETUS on roblox, im not the original creator of the all known
	leaked fe stand script, I made this script on 6/2/2021 from scratch because the leaked FE stand script has been patched
	by roblox, if the stando is gone or not showing when executed first on ur executor please rejoin and execute it again.
	Read things that I've written below to guide you using the script.

	Hats Needed:
	https://www.roblox.com/catalog/617605556 (you can use any hats and offset the head with HeadOffset variable and remove the head mesh with RemoveHeadMesh variable)
	https://www.roblox.com/catalog/451220849
	https://www.roblox.com/catalog/63690008
	https://www.roblox.com/catalog/48474294 (bundle: https://www.roblox.com/bundles/282)
	https://www.roblox.com/catalog/48474313
	https://www.roblox.com/catalog/62234425
	https://www.roblox.com/catalog/62724852 (bundle: https://www.roblox.com/bundles/239)

	Keybinds:
	Q - Summon / Unsummon stand
	E - Barrage
	R - HeavyPunch
	F - Time Stop
	Z - Stando Jump
	G - Stand Idle Menance thingy
--]]
-- // SETTINGS
local HeadName = "MediHood" -- you can find the name of ur desired head by using dex or viewing it with btroblox (chrome extension)
local HeadOffset = CFrame.new(Vector3.new(0, .125, .25)) -- offsets the desired head
local RemoveHeadMesh = false -- removes the mesh of the desired head when enabled
local StarterStandoCFramePos = CFrame.new(Vector3.new(-1.75, 1.65, 2.5)) -- the starting position of the stand
local EnableChats = false -- enables character chatting when a action was enabled / changed
local NerfHitDamages = false -- nerfs the damage from the stand, if u will have a stand fight just enable this lol (player damaging only works on prison life)
local UseBuiltinNetless = true -- enables builtin netless that on this script when enabled, if u want to use ur own netless just disable this, execute ur netless script first and this script
-- // SERVICES
local GuiService = game:GetService("GuiService")
local Lighting = game:GetService("Lighting")
local Players = game:GetService("Players")
local RepStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local UIS = game:GetService("UserInputService")
-- // OBJECTS
local Player = Players.LocalPlayer
local Character = Player.Character
local Humanoid = Character.Humanoid
local HRP = Character.HumanoidRootPart
local ChatMakeMsg, meleeEvent = RepStorage.DefaultChatSystemChatEvents.SayMessageRequest
-- // VARIABLES
_G.Connections = _G.Connections or {}
local rad, sin, cos, RandomObj = math.rad, math.sin, math.cos, Random.new(os.clock())
local HatParts = {
	["Head"] = Character:FindFirstChild(HeadName),
	["Left Arm"] = Character:FindFirstChild("Pal Hair"),
	["Left Leg"] = Character:FindFirstChild("Pink Hair"),
	["Right Arm"] = Character:FindFirstChild("Hat1"),
	["Right Leg"] = Character:FindFirstChild("LavanderHair"),
	["Torso1"] = Character:FindFirstChild("Robloxclassicred"),
	["Torso2"] = Character:FindFirstChild("Kate Hair")
}
local StandoStates = {
	["Enabled"] = false,
	["ModeState"] = "Idle",
	["IsTimeStopMode"] = false,
	["CanUpdateStates"] = true,
	["CanUpdateStates2"] = true,
}
local StandoKeybinds = {
	[Enum.KeyCode.E] = "Barrage",
	[Enum.KeyCode.R] = "HeavyPunch",
	[Enum.KeyCode.F] = "TimeStop",
	[Enum.KeyCode.G] = "MenanceIdle",
	[Enum.KeyCode.Z] = "StandoJump"
}
local StandoCFrame = CFrame.new()
local anim, animSpeed = 0, 0
local rayParams, rayResult, targetPlayer
-- // MAIN
assert(not Character:FindFirstChild("StandoCharacter"), [[["FE-STANDO.LUA"]: Please reset to be able to run the script again!]])
assert(Humanoid.RigType == Enum.HumanoidRigType.R6, [[["FE-STANDO.LUA"]: Sorry, R6 only!]])
for _, connection in ipairs(_G.Connections) do connection:Disconnect() end _G.Connections = {}
local StandoCharacter = game:GetObjects("rbxassetid://6843243348")[1]
local StandoHRP = StandoCharacter.HumanoidRootPart
local ColorCE = Lighting:FindFirstChild("TimeStopCCE") or Instance.new("ColorCorrectionEffect")
StandoCharacter.Name, StandoCharacter.Parent = "StandoCharacter", Character
ColorCE.Name, ColorCE.Parent = "TimeStopCCE", Lighting
meleeEvent, rayParams = (game.PlaceId == 155615604 and RepStorage:FindFirstChild("meleeEvent") or nil), RaycastParams.new()
rayParams.FilterType, rayParams.FilterDescendantsInstances = Enum.RaycastFilterType.Blacklist, {Character}

local initMotor = function(motor)
	return {
		Object = motor,
		CFrame = motor.Transform,
		Cache = motor.Transform
	}
end

local Motors = {
	["Neck"] = initMotor(StandoCharacter.Torso.Neck),
	["RS"] = initMotor(StandoCharacter.Torso["Right Shoulder"]),
	["LS"] = initMotor(StandoCharacter.Torso["Left Shoulder"]),
	["RH"] = initMotor(StandoCharacter.Torso["Right Hip"]),
	["LH"] = initMotor(StandoCharacter.Torso["Left Hip"]),
	["RJoint"] = initMotor(StandoHRP.RootJoint),
}

for _, object in ipairs(StandoCharacter:GetChildren()) do if object:IsA("BasePart") then object.Transparency = 1 end end
for PartName, object in pairs(HatParts) do
	if object.Handle:FindFirstChildWhichIsA("Weld") then object.Handle:FindFirstChildWhichIsA("Weld"):Destroy() end
	if PartName == "Head" and RemoveHeadMesh then
		object.Handle:FindFirstChildWhichIsA("SpecialMesh"):Destroy()
	elseif PartName ~= "Head" then
		object.Handle:FindFirstChildWhichIsA("SpecialMesh"):Destroy()
	end
end

local setUpdateState = function(boolean) StandoStates.CanUpdateStates, StandoStates.CanUpdateStates2 = boolean, boolean end
local createMessage = function(msg) ChatMakeMsg:FireServer((EnableChats and msg) and msg, "All") end
local setDamage = function(plr) if meleeEvent then meleeEvent:FireServer(plr and plr) end end
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

local Barrage = function()
	StandoStates.ModeState = "Barrage"
	setUpdateState(false)
	StandoCFrame = CFrame.new(Vector3.new(0, .25, -2.25))
	Humanoid.WalkSpeed = 6.3525
	Motors.Neck.CFrame = Motors.Neck.Cache * CFrame.Angles(rad(7.5), 0, 0)
	Motors.LS.CFrame = Motors.LS.Cache * CFrame.new(Vector3.new(0, .5, .5)) * CFrame.Angles(rad(90), 0, -rad(90))
	Motors.RS.CFrame = Motors.RS.Cache * CFrame.new(Vector3.new(0, .5, .5)) * CFrame.Angles(rad(90), 0, rad(90))
	Motors.RJoint.CFrame = Motors.RJoint.Cache
	wait()
	createMessage("MUDA! (x15)")
	for _ = 1, 15 do
		local damaging, damaging2 = (not NerfHitDamages and true or RandomObj:NextInteger(1, 10) < 7), (not NerfHitDamages and true or RandomObj:NextInteger(1, 10) < 7)
		setDamage(damaging and targetPlayer or nil)
		Motors.RJoint.CFrame = Motors.RJoint.Cache * CFrame.new(Vector3.new(.1)) * CFrame.Angles(rad(7.5), 0, 0)
		Motors.LS.CFrame = Motors.LS.Cache * CFrame.new(Vector3.new(-3.5, .5, 0)) * CFrame.Angles(rad(90), 0, -rad(32.5))
		wait(.075)
		Motors.RJoint.CFrame = Motors.RJoint.Cache * CFrame.new(Vector3.new(-.1)) * CFrame.Angles(rad(7.25), 0, 0)
		Motors.RS.CFrame = Motors.RS.Cache * CFrame.new(Vector3.new(3.5, .5, 0)) * CFrame.Angles(rad(90), 0, rad(32.5))
		Motors.LS.CFrame = Motors.LS.Cache * CFrame.new(Vector3.new(0, .5, .5)) * CFrame.Angles(rad(90), 0, -rad(90))
		wait(.075)
		Motors.RS.CFrame = Motors.RS.Cache * CFrame.new(Vector3.new(0, .5, .5)) * CFrame.Angles(rad(90), 0, rad(90))
		wait(.025)
		setDamage(damaging2 and targetPlayer or nil)
	end
	StandoStates.ModeState = "Idle"
	setUpdateState(true)
	Humanoid.WalkSpeed = 16
	StandoCFrame = StarterStandoCFramePos
end

local HeavyPunch = function()
	StandoStates.ModeState = "HeavyPunch"
	setUpdateState(false)
	StandoCFrame = CFrame.new(Vector3.new(0, .25, -2.25))
	Humanoid.WalkSpeed = 5.6575
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
	for _ = 1, (NerfHitDamages and RandomObj:NextInteger(5, 7) or 25) do setDamage(targetPlayer) end
	wait(.65)
	StandoStates.ModeState = "Idle"
	setUpdateState(true)
	StandoCFrame = StarterStandoCFramePos
	Humanoid.WalkSpeed = 16
end

local TimeStop = function()
	StandoStates.ModeState = "TimeStop"
	StandoStates.CanUpdateStates = false
	StandoCFrame = CFrame.new(Vector3.new(0, .25, -1.75))
	HRP.Anchored = true
	ColorCE.Enabled = true
	createMessage("ZA WARUDOOOOO!")
	for _, animObj in pairs(Humanoid:GetPlayingAnimationTracks()) do animObj:Stop() end
	Motors.Neck.CFrame = Motors.Neck.Cache * CFrame.Angles(rad(40), 0, 0)
	Motors.LS.CFrame = Motors.LS.Cache * CFrame.new(Vector3.new(0, .5, .5)) * CFrame.Angles(rad(90), 0, -rad(45))
	Motors.RS.CFrame = Motors.RS.Cache * CFrame.new(Vector3.new(0, .5, .5)) * CFrame.Angles(rad(90), 0, rad(45))
	Motors.RJoint.CFrame = Motors.RJoint.Cache * CFrame.Angles(rad(7.25), 0, 0)
	wait(.55)
	Motors.Neck.CFrame = Motors.Neck.Cache * CFrame.Angles(-rad(15), 0, 0)
	Motors.LS.CFrame = Motors.LS.Cache * CFrame.new(Vector3.new(0, .5, .5)) * CFrame.Angles(rad(90), 0, -rad(140))
	Motors.RS.CFrame = Motors.RS.Cache * CFrame.new(Vector3.new(0, .5, .5)) * CFrame.Angles(rad(90), 0, rad(140))
	Motors.RJoint.CFrame = Motors.RJoint.Cache * CFrame.Angles(rad(7.25), 0, 0)
	for _ = 1, 10 do
		ColorCE.Saturation -= .1
		ColorCE.Contrast += .1
		wait(.025)
	end
	wait(.15)
	Humanoid.WalkSpeed = 25
	StandoStates.IsTimeStopMode = true
	anchorPlrs(true)
	settings():GetService("NetworkSettings").IncomingReplicationLag = math.huge
	HRP.Anchored = false
	Humanoid:ChangeState("Freefall")
	StandoCFrame = StarterStandoCFramePos
	StandoStates.ModeState = "Idle"
	wait(8)
	for _ = 1, 10 do
		ColorCE.Saturation += .1
		ColorCE.Contrast -= .1
		wait(.025)
	end
	Humanoid.WalkSpeed = 16
	ColorCE.Enabled = false
	StandoStates.CanUpdateStates = true
	StandoStates.IsTimeStopMode = false
	anchorPlrs(false)
	settings():GetService("NetworkSettings").IncomingReplicationLag = 0
end

local StandoJump = function()
	StandoStates.ModeState = "StandoJump"
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
	StandoStates.ModeState = "Idle"
	StandoCFrame = StarterStandoCFramePos
	wait(.125)
	setUpdateState(true)
	HRP.Velocity = Vector3.new()
end

local MenanceIdleAnim = function()
	for _, animObj in pairs(Humanoid:GetPlayingAnimationTracks()) do animObj:Stop() end
	StandoStates.ModeState = "MenanceIdle"
	setUpdateState(false)
	HRP.Anchored = true
	StandoCFrame = CFrame.new(Vector3.new(0, 0, 1.25)) * CFrame.Angles(0, rad(180), 0)
	wait(.125)
	setUpdateState(true)
end

_G.Connections[#_G.Connections + 1] = UIS.InputBegan:Connect(function(input)
	if input.UserInputType == Enum.UserInputType.Keyboard and not UIS:GetFocusedTextBox() and not GuiService.MenuIsOpen then
		if input.KeyCode == Enum.KeyCode.Q and StandoStates.CanUpdateStates and StandoStates.ModeState ~= "MenanceIdle" then
			StandoStates.Enabled = not StandoStates.Enabled
			if StandoStates.Enabled then
				createMessage("FE SUTANDO!")
				StandoStates.ModeState = "Idle"
				Humanoid.WalkSpeed = 16
				HRP.Anchored = false
				StandoCFrame = StarterStandoCFramePos
			end
		elseif StandoStates.Enabled and (StandoStates.CanUpdateStates or (StandoStates.CanUpdateStates2 and StandoStates.IsTimeStopMode)) then
			if StandoStates.ModeState == "Idle" and StandoKeybinds[input.KeyCode] and StandoStates.ModeState ~= StandoKeybinds[input.KeyCode] then
				if StandoKeybinds[input.KeyCode] == "Barrage" then
					Barrage()
				elseif StandoKeybinds[input.KeyCode] == "HeavyPunch" then
					HeavyPunch()
				elseif StandoKeybinds[input.KeyCode] == "StandoJump" then
					StandoJump()
				elseif StandoKeybinds[input.KeyCode] == "MenanceIdle" then
					MenanceIdleAnim()
				elseif StandoKeybinds[input.KeyCode] == "TimeStop" and not StandoStates.IsTimeStopMode then
					TimeStop()
				end
			elseif StandoStates.ModeState ~= "Idle" and StandoKeybinds[input.KeyCode] then
				StandoStates.ModeState = "Idle"
				Humanoid.WalkSpeed = 16
				HRP.Anchored = false
				StandoCFrame = StarterStandoCFramePos
			end
		end
	end
end)

_G.Connections[#_G.Connections + 1] = RunService.Stepped:Connect(function()
	anim = (anim % 100) + animSpeed / 10

	for _, object in ipairs(StandoCharacter:GetDescendants()) do if object:IsA("BasePart") then object.CanCollide = false end end
	for _, motor in pairs(Motors) do motor.Object.Transform = motor.Object.Transform:Lerp(motor.CFrame, .25) end

	if UseBuiltinNetless then
		settings().Physics.AllowSleep = false
		settings().Physics.PhysicsEnvironmentalThrottle = Enum.EnviromentalPhysicsThrottle.DefaultAuto
		settings().Physics.ThrottleAdjustTime = 0 / 1 / 0

		for _, object in pairs(HatParts) do
			if object and object:FindFirstChild("Handle") then
				object.Handle.CanCollide = false
				object.Handle.Massless = true
				object.Handle.Velocity = Vector3.new(-25.05, -25.05, -25.05)
				object.Handle.RotVelocity = Vector3.new()
			end
		end
	end

	if StandoStates.Enabled then
		if StandoStates.ModeState == "Idle" then
			animSpeed = .325
			Motors.Neck.CFrame = Motors.Neck.Cache * CFrame.Angles(rad(7.5) + cos(anim) * .0375, 0, 0)
			Motors.LS.CFrame = Motors.LS.Cache * CFrame.Angles(rad(6), -rad(6.5) + cos(anim) * .075, -rad(4) + sin(anim) * .05)
			Motors.LH.CFrame = Motors.LH.Cache * CFrame.Angles(0, 0, rad(5) * cos(anim) * .5)
			Motors.RS.CFrame = Motors.RS.Cache * CFrame.Angles(-rad(3.5), cos(anim) * .05, cos(anim) * .065)
			Motors.RH.CFrame = Motors.RH.Cache * CFrame.new(Vector3.new(.325 + cos(anim) * .075, 0, 0)) * CFrame.Angles(0, 0, -rad(10) + sin(anim) * .1)
			Motors.RJoint.CFrame = Motors.RJoint.Cache * CFrame.new(Vector3.new(0, 0, -cos(anim) * .125)) * CFrame.Angles(0, 0, rad(7.5))
		elseif StandoStates.ModeState == "MenanceIdle" then
			animSpeed = .325
			Motors.Neck.CFrame = Motors.Neck.Cache * CFrame.Angles(rad(15) + cos(anim) * .0325, 0, rad(22.5))
			Motors.LS.CFrame = Motors.LS.Cache * CFrame.Angles(rad(6), -rad(6.5) + cos(anim) * .075, -rad(4) + sin(anim) * .05)
			Motors.LH.CFrame = Motors.LH.Cache * CFrame.Angles(0, cos(anim) * .035, -rad(3.5))
			Motors.RS.CFrame = Motors.RS.Cache * CFrame.Angles(-rad(3.5), cos(anim) * .03, cos(anim) * .05)
			Motors.RH.CFrame = Motors.RH.Cache * CFrame.new(Vector3.new(.25 + cos(anim) * .05, 0, 0)) * CFrame.Angles(0, 0, -rad(10) + sin(anim) * .05)
			Motors.RJoint.CFrame = Motors.RJoint.Cache * CFrame.new(Vector3.new(cos(anim) * .0125, 0, 0))
		end
	else
		StandoCFrame = CFrame.new(Vector3.new(1000, 1000 + RandomObj:NextInteger(1, 100), 1000))
		for _, motor in pairs(Motors) do motor.CFrame = motor.Cache end
	end

	rayResult = (meleeEvent and workspace:Raycast(HRP.Position, HRP.CFrame.LookVector * 3.8, rayParams) or nil)
	if rayResult then
		local hitPart = rayResult.Instance
		if hitPart.Parent:IsA("Model") then
			targetPlayer = Players:GetPlayerFromCharacter(hitPart.Parent)
		elseif hitPart.Parent:IsA("Accessory") or hitPart.Parent:IsA("Tool") then
			targetPlayer = Players:GetPlayerFromCharacter(hitPart.Parent.Parent)
		end
	end
end)

_G.Connections[#_G.Connections + 1] = RunService.Heartbeat:Connect(function()
	StandoHRP.CFrame = HRP.CFrame * StandoCFrame
	for PartName, object in pairs(HatParts) do
		if object and object:FindFirstChild("Handle") then
			if PartName == "Torso1" then
				object.Handle.CFrame = StandoCharacter.Torso.CFrame * CFrame.new(Vector3.new(.5, 0, 0)) * CFrame.Angles(rad(90), 0, 0)
			elseif PartName == "Torso2" then
				object.Handle.CFrame = StandoCharacter.Torso.CFrame * CFrame.new(Vector3.new(-.5, 0, 0)) * CFrame.Angles(rad(90), 0, 0)
			elseif PartName == "Head" then
				object.Handle.CFrame = StandoCharacter.Head.CFrame * HeadOffset
			else
				object.Handle.CFrame = StandoCharacter[PartName].CFrame * CFrame.Angles(rad(90), 0, 0)
			end
		end
	end
end)

_G.Connections[#_G.Connections + 1] = Humanoid.Died:Connect(onCharacterRemoved)
_G.Connections[#_G.Connections + 1] = Player.CharacterRemoving:Connect(onCharacterRemoved)
