return error("It doesn't work anymore, sorry!")

--[[ services
local players = game:GetService("Players")
local starterGui = game:GetService("StarterGui")
-- objects
local player = players.LocalPlayer
local character = player.Character
local humanoid = character:FindFirstChildWhichIsA("Humanoid")
local head, neck = character:FindFirstChild("Head"), character:FindFirstChild("Neck", true)
local resetBindable = Instance.new("BindableEvent")
-- variables
local destroyFunc, resetBindableConnection = character.Destroy, nil
local valueResetPlayerGuiOnSpawn = starterGui.ResetPlayerGuiOnSpawn
-- main
-- initializes the permadeath
starterGui.ResetPlayerGuiOnSpawn = false
player.Character = nil
player.Character = character
starterGui.ResetPlayerGuiOnSpawn = valueResetPlayerGuiOnSpawn
task.wait(players.RespawnTime + .05)

humanoid.BreakJointsOnDeath = false
humanoid:SetStateEnabled(Enum.HumanoidStateType.Dead, false)
humanoid:TakeDamage(-10e100)
task.defer(humanoid.ChangeState, humanoid, Enum.HumanoidStateType.Running)
task.defer(destroyFunc, neck) -- destroys the weld of the head first for some magic
task.defer(destroyFunc, head) -- and we destroy the head

resetBindableConnection = resetBindable.Event:Connect(function()
	starterGui:SetCore("ResetButtonCallback", true)
	resetBindableConnection:Disconnect()
	resetBindable:Destroy()

	if player.Character == character then
		character:Destroy()
		local daModel = Instance.new("Model")
		local _daModelHumanoid = Instance.new("Humanoid")
		_daModelHumanoid.Parent = daModel
		player.Character = daModel

		task.delay(players.RespawnTime, destroyFunc, daModel)
	else
		player.Character:BreakJoints()
	end
end)
starterGui:SetCore("ResetButtonCallback", resetBindable)--]]
