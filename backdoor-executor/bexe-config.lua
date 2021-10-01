-- ALWAYS BACKUP YOUR CONFIG
return {
	["cachedPlaces"] = {
		[5033592164] = {
			["Path"] = game.PlaceId == 5033592164 and game:GetService("ReplicatedStorage"):GetChildren()[1]:GetFullName(),
			["Args"] = {"1234567890", "source"}
		},
		[6879465970] = {
			["Path"] = "ReplicatedStorage.RemoteEvent",
			["Args"] = {"source"}
		},
	},
	["autoExec"] = {
		[[print("backdoor-executor.lua is epic!")]],
	},
	["configVer"] = 2 -- don't touch this!
}
