--[[
	BSD 3-Clause License

	Copyright (c) 2022, jLn0n
	All rights reserved.

	Redistribution and use in source and binary forms, with or without
	modification, are permitted provided that the following conditions are met:

	1. Redistributions of source code must retain the above copyright notice, this
	   list of conditions and the following disclaimer.

	2. Redistributions in binary form must reproduce the above copyright notice,
	   this list of conditions and the following disclaimer in the documentation
	   and/or other materials provided with the distribution.

	3. Neither the name of the copyright holder nor the names of its
	   contributors may be used to endorse or promote products derived from
	   this software without specific prior written permission.

	THIS SOFTWARE IS PROVIDED BY THE COPYRIGHT HOLDERS AND CONTRIBUTORS "AS IS"
	AND ANY EXPRESS OR IMPLIED WARRANTIES, INCLUDING, BUT NOT LIMITED TO, THE
	IMPLIED WARRANTIES OF MERCHANTABILITY AND FITNESS FOR A PARTICULAR PURPOSE ARE
	DISCLAIMED. IN NO EVENT SHALL THE COPYRIGHT HOLDER OR CONTRIBUTORS BE LIABLE
	FOR ANY DIRECT, INDIRECT, INCIDENTAL, SPECIAL, EXEMPLARY, OR CONSEQUENTIAL
	DAMAGES (INCLUDING, BUT NOT LIMITED TO, PROCUREMENT OF SUBSTITUTE GOODS OR
	SERVICES; LOSS OF USE, DATA, OR PROFITS; OR BUSINESS INTERRUPTION) HOWEVER
	CAUSED AND ON ANY THEORY OF LIABILITY, WHETHER IN CONTRACT, STRICT LIABILITY,
	OR TORT (INCLUDING NEGLIGENCE OR OTHERWISE) ARISING IN ANY WAY OUT OF THE USE
	OF THIS SOFTWARE, EVEN IF ADVISED OF THE POSSIBILITY OF SUCH DAMAGE.
--]]
-- init
if shared.executed then return end
-- config
shared.fov = (shared.fov or 175) -- mouse fov
shared.distance = (shared.distance or 15) -- plrchar distance to targetchar
-- services
local inputService = game:GetService("UserInputService")
local players = game:GetService("Players")
local runService = game:GetService("RunService")
-- objects
local camera = workspace.CurrentCamera
local player = players.LocalPlayer
local plrChar = player.Character
local sword
-- functions
local function checkPlr(plrArg)
	local plrChar = plrArg.Character
	local plrHumanoid, plrTPart = (plrChar and plrChar:FindFirstChild("Humanoid")), (plrChar and plrChar:FindFirstChild("Head"))
	return plrArg ~= player and (plrChar and (plrHumanoid and plrHumanoid.Health ~= 0)), plrTPart
end
local function getNearestPlrByCursor()
	local nearestPlrData = {aimPart = nil, dist = math.huge}

	for _, plr in players:GetPlayers() do
		local passed, plrTPart = checkPlr(plr)
		if not (passed and plrTPart) then continue end
		local posVec3 = camera:WorldToViewportPoint(plrTPart.Position)
		local fovDist = (inputService:GetMouseLocation() - Vector2.new(posVec3.X, posVec3.Y)).Magnitude
		local charDist = ((plr.Character and plr.Character.PrimaryPart) and (plrChar.PrimaryPart.Position - plr.Character.PrimaryPart.Position).Magnitude or nil)

		if checkPlr(plr) then
			if ((fovDist <= shared.fov) and (fovDist < nearestPlrData.dist)) and (charDist and charDist <= shared.distance) then
				nearestPlrData.aimPart = plrTPart
				nearestPlrData.dist = fovDist
			end
		end
	end
	return (nearestPlrData.aimPart and nearestPlrData or nil)
end
-- main
shared.executed = true
runService.Heartbeat:Connect(function()
	plrChar = player.Character
	sword = (plrChar and plrChar:FindFirstChildWhichIsA("Tool") or nil)
	if not (plrChar and sword) then return end
	local nearestPlr = getNearestPlrByCursor()

	if nearestPlr then
		sword.Handle.Position = nearestPlr.aimPart.Position
	end
end)
