---@diagnostic disable: undefined-global
--[[
	communication-lib.lua
	@jLn0n | 2023

	A library used to communicate between a program and Cheat Engine while using strings (janky).

	DOCUMENTATION:
	comms.new_id(commsId: string): ()
	- Used to initialize a new communication id, should only be called once when adding new id.

	comms.update_addys(): ()
	- Used to update the addresses of a string that is assigned by id.
	- This might be useless since `comms.communicate` & `comms.get_data` already updates the address
	  when its outdated.

	comms.communicate(commsId: string, data: string): ()
	- Used to send data within the assigned `commsId`.
	- This function will error if `commsId` is not defined by `comms.new_id`.

	comms.get_data(commsId: string): string?
	- Used to fetch data that the program had transferred to Cheat Engine.
	- This function will error if `commsId` is not defined by `comms.new_id`.

	comms.new_listener(commsId: string, callback: (data: string) -> ()): Thread
	- Used to create a listener for listening changes to data.
	- This function will error if `commsId` is not defined by `comms.new_id`.

	INTEGRATIONS:
	- Libraries that works with this library.

	Roblox: https://github.com/jLn0n/scripts/blob/main/cheat-engine/communication_lib_roblox.rbxm

	------------------------------------------------------------------------------------------------
	example: (will only work on https://www.roblox.com/games/14049812318)
	-- first example
	comms.new_id("test") -- defines communication id
	comms.communicate("test", "Hello World!") -- communicates to the program
	print(comms.get_data("test")) -- prints "Hello World!"

	-- listener example
	comms.new_id("test2") -- defines communication id
	comms.new_listener("test2", function(data)
		print("got new data:", data)
	end)
--]]
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
			error("Cannot convert nil value to byte table")
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
			local value = scan_result[_idx]
			local str = value and readString(value) or nil

			if (str and string.find(str, "^" .. search)) then
				return value
			end
		end
	end
end

-- variables
local alloc_size = 2^24
local signature = "R\34" -- you can customize this
local PAYLOAD_MATCH = "^" .. signature .. "%w+%-%w+|[%x]+|"
local HEX_MATCH = "|%x+"
local DATA_IDX_MATCH = "%-%w+|"
local CHAR_LIST = "QWERTYUIOPASDFGHJKLXCVBNMqwertyuiopasdfghjklzxcvbnm"

-- helper
local function parseData(data)
	local data_sig = string.sub(data, 1, #signature)
	if data_sig ~= signature then
		return
	end

	local str_lenght = string.match(data, HEX_MATCH, 1)
	str_lenght = (str_lenght and tonumber(string.sub(str_lenght, 2, #str_lenght), 16) or nil)
	if not str_lenght then
		return
	end

	local data_id = string.match(data, DATA_IDX_MATCH, 1)
	data_id = (data_id and string.sub(data_id, 2, #data_id - 1) or nil)
	if not data_id then
		return
	end

	local _, payload_end = string.find(data, PAYLOAD_MATCH, 1)
	return string.sub(data, payload_end + 1, payload_end + str_lenght), data_id
end

local function generateDataId()
	local result = {}

	for _ = 1, 5 do
		local randInt = math.random(1, #CHAR_LIST)
		table.insert(result, string.sub(CHAR_LIST, randInt, randInt))
	end
	return table.concat(result)
end

local function compileCommData(commsId, data)
	data = string.sub(data or "", 1, alloc_size)
	commsId = string.format(signature .. "%s", commsId)
	local id = generateDataId()

	return string.format("%s-%s|%08X|%s\0", commsId, id, #data, data), commsId
end

local function fetchCommsAddy(addys_list, commsId)
	local stringAddy = addys_list[commsId]
	if not stringAddy then -- if not found
		return
	end
	if string.sub(readString(stringAddy) or "", 1, 2) == signature then
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
	local data_cache, data_id_cache = comms.get_data(commsId, true)

	while not thread.Terminated do sleep(1/45 * 1000)
		local current_data, current_data_id = comms.get_data(commsId, true)
		if not (current_data and current_data_id) then
			break
		end

		if not (data_cache == current_data and data_id_cache == current_data_id) then
			data_cache, data_id_cache = current_data, current_data_id
			synchronize(callback, data_cache)
		end
		::continue_commslistener::
	end
end

-- main
local comms = {}
comms.addys = {}

comms.new_id = function(commsId, fetchAddy)
	if comms.addys[commsId] then return end
	comms.addys[commsId] = 0

	if fetchAddy then
		fetchCommsAddy(comms.addys, commsId)
	end
end

comms.update_addys = function()
	for commsId in pairs(comms.addys) do
		local stringAddy = fetchCommsAddy(comms.addys, commsId)
		if not stringAddy then
			print("Failed to update address of commsId:", commsId)
			goto continue_commsscan
		end

		print(string.format("'%s' address: %08X", commsId, stringAddy))
		::continue_commsscan::
	end
end

comms.communicate = function(commsId, data, silentError)
	if (not comms.addys[commsId] and not silentError) then
		return error(string.format("Communication Id not defined: '%s'", commsId), 2)
	end

	local stringAddy = fetchCommsAddy(comms.addys, commsId)
	if not stringAddy or stringAddy == 0 then
		return
	end

	local payload = compileCommData(commsId, data)
	writeString(stringAddy, payload)
end

comms.get_data = function(commsId, silentError)
	if (not comms.addys[commsId] and not silentError) then
		return error(string.format("Communication Id not defined: '%s'", commsId), 2)
	end

	local stringAddy = fetchCommsAddy(comms.addys, commsId)
	if not stringAddy or stringAddy == 0 then
		return
	end

	return parseData(readString(stringAddy))
end

comms.new_listener = function(commsId, callback)
	if (not comms.addys[commsId]) then
		return error(string.format("Communication Id not defined: '%s'", commsId), 2)
	end

	return createThread(_comms_onDataRecieved, commsId, callback)
end

return comms
