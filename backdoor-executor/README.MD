# jLn0n's __backdoor executor__ (beckdeer skenner)

* The very best backdoor scanning utility of the southeasterns.

## Info

* A backdoor scanner for [ROBLOX](https://roblox.com) that scans the game for potential backdoored remotes and uses them for running server-sided scripts.  
* **NOTE:** Make sure that you got the script from Scriptblox or this Github repo. There might have been reuploads of the script which includes malicious code.

### Features

* Fast & Reliable Backdoor Scanner
* Remote & Output Redirection (DISABLED BY DEFAULT)
* Auto Execute (CUSTOMIZABLE)
* Macros (CUSTOMIZABLE)
* AND MUCH MORE!!

### Script

> Just copy the script below and run it through your script utility(executor).
```lua
loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/jLn0n/scripts/main/backdoor-executor/backdoor-executor.lua"))()
```   

### Requirements

- A brain that knows this stuff.
- A decent script utility that supports most of [UNC](https://scriptunc.org) functions (such as filesystem functions) and all of [Luau](https://luau-lang.org) features.

### FAQ & Troubleshooting

- Backdoor scanner doesn't seem to work.
> Your configuration file might be outdated, make sure to update it.  
> The script might not support your script utility too.  
> Scripting Utilities that are built for android/ios doesn't seem to support the script.  

- How can I enable Remote and Output Redirection?
> Enable them through the configuration file.  
> Usually it is located in workspace folder.

- How does the Remote Redirection works?
> It works by creating a new remote and using that new remote for running server-sided scripts.  
> It also provides some features like anti-destroy, anti-logger and source encryption.  

- How can I add a backdoor to a game?
> Please refer to this link: [How to add a backdoor](https://github.com/k4scripts/backdoor.exe#how-to-infect-your-game-with-a-backdoor)

- Do you log any of the sensitive information and/or backdoored games?
> No, I respect the privacy of everyone who uses the script and refrain from engaging in any of those malicious practices.
> You can check the script's source code to verify its authenticity.

### Configuration Wiki

- Using Cache:
> Caching can be used to quickly find the remote on a specific game without any waiting.  
> You can also use Caching if you know the backdoor remote of a game and its arguments.
>  
> Example:
```lua
[placeid] = {
	["Remote"] = "remote.path.here", -- the remote can be a path like "ReplicatedStorage["Remotes here"].Remote" or a instance
	["Args"] = {"arg1here", "source"}, -- source is the place that the executing script will be putted
	["SourceFunc"] = function(source) -- use this if a game has a custom encryption for source
		return source
	end
}
```

- Using Auto Execute:
> AutoExecute can be used to load script after backdoor is successfully found.  
> You can put many code as long as you want inside the table.
>   
> Example:
```lua
-- it should be a array and don't add a nil or it will not work
{
	[[warn("backdoor-executor.lua loaded!")]],
	[[require(someid).load(%username%)]],
},
```

- Using Script Macros:
> Script Macros can be very helpful to set values.  
> Config example:
```lua
{
	["staticmacro"] = "value", -- returns "value"
	["dynamicmacro"] = function() -- returns a random number of 1-100
		return math.random(1, 100)
	end,
}
```
> Usage example:
```lua
print(%username%, %userid%, %placeid%) -- prints "Username", 69420, 1818 as an example
```

- Using Remote Filters:
> Remote Filters can be used to block any of the remotes with specific properties.  
>   
> Example:
```lua
{
	["exampleFilter"] = function(remoteObj) -- the remote will be filtered out of the remoteObj name is "bogus" or its parent name is "yomama"
		return remoteObj.Name == "bogus" or remoteObj.Parent.Name == "yomama"
	end,
},
```

- Using Backdoor Payloads:
> Backdoor Payloads can be used to customize arguments of remotes on when scanning.  
> It can be also be used for a certain remote to be used with the provided payload.  
>   
> Example:
```lua
{
	["examplePayload"] = {
		["Args"] = {"arg1here", "source"}, -- this is the arguments that is gonna be loaded in the specified remote, same details as the args in cache
		["Verifier"] = function(remoteObj) -- this verifies if remoteObj is appropriate to be used for payload, the remote will be provided with the argument {"arg1here", "source"} if remoteObj is a descendant of JointsService
			return remoteObj:IsDescendantOf(game:GetService("JointsService"))
		end
	}
}
```
