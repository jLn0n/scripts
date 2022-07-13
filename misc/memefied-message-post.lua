--[[
	memefied-message-post.lua (modified thingy script of https://v3rmillion.net/showthread.php?tid=1150896.)
	a script that just works like the orig script but with memes
	idk why did i add memes but ye unfunny and lack of effort meme texts thingys
--]]
if not game:IsLoaded() then game.Loaded:Wait() end
-- services
local players = game:GetService("Players")
-- objects
local player = players.LocalPlayer
local plrScripts = player.PlayerScripts
local chatScript = plrScripts:FindFirstChild("ChatScript")
local chatMain = chatScript:FindFirstChild("ChatMain")
-- variables
local oldFunc, oldIndex
local memes = {
	"synpase x craked 2022 free no virus *not clickbait*",
	"if u are reading this then u are a skid.",
	"i feel so bad about skids reading my chat logs",
	"\n\nnewline\n",
	"how about u read some memes on the chat logs?",
	"a chad modifies the messageposted thingy, what happens next is memes",
	"\"plus ratio\" thingys are cringe ngl",
	"what do u expect its all memes bleachiñ",
	"dude im not exploiting because im a chad bruh",
	"i hope roblox doesnt ban me with this stuff that im saying",
	"kids be like: block hax0r",
	"Also try Minecraft!",
	"Also try Terraria!",
	"a \"admin\" reads chatlogs, what happens is shocking",
	"bahog bhielat",
	"ukininayo",
	"touch some grass skid",
}
-- main
if player and chatMain then print("memefied-message-post.lua loaded!")
	local messagePosted = require(chatMain).MessagePosted
	local chattedEvent = Instance.new("BindableEvent")
	chattedEvent.Name = player.Name .. "-ChattedEvent"

	oldFunc = messagePosted.fire
	messagePosted.fire = function(...)
		local self, message = ...

		if not checkcaller() then
			task.spawn(chattedEvent.Fire, chattedEvent, message)
		end
		return oldFunc(self, memes[math.random(1, #memes)])
	end
	oldIndex = hookmetamethod(game, "__index", newcclosure(function(...)
		local self, index = ...

		if self == player and index == "Chatted" then
			return chattedEvent.Event
		end
		return oldIndex(...)
	end))
end
