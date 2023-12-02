---@diagnostic disable: undefined-global
--[[
	communication-lib.lua
	@jLn0n | 2023

	A library used to communicate between a program and Cheat Engine while using strings (janky).

	DOCUMENTATION:
	comms_lib.new_id(commsId: string): ()
	- Initializes a new communication id, should only be called once when adding new id.
	- Alphanumeric characters and underscores are only allowed in `commsId`. (A-Za-z0-9_)

	comms_lib.update_addys(): ()
	- Updates all of the added communication id(s).
	- This might be useless since `comms_lib.communicate` & `comms_lib.get_data` already updates the address
	  when its outdated.

	comms_lib.update_addy(commsId: string): ()
	- Tries to update the address of a communication id.

	comms_lib.communicate(commsId: string, data: string): ()
	- Sends `data` to assigned `commsId`.
	- This function will error if `commsId` is not defined by `comms_lib.new_id`.

	comms_lib.get_data(commsId: string): string?
	- Fetches current data of `commsId`.
	- This function will error if `commsId` is not defined by `comms_lib.new_id`.

	comms_lib.new_listener(commsId: string, callback: (data: string, nonce: string) -> ()): Thread
	- Creates a listener for listening changes to data.
	- This function will error if `commsId` is not defined by `comms_lib.new_id`.

	INTEGRATIONS:
	- Libraries that works with communication lib.

	Roblox: https://github.com/jLn0n/scripts/blob/main/cheat-engine/communication_lib_roblox.rbxm

	------------------------------------------------------------------------------------------------
	example: (will only work on https://www.roblox.com/games/14049812318)
	-- first example
	comms_lib.new_id("test") -- defines communication id
	comms_lib.communicate("test", "Hello World!") -- communicates to the program
	print(comms_lib.get_data("test")) -- prints "Hello World!"

	-- listener example
	comms_lib.new_id("test2") -- defines communication id
	comms_lib.new_listener("test2", function(data)
		print("got new data:", data)
	end)
--]]

-- variables
local alloc_size = 2^24 -- 16mb of allocation, allocation only happens in the program itself.
local signature = "R\34" -- you can customize this
local PAYLOAD_TEMPLATE = "%s%s-%s|%08X|%s"
local PAYLOAD_MATCH = "^" .. signature .. "[%w_]+%-%w+|%x+|"
local HEX_MATCH = "|%x+"
local DATA_NONCE_MATCH = "%-%w+|"
local CHAR_LIST = "QWERTYUIOPASDFGHJKLXCVBNMqwertyuiopasdfghjklzxcvbnm"
local comms_lib = {}

-- helpers
local util do
	util = {}

	util.allocateMemory = allocateMemory
	util.startThread = executeCode
	util.freeMemory = deAlloc

	util.aobScan = function(aob, code)
		local result = {}
		local scan_result = AOBScan(aob, "*X*C*W")
		if not scan_result then return result end

		for i = 1, scan_result.Count do
			local addy = getAddress(scan_result[i - 1])
			table.insert(result, addy)
		end
		return result
	end

	util.intToBytes = function(val)
		if not val then
			return error("Cannot convert nil value to byte table")
		end

		local t = {val & 0xFF}
		for i = 1, 7 do
			table.insert(t, (val >> (8 * i)) & 0xFF)
		end
		return t
	end

	util.getMatchedStringAddy = function(search)
		local string_sig = string.gsub(search, ".", function(value) return string.format("%X", string.byte(value)) end)
		local scan_result = util.aobScan(string_sig)
		if not scan_result then return end

		for _idx = 1, #scan_result do
			local address = scan_result[_idx]
			local str = address and readString(address, 1024) or nil

			if (str and string.find(str, search)) then
				return address
			end
		end
	end
end

local function parseData(data)
	local data_sig = string.sub(data, 1, #signature)
	if data_sig ~= signature then
		return
	end

	local str_lenght = string.match(data, HEX_MATCH, 1)
	str_lenght = (str_lenght and tonumber(string.sub(str_lenght, 2), 16) or nil)
	if not str_lenght then
		return
	end

	local nonce = string.match(data, DATA_NONCE_MATCH, 1)
	nonce = (nonce and string.sub(nonce, 2, #nonce - 1) or nil)
	if not nonce then
		return
	end

	local _, payload_end = string.find(data, PAYLOAD_MATCH, 1)
	return string.sub(data, payload_end + 1, payload_end + str_lenght), nonce
end

local function generateNonce()
	local result = {}

	for _ = 1, 5 do
		local randInt = math.random(1, #CHAR_LIST)
		table.insert(result, string.sub(CHAR_LIST, randInt, randInt))
	end
	return table.concat(result)
end

local function compileCommData(commsId, data)
	data = string.sub(data or "", 1, alloc_size)
	commsId = (signature .. commsId)
	local nonce = generateNonce()

	return string.format(PAYLOAD_TEMPLATE, "", commsId, nonce, #data, data), commsId
end

local function fetchCommsAddy(addys_list, commsId)
	local stringAddy = addys_list[commsId]
	if not stringAddy then -- if not found
		return
	end
	if string.sub(readString(stringAddy) or "", 1, 2) == signature then -- verifies signature
		return stringAddy
	end

	local _, commsSig = compileCommData(commsId)
	stringAddy = util.getMatchedStringAddy(commsSig)
	if not stringAddy then
		return
	end

	addys_list[commsId] = stringAddy
	return stringAddy
end

local function _comms_onDataRecieved(thread, commsId, callback)
	thread.Name = "comms_onDataRecieved"
	local data_cache, data_nonce_cache = comms_lib.get_data(commsId, true)

	while not thread.Terminated do
		local current_data, current_data_nonce = comms_lib.get_data(commsId, true)
		if not (current_data and current_data_nonce) then
			thread.terminate()
			thread.destroy()
			break
		end

		if not (data_cache == current_data and data_nonce_cache == current_data_nonce) then
			data_cache, data_nonce_cache = current_data, current_data_nonce
			synchronize(callback, data_cache, data_nonce_cache)
		end
		sleep(1/45 * 1000)
	end
end

-- main
comms_lib.addys = {}

comms_lib.new_id = function(commsId, fetchAddy)
	if not string.find(commsId, "[%w_]+", 1) then
		return error("commsId is invalid.", 0) -- improve error.
	end
	if comms_lib.addys[commsId] then return end
	comms_lib.addys[commsId] = 0

	if fetchAddy then
		fetchCommsAddy(comms_lib.addys, commsId)
	end
end

comms_lib.update_addys = function()
	for commsId in pairs(comms_lib.addys) do
		local stringAddy = fetchCommsAddy(comms_lib.addys, commsId)
		if not stringAddy then
			print("Failed to update address of commsId:", commsId)
			goto continue_commsscan
		end

		print(string.format("'%s' address: %08X", commsId, stringAddy))
		::continue_commsscan::
	end
end

comms_lib.update_addy = function(commsId)
	fetchCommsAddy(comms_lib.addys, commsId)
end

comms_lib.communicate = function(commsId, data, silentError)
	if (not comms_lib.addys[commsId] and not silentError) then
		return error(string.format("Communication Id not defined: '%s'", commsId), 2)
	end

	local stringAddy = fetchCommsAddy(comms_lib.addys, commsId)
	if not stringAddy or stringAddy == 0 then
		return
	end

	local payload = compileCommData(commsId, data)
	writeString(stringAddy, payload)
end

comms_lib.get_data = function(commsId, silentError)
	if (not comms_lib.addys[commsId] and not silentError) then
		return error(string.format("Communication Id not defined: '%s'", commsId), 2)
	end

	local stringAddy = fetchCommsAddy(comms_lib.addys, commsId)
	if not stringAddy or stringAddy == 0 then
		return
	end
	local payload_info_size = (#signature + #commsId + 5 + 10) -- size of payload info thing
	local raw_data = readString(stringAddy, alloc_size + payload_info_size)

	if raw_data then
		return parseData(raw_data)
	end
end

comms_lib.new_listener = function(commsId, callback)
	if (not comms_lib.addys[commsId]) then
		return error(string.format("Communication Id not defined: '%s'", commsId), 2)
	end

	return createThread(_comms_onDataRecieved, commsId, callback)
end

_ENV.comms_lib = comms_lib
return comms_lib
