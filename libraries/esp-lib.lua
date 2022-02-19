-- services
local players = game:GetService("Players")
-- objects
local player = players.LocalPlayer
local camera = workspace.CurrentCamera
-- variables
local headOffset, legOffset = Vector3.yAxis * .5, Vector3.yAxis * 3
-- main
local module = {}
module.__index = module

function module.new(plr, config)
	local self = setmetatable({
		player  = plr,
		config = config,
		renderObj = table.create(0)
	}, module)

	local boxRender = Drawing.new("Square")
	boxRender.Thickness = 2
	boxRender.Filled = false
	boxRender.Transparency = .8
	local tracerRender = Drawing.new("Line")
	tracerRender.Thickness = 2
	tracerRender.Transparency = .8
	local textRender = Drawing.new("Text")
	textRender.Size = 16
	textRender.Center = true
	textRender.Outline = true

	self.renderObj["box"] = boxRender
	self.renderObj["tracer"] = tracerRender
	self.renderObj["text"] = textRender
	return self
end

function module:updateConfig(config)
	self.config = config
end

function module:updateRender()
	local character = self.config.character
	if self.player and character then
		local humanoid = character:FindFirstChildWhichIsA("Humanoid")
		local head = character:FindFirstChild("Head")
		local rootPart = character:FindFirstChild("HumanoidRootPart")

		if humanoid and (head and rootPart) then
			local rootPos, rootVisible = camera:WorldToViewportPoint(rootPart.Position)
			local headPos = camera:WorldToViewportPoint(head.Position + headOffset)
			local legPos = camera:WorldToViewportPoint(rootPart.Position - legOffset)
			local notTeammate = self.config.teamCheck and (self.player and (self.player.Neutral or self.player.TeamColor ~= player.TeamColor)) or (not self.config.teamCheck)

			if rootVisible and notTeammate then
				self.renderObj.box.Color = self.config.color
				self.renderObj.box.Size = Vector2.new(2350 / rootPos.Z, headPos.Y - legPos.Y)
				self.renderObj.box.Position = Vector2.new(rootPos.X, rootPos.Y) - (self.renderObj.box.Size / 2)
				self.renderObj.box.Visible = self.config.visibility.box

				self.renderObj.tracer.Color = self.config.color
				self.renderObj.tracer.To = Vector2.new(rootPos.X, headPos.Y)
				self.renderObj.tracer.From = Vector2.new(camera.ViewportSize.X / 2, camera.ViewportSize.Y)
				self.renderObj.tracer.Visible = self.config.visibility.tracer

				self.renderObj.text.Color = self.config.color
				self.renderObj.text.Text = self.config.text
				self.renderObj.text.Position = Vector2.new(rootPos.X, headPos.Y - (16 + self.config.textOffset))
				self.renderObj.text.Visible = self.config.visibility.text
			else
				for _, dRender in pairs(self.renderObj) do
					dRender.Visible = false
				end
			end
		end
	end
end

function module:remove()
	for _, dRender in pairs(self.renderObj) do
		dRender:Remove()
	end
	setmetatable(self, nil)
end

return module
