local config do
	config = {
		lagPerSecond = 2.5,
		lagPosOffset = CFrame.new(Vector3.yAxis * -6) * CFrame.Angles(math.rad(90), 0, 0),
	}

	getgenv().FAKELAG_CONFIG = config
end
-- services
local runService = game:GetService("RunService")
-- objects
local player = game:GetService("Players").LocalPlayer
local character, rootPart
-- variables
local lagData = {
	lastLagTime = 0,
	oldCharPos = CFrame.identity
}
-- function
local function onCharacterAdded(newChar)
	task.wait(.5)
	character = newChar
	rootPart = newChar:WaitForChild("HumanoidRootPart")
end
-- main
onCharacterAdded(player.Character or player.CharacterAdded:Wait())
player.CharacterAdded:Connect(onCharacterAdded)

lagData.lastLagTime = os.clock()
lagData.oldCharPos = rootPart.CFrame
while true do runService.Heartbeat:Wait()
	if not (character and rootPart) then continue end
	local shouldUnlag = ((os.clock() - lagData.lastLagTime) > config.lagPerSecond)

	if shouldUnlag then
		lagData.lastLagTime = os.clock()
		lagData.oldCharPos = rootPart.CFrame

		task.spawn(sethiddenproperty, rootPart, "NetworkIsSleeping", false)
		rootPart.CFrame = (lagData.oldCharPos * config.lagPosOffset)
		runService.PreAnimation:Wait()
		task.spawn(sethiddenproperty, rootPart, "CFrame", lagData.oldCharPos)
	elseif (not shouldUnlag and not gethiddenproperty(rootPart, "NetworkIsSleeping")) then
		task.defer(sethiddenproperty, rootPart, "NetworkIsSleeping", true)
	end
end
