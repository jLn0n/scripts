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

local initSynHighlight = function(synHL_UI, connectionStorage)
	local TextLines = synHL_UI.TextLines
	local TextSource = synHL_UI.TextSource

	connectionStorage[#connectionStorage + 1] = TextSource:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		TextLines.CanvasPosition = Vector2.new(0, TextSource.CanvasPosition.Y)
	end)
end

local M = {} -- why use metatables lol

function M.new(guiParent, properties)
	assert(typeof(guiParent) == "Instance", "the argument #1 should be a instance")
	assert(type(properties) == "table", "the argument #2 should be a table")
	local synHL_UI = synHLUI_Template:Clone()
	local sub_M = {
		_connections = {},
	}
	synHL_UI.Parent, synHL_UI.Position, synHL_UI.Size = guiParent, properties.Position or UDim2.new(), properties.Size or UDim2.new(0, 350, 0, 500)
	updateTextSource(synHL_UI, properties.TextSource or "")

	function sub_M:updateSource(textSource)
		updateTextSource(synHL_UI, textSource)
	end

	function sub_M:Destroy()
		for _, connection in ipairs(sub_M._connections) do
			connection:Disconnect()
		end
		synHL_UI:Destroy()
	end

	initSynHighlight(synHL_UI, sub_M._connections)
	return sub_M
end

return M
