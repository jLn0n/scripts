-- services
local coreGui = game:GetService("CoreGui")
-- objects
local camera = workspace.CurrentCamera
local drawingParent = Instance.new("ScreenGui")
drawingParent.Parent = coreGui.RobloxGui
-- variables
local baseDrawingObj = setmetatable({
	Visible = true,
	ZIndex = 1,
	Transparency = 0,
	Color = Color3.new(),
	Remove = function(self)
		setmetatable(self, nil)
	end
}, {
	__add = function(t1, t2)
		local result = table.clone(t1)

		for index, value in t2 do
			result[index] = value
		end
		return result
	end
})
-- main
local Drawing = {}
Drawing.Fonts = {
	UI = 0
}

function Drawing.new(type)
	if type == "Line" then
		local lineObj = ({
			To = Vector2.zero,
			From = Vector2.zero,
			Thickness = 1
		} + baseDrawingObj)

		local lineFrame = Instance.new("Frame")
		lineFrame.AnchorPoint = (Vector2.one * .5)
		lineFrame.BorderSizePixel = 0

		lineFrame.BackgroundColor3 = lineObj.Color
		lineFrame.Visible = lineObj.Visible
		lineFrame.ZIndex = lineObj.ZIndex
		lineFrame.BackgroundTransparency = lineObj.Transparency

		lineFrame.Parent = drawingParent
		return setmetatable({}, {
			__newindex = function(_, index, value)
				if not lineObj[index] then return end
				if index == "To" then
					local direction = (value - lineObj.From)
					local center = (value + lineObj.From) / 2
					local distance = direction.Magnitude
					local theta = math.deg(math.atan2(direction.Y, direction.X))

					lineFrame.Position = UDim2.fromOffset(center.X, center.Y)
					lineFrame.Rotation = theta
					lineFrame.Size = UDim2.fromOffset(distance, lineObj.Thickness)
				elseif index == "From" then
					local direction = (lineObj.To - value)
					local center = (lineObj.To + value) / 2
					local distance = direction.Magnitude
					local theta = math.deg(math.atan2(direction.Y, direction.X))

					lineFrame.Position = UDim2.fromOffset(center.X, center.Y)
					lineFrame.Rotation = theta
					lineFrame.Size = UDim2.fromOffset(distance, lineObj.Thickness)
				elseif index == "Thickness" then
					value = (if (value < 1 and value > -0) then value else 1)
					local distance = (lineObj.To - lineObj.From).Magnitude

					lineFrame.Size = UDim2.fromOffset(distance, value)
				elseif index == "Visible" then
					lineFrame.Visible = value
				elseif index == "ZIndex" then
					lineFrame.ZIndex = value
				elseif index == "Transparency" then
					lineFrame.BackgroundTransparency = value
				elseif index == "Color" then
					lineFrame.BackgroundColor3 = value
				end
				lineObj[index] = value
			end,
			__index = function(self, index)
				if index == "Remove" then
					return function()
						lineFrame:Destroy()
						lineObj.Remove(self)
						return lineObj:Remove()
					end
				end
				return lineObj[index]
			end
		})
	elseif type == "Circle" then
		local circleObj = ({
			Radius = 150,
			Filled = false,
			Position = Vector2.zero
		} + baseDrawingObj)

		local circleFrame, uiCorner = Instance.new("Frame"), Instance.new("UICorner")
		circleFrame.AnchorPoint = (Vector2.one * .5)
		circleFrame.BorderSizePixel = 0

		circleFrame.BackgroundColor3 = circleObj.Color
		circleFrame.Visible = circleObj.Visible
		circleFrame.ZIndex = circleObj.ZIndex
		circleFrame.BackgroundTransparency = circleObj.Transparency

		uiCorner.CornerRadius = UDim.new(1, 0)
		circleFrame.Size = UDim2.fromOffset(circleObj.Radius, circleObj.Radius)

		circleFrame.Parent, uiCorner.Parent = drawingParent, circleFrame
		return setmetatable({}, {
			__newindex = function(_, index, value)
				if not circleObj[index] then return end
				if index == "Radius" then
					circleFrame.Size = UDim2.fromOffset(value, value)
				elseif index == "Filled" then
					circleFrame.BackgroundTransparency = (if value then 0 else circleObj.Transparency)
				elseif index == "Position" then
					circleFrame.Position = UDim2.fromOffset(value.X, value.Y)
				elseif index == "Visible" then
					circleFrame.Visible = value
				elseif index == "ZIndex" then
					circleFrame.ZIndex = value
				elseif index == "Transparency" then
					circleFrame.BackgroundTransparency = (if circleObj.Filled then 0 else value)
				elseif index == "Color" then
					circleFrame.BackgroundColor3 = value
				end
				circleObj[index] = value
			end,
			__index = function(self, index)
				if index == "Remove" then
					return function()
						circleFrame:Destroy()
						circleObj.Remove(self)
						return circleObj:Remove()
					end
				end
				return circleObj[index]
			end
		})
	elseif type == "Text" then
		local textObj = ({
			Text = "",
			Size = 0,
			Center = false,
			Outline = false,
			OutlineColor = Color3.new(),
			Position = Vector2.zero,
		} + baseDrawingObj)

		local textLabel = Instance.new("TextLabel")
		textLabel.AnchorPoint = (Vector2.one * .5)
		textLabel.BorderSizePixel = 0
		textLabel.Size = UDim2.fromOffset(0, 0)
		textLabel.Font = Enum.Font.Roboto
		textLabel.BackgroundTransparency = 1

		textLabel.TextSize = textObj.Size
		textLabel.Visible = textObj.Visible
		textLabel.TextColor3 = textObj.Color
		textLabel.TextTransparency = (1 - textObj.Transparency)

		textLabel.Parent = drawingParent
		return setmetatable({}, {
			__newindex = function(_, index, value)
				if not textObj[index] then return end

				if index == "Text" then
					textLabel.Text = value
				elseif index == "Size" then
					textLabel.TextSize = value
				elseif index == "Center" then
					textLabel.Position = (
						if value then
							UDim2.fromOffset(camera.ViewportSize.X / 2, camera.ViewportSize.Y / 2)
						else
							textObj.Position
					)
				elseif index == "Outline" then
					textLabel.TextStrokeTransparency = (if value then 0 else 1)
				elseif index == "OutlineColor" then
					textLabel.TextStrokeColor3 = value
				elseif index == "Position" then
					textLabel.Position = UDim2.fromOffset(value.X, value.Y)
				elseif index == "Visible" then
					textLabel.Visible = value
				elseif index == "ZIndex" then
					textLabel.ZIndex = value
				elseif index == "Transparency" then
					textLabel.TextTransparency = (1 - value)
				elseif index == "Color" then
					textLabel.TextColor3 = value
				end
				textObj[index] = value
			end,
			__index = function(self, index)
				if index == "Remove" then
					return function()
						textLabel:Destroy()
						textObj.Remove(self)
						return textObj:Remove()
					end
				elseif index == "TextBounds" then
					return textLabel.TextBounds
				end
				return textObj[index]
			end
		})
	elseif type == "Square" then
		local squareObj = ({
			Filled = false,
			Thickness = 1,
			Size = Vector2.zero,
			Position = Vector2.zero
		} + baseDrawingObj)

		local squareFrame = Instance.new("Frame")
		--squareFrame.AnchorPoint = (Vector2.one * .5)
		squareFrame.BorderMode = Enum.BorderMode.Outline

		squareFrame.BorderSizePixel = 0
		squareFrame.Visible = squareObj.Visible

		squareFrame.Parent = drawingParent
		return setmetatable({}, {
			__newindex = function(_, index, value)
				if not squareObj[index] then return end

				if index == "Filled" then
					squareFrame.BackgroundTransparency = (if value then 1 else squareObj.Transparency)
				elseif index == "Thickness" then
					squareFrame.BorderSizePixel = value
				elseif index == "Size" then
					squareFrame.Size = UDim2.fromOffset(value.X, value.Y)
				elseif index == "Position" then
					squareFrame.Position = UDim2.fromOffset(value.X, value.Y)
				elseif index == "Visible" then
					squareFrame.Visible = value
				elseif index == "ZIndex" then
					squareFrame.ZIndex = value
				elseif index == "Transparency" then
					squareFrame.BackgroundTransparency = (if squareObj.Filled then 1 else value)
				elseif index == "Color" then
					squareFrame.BackgroundColor3 = value
					squareFrame.BorderColor3 = value
				end
				squareObj[index] = value
			end,
			__index = function(self, index)
				if index == "Remove" then
					return function()
						squareFrame:Destroy()
						squareObj.Remove(self)
						return squareObj:Remove()
					end
				end
				return squareObj[index]
			end
		})
	end
end

getgenv().Drawing = Drawing
return Drawing
