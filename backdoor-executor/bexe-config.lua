--[==[
	cache example:
	[placeid here (placeid should be only a integer)] = {
		["Path"] = "remote.path.here", -- don't do remote.path["here"] or the path parser will not work
		["Args"] = {"arg1here", "source"}, -- source shouldn't be deleted because its a arg for scripts that will be executed
		["Func"] = function(source) -- only add this when the remote has custom encryption thingy
			return source
		end
	}
	AutoExec how to use:
	add a script to it inside the table example:
	{
		[[print("im epic")]],
		[[print("yes")]]
	}
	the script on the top will run when backdoor-executor.lua is attached
	it should be always an array or it will not run

	note that this config will autoupdate every config changes so u should always backup this config incase of data loss
--]==]
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
	["configVer"] = 2
}
