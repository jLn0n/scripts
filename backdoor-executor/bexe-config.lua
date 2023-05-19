-- objects
local player = game:GetService("Players").LocalPlayer

-- main
return {
	["configVer"] = 7, -- don't touch this!
	-- @tweaks
	["redirectOutput"] = false, -- [BETA] redirects output to console
	["redirectRemote"] = false, -- [BETA] redirects to a custom remote

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

	-- $any macro shenanigans you can add here
	-- $prefixed as "%macro%" | example: %username% -> "Roblox", %plr_pos% -> Vector3
	["scriptMacros"] = {
		["username"] = player.Name,
		["userid"] = player.UserId,
		["placeid"] = game.PlaceId
	},

	-- $backdoor payloads
	["backdoorPayloads"] = {
		["default"] = {
			["Args"] = {"source"},
		},

		-- payloads below are from github.com/L1ghtingBolt/FraktureSS
		["helpmeRemote"] = {
			["Args"] = {"helpme", "source"},
		},
		["pickettRemote"] = {
			["Args"] = {"cGlja2V0dA==", "source"},
		},
		["runSSRemote"] = {
			["Args"] = {"5#lGIERKWEF", "source"},
			["Verifier"] = function(remoteObj)
				local remoteParent = remoteObj.Parent
				return (remoteObj.Name == "Run" and remoteParent) and (
					remoteParent:FindFirstChild("Pages") and remoteParent:FindFirstChild("R6") and
					remoteParent:FindFirstChild("Version") and remoteParent:FindFirstChild("Title")
				)
			end
		},
		["emmaSSRemote"] = {
			["Args"] = {"pwojr8hoc0-gr0yxohlgp-0feb7ncxed", ",,,,,,,,,,,,,,,", "source"},
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
			["Remote"] = game:GetService("ReplicatedStorage"):FindFirstChildWhichIsA("RemoteEvent"),
			["Args"] = {"1234567890", "source"}
		},
		[6879465970] = {
			["Remote"] = "ReplicatedStorage.RemoteEvent",
			["Args"] = {"source"}
		},
		[6664139112] = {
			["Remote"] = "ReplicatedStorage.Core.Communication.RemoteEvent",
			["Args"] = {"Execute", "source"}
		},
	},
}
