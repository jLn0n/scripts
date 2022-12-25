-- objects
local player = game:GetService("Players").LocalPlayer

-- main
return {
	["configVer"] = 4.1, -- don't touch this!
	-- tweaks
	["redirectRemote"] = false, -- [BETA] uses a custom remote for server-side execution

	-- customization
	["autoExec"] = { -- scripts that executes after backdoor is found
		[[print("backdoor-executor.lua is epic!")]],
	},

	["remoteFilters"] = { -- remote filters that you don't want to be scanned
		["AdminRemotes"] = function(remoteObj)
			local remoteObjPath = remoteObj:GetFullName()

			return remoteObj:IsDescendantOf(game:GetService("ReplicatedStorage")) and (string.find(remoteObjPath, "HDAdminClient") or string.find(remoteObjPath, "Basic Admin Essentials"))
		end,
		["AdonisRemotes"] = function(remoteObj)
			return (
				(remoteObj.Parent and remoteObj.Parent:IsA("ReplicatedStorage") and remoteObj:FindFirstChild("__FUNCTION")) or
				(remoteObj.Name == "__FUNCTION" and remoteObj.Parent:IsA("RemoteEvent") and remoteObj.Parent.Parent:IsA("ReplicatedStorage"))
			)
		end,
		["RobloxReplicatedStorage"] = function(remoteObj)
			return remoteObj:IsDescendantOf(game:GetService("RobloxReplicatedStorage"))
		end
	},

	["scriptMacros"] = { -- prefixed as "%macro%" | example %username% -> "Roblox"
		["username"] = player.Name,
		["userid"] = player.UserId
	},

	["cachedPlaces"] = { -- backdoor remote configuration cache thing
		[5033592164] = {
			["Path"] = game.PlaceId == 5033592164 and game:GetService("ReplicatedStorage"):GetChildren()[1]:GetFullName(),
			["Args"] = {"1234567890", "source"}
		},
		[6879465970] = {
			["Path"] = "ReplicatedStorage.RemoteEvent",
			["Args"] = {"source"}
		},
	},
}
