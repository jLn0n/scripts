--[[
	getobjects.lua
	Maybe a faster implementation of game:GetObjects

	How to use:
		local getobjects = loadstring(game:HttpGet("https://raw.githubusercontent.com/jLn0n/created-scripts-public/main/libraries/getobjects.lua"))()
		getobjects("rbxassetid://1234567890")[1]
--]]
-- // SERVICES
local InsertService = game:GetService("InsertService")
-- // MAIN
return function(assetId_url)
	assert(type(assetId_url) == "string", "Failed to get the asset, is arg#1 a string?")
	local tResult = table.create(0)
	local succ, result = pcall(InsertService.LoadLocalAsset, InsertService, assetId_url)
	if succ then
		table.insert(tResult, result)
	else
		error(result)
	end
	return tResult
end
