-- // SERVICES
local TextService = game:GetService("TextService")
-- // OBJECTS
local synHLUI_Template = game:GetObjects("rbxassetid://6969756999")[1]
-- // MODULES
local Lexer = loadstring(game:HttpGet("https://raw.githubusercontent.com/jLn0n/created-scripts-public/main/boatbomber-lexer.lua", true))()
-- // VARIABLES
local sformat, smatch, sgsub, srep = string.format, string.match, string.gsub, string.rep
local Lexer_scan = Lexer.scan
-- // MAIN
local getTextSize = function(object)
	return TextService:GetTextSize(
		object.Text,
		object.TextSize,
		object.Font,
		Vector2.new(object.AbsoluteSize, 10e10)
	)
end

local updateTextSource = function(synHL_UI, textSource)
	textSource = sgsub(textSource, "\t", "    ")
	local TextLines = synHL_UI.TextLines
	local TextSource = synHL_UI.TextSource
	local TextSourceHolder = TextSource.Holder
	local line = 1
	local TextSourceSize, TextLineSize

	TextSourceHolder.Text = textSource
	TextLines.LineText.Text = ""
	for _, lexObj in ipairs(TextSourceHolder:GetChildren()) do lexObj.Text = "" end
	for tok, str in Lexer_scan(textSource) do
		for _, lexObj in ipairs(TextSourceHolder:GetChildren()) do
			if lexObj.Name == tok then
				lexObj.Text = lexObj.Text .. str
			else
				lexObj.Text = lexObj.Text .. sgsub(str, "[^\n\r]", " ")
			end
		end
	end

	sgsub(textSource, "\n", function() line = line + 1 end)
	for lineVal = 1, line do
		TextLines.LineText.Text = TextLines.LineText.Text .. tostring(lineVal) .. "\n"
	end

	TextSourceSize, TextLineSize = getTextSize(TextSourceHolder), getTextSize(TextLines.LineText)
	TextLines.Size = UDim2.new(0, TextLineSize.X + 10, 1, 0)
	TextLines.CanvasSize = UDim2.new(0, 0, 0, TextLineSize.Y + TextLines.ScrollBarThickness)
	TextSource.Position = UDim2.new(0, TextLines.Size.X.Offset, 0, 0)
	TextSource.Size = UDim2.new(0, synHL_UI.AbsoluteSize.X - TextLines.Size.X.Offset, 0, synHL_UI.AbsoluteSize.Y)
	TextSource.CanvasSize = UDim2.new(0, TextSourceSize.X + (TextSource.ScrollBarThickness + 2), 0, TextSourceSize.Y + TextSource.ScrollBarThickness)
end

local setProperty = function(object, propName, propValue)
	local succ, err = pcall(function()
		object[propName] = propValue
	end)

	if not succ and propName == "TextSource" then
		updateTextSource(object, propValue)
	elseif not succ then
		return error(err)
	end
end

local M = {} -- why use metatables lol

function M.new(properties)
	assert(type(properties) == "table", "the argument #1 should be a table")
	local synHL_UI = synHLUI_Template:Clone()
	local TextLines = synHL_UI.TextLines
	local TextSource = synHL_UI.TextSource
	local sub_M = {
		_connections = {},
	}

	for propName, propValue in pairs(properties) do
		setProperty(synHL_UI, propName, propValue)
	end

	function sub_M:setProperty(propName, propValue) setProperty(synHL_UI, propName, propValue) end
	function sub_M:Destroy()
		for _, connection in ipairs(sub_M._connections) do
			connection:Disconnect()
		end
		synHL_UI:Destroy()
	end

	sub_M._connections[#sub_M._connections + 1] = TextSource:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		TextLines.CanvasPosition = Vector2.new(0, TextSource.CanvasPosition.Y)
	end)
	return sub_M
end

return M
