-- // SERVICES
local TextService = game:GetService("TextService")
-- // LIBRARIES
local getObjects = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/jLn0n/created-scripts-public/main/libraries/getobjects.lua", true))()
local Lexer = loadstring(game:HttpGetAsync("https://raw.githubusercontent.com/jLn0n/created-scripts-public/main/libraries/boatbomber-lexer.lua", true))()
-- // OBJECTS
local synHLUI_Template = getObjects("rbxassetid://6969756999")[1]
-- // VARIABLES
local sformat, smatch, sgsub, srep = string.format, string.match, string.gsub, string.rep
-- // MAIN
local getTextSize = function(object, abSize)
	return TextService:GetTextSize(
		object.Text,
		object.TextSize,
		object.Font,
		abSize
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
	for tok, str in Lexer.scan(textSource) do
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

	TextSourceSize, TextLineSize = getTextSize(TextSourceHolder, TextSource.AbsoluteSize), getTextSize(TextLines.LineText, TextLines.AbsoluteSize)
	TextLines.Size = UDim2.new(0, TextLineSize.X + 10, 1, 0)
	TextLines.CanvasSize = UDim2.new(0, 0, 0, TextLineSize.Y + TextLines.ScrollBarThickness + synHL_UI.AbsoluteSize.Y)
	TextSource.Position = UDim2.new(0, TextLines.Size.X.Offset, 0, 0)
	TextSource.Size = UDim2.new(0, synHL_UI.AbsoluteSize.X - TextLines.Size.X.Offset, 0, synHL_UI.AbsoluteSize.Y)
	TextSource.CanvasSize = UDim2.new(0, TextSourceSize.X + (TextSource.ScrollBarThickness + TextLines.Size.X.Offset + 2), 0, TextSourceSize.Y + TextSource.ScrollBarThickness + synHL_UI.AbsoluteSize.Y)
end

local setProperty = function(object, propName, propValue)
	local succ, err = pcall(function()
		object[propName] = propValue
	end)

	if not succ and propName == "TextSource" then
		updateTextSource(object, propValue)
	elseif not succ and propName == "SyntaxColors" and type(propValue) == "table" then
		local SynHL_Labels = object.TextSource.Holder:GetChildren()
		for _, labelObj in ipairs(SynHL_Labels) do
			if propValue[labelObj.Name] then
				labelObj.TextColor3 = propValue[labelObj.Name]
			end
		end
	elseif not succ then
		return error(err)
	end
end

local M = {} -- why use metatables lol

function M.new(properties)
	assert(typeof(properties) == "table", "argument #1 should be a table")
	local synHL_UI = synHLUI_Template:Clone()
	local TextLines = synHL_UI.TextLines
	local TextSource = synHL_UI.TextSource
	local sub_M = {
		_connections = {},
	}

	function sub_M:getChildren()
		return {
			[TextSource.Name] = TextSource,
			[TextLines.Name] = TextLines
		}
	end
	function sub_M:setProperty(propName, propValue) setProperty(synHL_UI, propName, propValue) end
	function sub_M:Destroy()
		for _, connection in ipairs(sub_M._connections) do
			connection:Disconnect()
		end
		synHL_UI:Destroy()
		table.clear(sub_M); sub_M = nil
	end

	-- // INIT
	for propName, propValue in pairs(properties) do
		setProperty(synHL_UI, propName, propValue)
	end

	sub_M._connections[#sub_M._connections + 1] = TextSource:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
		TextLines.CanvasPosition = Vector2.new(0, TextSource.CanvasPosition.Y)
	end)
	return sub_M
end

return M
