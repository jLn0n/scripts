local Player = game:GetService("Players").LocalPlayer
return {
	[5033592164] = {
		["Path"] = game.PlaceId == 5033592164 and game.JointsService:GetChildren()[1]:GetFullName(),
		["Args"] = {"1234567890", "source"}
	},
	[6879465970] = {
		["Path"] = "ReplicatedStorage.RemoteEvent",
		["Args"] = {"source"}
	},
	[3362132792] = {
		["Path"] = string.format("Players.%s.PlayerGui.EBG.MainRemake.Folder.run", Player.Name),
		["Args"] = {"source"},
		["SourceFunc"] = function(source) -- credits to http://lua-users.org/wiki/BaseSixtyFour for the base64 source
			local bString = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/"
			return ((source:gsub('.', function(str)
				local v1, v2 = "", str:byte()
				for iv1 = 8, 1, -1 do
					v1 = v1 .. (v2 % 2^ iv1 - v2 % 2^ (iv1 - 1) > 0 and "1" or "0")
				end
				return v1
			end) .. '0000'):gsub('%d%d%d?%d?%d?%d?', function(str)
				if (#str < 6) then return "" end
				local v1 = 0
				for iv1 = 1, 6 do
					v1 = v1 + (str:sub(iv1, iv1) == "1" and 2^ (6 - iv1) or 0)
				end
				return bString:sub(v1 + 1, v1 + 1)
			end) .. ({ "", '==', '=' })[#source %3 + 1])
		end
	},
}
