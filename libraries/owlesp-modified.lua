local OwlESP = {}

local localPlayer = game:GetService("Players").LocalPlayer
local currentCamera = workspace.CurrentCamera
local worldToViewportPoint = currentCamera.WorldToViewportPoint
local newDrawing = Drawing.new
local newVector2 = Vector2.new
local newVector3 = Vector3.new

local headOffset = newVector3(0, 0.5, 0)
local legOffset = newVector3(0, 3, 0)
local tracerStart = newVector2(currentCamera.ViewportSize.X / 2, currentCamera.ViewportSize.Y)

function OwlESP.new(data)
	local self = setmetatable({
		plr = data.plr,
		char = data.plr.Character,
		espBox = nil,
		name = nil,
		tracer = nil,
		espColor = data.espColor or Color3.fromRGB(255, 255, 255),
		teamCheck = data.teamCheck or false
	}, {__index = OwlESP})

	local espBoxVisible = data.espBoxVisible
	local tracerVisible = data.tracerVisible
	local text = data.text

	local espBox = newDrawing("Square")
	espBox.Color = self.espColor
	espBox.Thickness = 2
	espBox.Filled = false
	espBox.Transparency = 0.8
	local tracer = newDrawing("Line")
	tracer.From = tracerStart
	tracer.Color = self.espColor
	tracer.Thickness = 2
	tracer.Transparency = 0.8
	local name = newDrawing("Text")
	name.Text = text
	name.Size = 16
	name.Color = self.espColor
	name.Center = true
	name.Outline = true

	espBox.Visible = false
	tracer.Visible = false
	name.Visible = false

	self.espBox = {espBox, espBoxVisible}
	self.tracer = {tracer, tracerVisible}
	self.name = {name, text}

	return self
end

function OwlESP:setConfig(data)
	self.espBox[2] = data.espBoxVisible or self.espBox[2]
	self.tracer[2] = data.tracerVisible or self.tracer[2]
	self.name[2] = data.text or self.name[2]
	self.char = data.char
	self.teamCheck = data.teamCheck or self.teamCheck
end

function OwlESP:update()
	local plr, char = self.plr, self.char
	local humanoid = char and char:FindFirstChildWhichIsA("Humanoid") or nil

	if plr and char and humanoid then
		local espBox, tracer, name = self.espBox[1], self.tracer[1], self.name[1]
		local espBoxVisible, healthBarVisible, tracerVisible, text, espColor = self.espBox[2], self.healthBar[2], self.tracer[2], self.name[2], self.espColor
		local rootPart, head = char:FindFirstChild("HumanoidRootPart"), char:FindFirstChild("Head")

		if rootPart and head then
			local rootPos, rootVis = worldToViewportPoint(currentCamera, rootPart.Position)
			local headPos = worldToViewportPoint(currentCamera, head.Position + headOffset)
			local legPos = worldToViewportPoint(currentCamera, rootPart.Position - legOffset)
			local visible = (self.teamCheck and (plr.Neutral == true or plr.TeamColor ~= localPlayer.TeamColor)) or (not self.teamCheck)

			if rootVis then
				local espBoxSize = espBox.Size
				espBox.Size = newVector2(2350 / rootPos.Z, headPos.Y - legPos.Y)
				espBox.Position = newVector2(rootPos.X - espBoxSize.X / 2, rootPos.Y - espBoxSize.Y / 2)
				espBox.Color = espColor
				tracer.To = newVector2(rootPos.X, rootPos.Y - espBoxSize.Y / 2)
				tracer.Color = espColor
				name.Position = newVector2(rootPos.X, (rootPos.Y + espBoxSize.Y / 2) - 25)
				name.Text = text
				name.Color = espColor

				espBox.Visible = espBoxVisible and visible
				tracer.Visible = tracerVisible and visible
				name.Visible = espBoxVisible and visible
			else
				espBox.Visible = false
				tracer.Visible = false
				name.Visible = false
			end
		end
	end
end

function OwlESP:remove()
	self.espBox[1]:Remove()
	self.tracer[1]:Remove()
	self.name[1]:Remove()
	function self:update() end
end

return OwlESP
