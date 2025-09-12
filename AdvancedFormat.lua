-- AdvancedFormat.lua
-- By @topalyh
-- Version 1.0.0
-- Lightweight string formatting & styling module for Roblox

-- Types
export type StyleOptions = {
	color: string?,
	font: string?,
	style: "Bold" | "Italic" | "Strikethrough" | "Underline" | "None"?
}

export type Styles = "None" | "Bold" | "Italic"
export type Fonts = "SourceSansPro" | "Gotham" | "Arial" | "Cartoon" | "Fantasy" | "Oswald" | "BuilderSans"

export type TimePatterns =
"yyyy/mm/dd hh/mm/ss" |
"hh:mm:ss" |
"yyyy/mm/dd" |
"mm/dd/yyyy" |
"dd:hh:mm:ss" |
"yyyy/mm" |
"mm/yyyy" |
"yyyy" |
"mm" |
"dd" |
"hh" |
"mm/ss" |
"ss"

export type AdvancedFormat = {
	new: () -> AdvancedFormat,
	createPlaceholder: (self: AdvancedFormat, name: string, defaultValue: string?) -> (),
	formatString: (self: AdvancedFormat, str: string, textObject: TextBox? | TextLabel? | TextButton?) -> Result,
	placeholders: { [string]: string? },
	toTitleCase: (self: AdvancedFormat, str: string) -> string,
	ordinal: (self: AdvancedFormat, num: number) -> string,
	pluralize: (self: AdvancedFormat, word: string, count: number) -> string,
	timeFormat: (self: AdvancedFormat, number: number, pattern: TimePatterns) -> string,
	invert: (self: AdvancedFormat, hex: string) -> string,
	ToRGB: (self: AdvancedFormat, r: number?, g: number?, b: number?) -> string,
	ToHex: (self: AdvancedFormat, r: number?, g: number?, b: number?) -> string,
	ToHSV: (self: AdvancedFormat, h: number?, s: number?, v: number?) -> string
}

export type Result = {
	GetResult: (self: Result) -> string,
	connectPlaceholder: (self: Result, name: string, value: string) -> Result,
	setColor: (self: Result, colorString: string, textPiece: string?) -> Result,
	editText: (self: Result, textPiece: string, style: Styles?, font: Fonts?) -> Result,
	setStyle: (self: Result, textPiece: string?, options: StyleOptions) -> Result,
	GetTextObject: (self: Result) -> TextBox? | TextLabel? | TextButton?,
	value: string,
	formatter: AdvancedFormat,
	textObject: TextLabel | TextBox | TextButton
}

local scriptPrefix = "[AdvancedFormat]: "
local CURRENT_VERSION = "1.0.0"
local checkVersionEvent = game.ReplicatedStorage:WaitForChild("AdvancedFormatHTTPReceive")

-- === Implementation ===
local AdvancedFormat = {}
AdvancedFormat.__index = AdvancedFormat
AdvancedFormat.VERSION = CURRENT_VERSION

local Result = {}
Result.__index = Result

local TextService = game:GetService("TextService")

-- Strip RichText tags (<...>) to get plain visible text
local function stripRichTextTags(s: string): string
	if not s then return "" end
	return s:gsub("<.->", "")
end

-- Parse color string "#rrggbb" or "r,g,b" -> Color3
local function parseColorString(colorStr: string?): Color3
	if not colorStr then return Color3.new(1, 1, 1) end

	if colorStr:match("^#%x%x%x%x%x%x$") then
		local ok, c = pcall(function() return Color3.fromHex(colorStr) end)
		if ok and c then return c end
	end

	local r, g, b = colorStr:match("(%d+),%s*(%d+),%s*(%d+)")
	if r and g and b then
		return Color3.fromRGB(tonumber(r), tonumber(g), tonumber(b))
	end

	return Color3.new(1, 1, 1)
end

-- Try to resolve a font name (string) to Enum.Font; fallback if not found
local function resolveEnumFont(fontName: string?, fallback: Enum.Font)
	fallback = fallback or Enum.Font.SourceSans
	if not fontName then return fallback end

	-- try direct access Enum.Font[fontName]
	local ok, enumVal = pcall(function() return Enum.Font[fontName] end)
	if ok and enumVal then return enumVal end

	local target = fontName:lower():gsub("%s", "")
	for _, item in ipairs(Enum.Font:GetEnumItems()) do
		if item.Name:lower():gsub("%s", "") == target then
			return item
		end
	end

	return fallback
end


-- Create Result object
function Result.new(str: string, formatter: AdvancedFormat, textObject: TextLabel?): Result
	return setmetatable({
		value = str,
		formatter = formatter,
		textObject = textObject
	}, Result) :: any
end

-- Get the result value
function Result:GetResult(): string
	return self.value
end

-- Connect placeholder to values
function Result:connectPlaceholder(name: string, value: string): Result
	if name and value then
		self.formatter.placeholders[name] = value
	end

	self.value = (self.value:gsub("{(.-)}", function(key)
		return tostring(self.formatter.placeholders[key] or "{" .. key .. "}")
	end))

	return self
end

-- setColor
function Result:setColor(colorString: string, textPiece: string?)
	if not self.value then return self end

	local function makeColorTag(inner: string): string
		-- HEX
		if colorString:match("^#%x%x%x%x%x%x$") then
			return string.format('<font color="%s">%s</font>', colorString, inner)
		end

		-- RGB
		local r, g, b = colorString:match("(%d+),(%d+),(%d+)")
		if r and g and b then
			return string.format('<font color="rgb(%d,%d,%d)">%s</font>', tonumber(r), tonumber(g), tonumber(b), inner)
		end

		return inner
	end

	if textPiece then
		self.value = self.value:gsub(textPiece, function(match)
			return makeColorTag(match)
		end, 1)
	else
		self.value = makeColorTag(self.value)
	end

	return self
end

-- editText
function Result:editText(textPiece: string, style: Styles?, font: Fonts?): Result
	if not self.value or textPiece == "" then return self end
	local replacement = textPiece

	font = font or "SourceSansPro"
	replacement = string.format('<font face="%s">%s</font>', font, replacement)

	if style == "Bold" then
		replacement = string.format("<b>%s</b>", replacement)
	elseif style == "Italic" then
		replacement = string.format("<i>%s</i>", replacement)
	end

	self.value = self.value:gsub(textPiece, replacement, 1)
	return self
end

-- setStyle
function Result:setStyle(textPiece: string?, options: StyleOptions)
	if not self.value then return self end

	-- applyStyle на возвращает строку (RichText) — и также создаёт/обновляет линии, если нужно
	local function applyStyle(inner: string): string
		local styled = inner

		-- Font (resolve to Enum.Font and to richText face)
		local enumFont = nil
		local richFace = nil
		if options and options.font and self.textObject then
			enumFont = resolveEnumFont(options.font, self.textObject.Font)
			richFace = enumFont.Name
		elseif self.textObject then
			enumFont = self.textObject.Font
			richFace = enumFont.Name
		else
			enumFont = Enum.Font.SourceSans
			richFace = enumFont.Name
		end

		if options and options.font then
			styled = string.format('<font face="%s">%s</font>', richFace, styled)
		end

		-- Color
		if options and options.color then
			if options.color:match("^#%x%x%x%x%x%x$") then
				styled = string.format('<font color="%s">%s</font>', options.color, styled)
			else
				local r, g, b = options.color:match("(%d+),%s*(%d+),%s*(%d+)")
				if r and g and b then
					styled = string.format('<font color="rgb(%d,%d,%d)">%s</font>', tonumber(r), tonumber(g), tonumber(b), styled)
				end
			end
		end

		-- Basic styles
		if options and options.style == "Bold" then
			styled = string.format("<b>%s</b>", styled)
		elseif options and options.style == "Italic" then
			styled = string.format("<i>%s</i>", styled)
		end

		-- Strikethrough / Underline (fake) — draw frame under/through the specific piece
		if (options and (options.style == "Strikethrough" or options.style == "Underline")) and self.textObject then
			local textObject = self.textObject
			-- choose text used for measurements: prefer the actual Text (stripped) if present, else use self.value (strip tags)
			local visibleSource = (textObject.Text and textObject.Text ~= "") and textObject.Text or self.value
			local plain = stripRichTextTags(visibleSource)
			local startIndex = plain:find(inner, 1, true)
			if not startIndex then
				-- not found — try case-insensitive
				startIndex = plain:lower():find(inner:lower(), 1, true)
			end
			if startIndex then
				-- remove any existing helper lines with same name (avoid duplicates)
				for _, child in ipairs(textObject:GetChildren()) do
					if child.Name == "_Strikethrough" or child.Name == "_Underline" then
						child:Destroy()
					end
				end

				-- measure sizes using resolved font
				local beforeText = plain:sub(1, startIndex - 1)
				local pieceText = plain:sub(startIndex, startIndex + #inner - 1)

				-- If options.font provided, use resolved enumFont; otherwise use textObject.Font
				local measureFont = enumFont or textObject.Font

				local beforeSize = TextService:GetTextSize(beforeText, textObject.TextSize, measureFont, Vector2.new(1e6, textObject.TextSize))
				local pieceSize = TextService:GetTextSize(pieceText, textObject.TextSize, measureFont, Vector2.new(1e6, textObject.TextSize))
				local fullSize = TextService:GetTextSize(plain, textObject.TextSize, measureFont, Vector2.new(1e6, textObject.TextSize))

				-- account for horizontal alignment
				local baseOffset = 0
				if textObject.TextXAlignment == Enum.TextXAlignment.Center then
					baseOffset = math.floor((textObject.AbsoluteSize.X - fullSize.X) / 2)
				elseif textObject.TextXAlignment == Enum.TextXAlignment.Right then
					baseOffset = math.floor(textObject.AbsoluteSize.X - fullSize.X)
				end

				-- compute color
				local lineColor = parseColorString(options.color)
				-- create frame
				local line = Instance.new("Frame")
				line.Name = (options.style == "Strikethrough") and "_Strikethrough" or "_Underline"
				line.BorderSizePixel = 0
				line.BackgroundColor3 = lineColor
				line.BackgroundTransparency = textObject.TextTransparency
				line.ZIndex = (textObject.ZIndex or 1) + 1
				line.AnchorPoint = Vector2.new(0, 0.5)

				-- y position: 0.5 for mid-line (strikethrough), 1 for underline
				local yAnchor = (options.style == "Strikethrough") and 0.5 or 1
				line.Size = UDim2.fromOffset(math.max(1, math.floor(pieceSize.X)), math.max(1, math.ceil(2)))
				line.Position = UDim2.new(0, baseOffset + math.floor(beforeSize.X), yAnchor, 0)
				line.Parent = textObject

				-- refresh function to reposition on changes (Text, TextSize, Font, AbsoluteSize)
				local function refresh()
					local visibleSource2 = (textObject.Text and textObject.Text ~= "") and textObject.Text or self.value
					local plain2 = stripRichTextTags(visibleSource2)
					local start2 = plain2:find(inner, 1, true)
					if not start2 then start2 = plain2:lower():find(inner:lower(), 1, true) end
					if not start2 then
						line:Destroy()
						return
					end
					local before2 = plain2:sub(1, start2 - 1)
					local piece2 = plain2:sub(start2, start2 + #inner - 1)
					local measureFont2 = resolveEnumFont(options and options.font, textObject.Font)
					local beforeSize2 = TextService:GetTextSize(before2, textObject.TextSize, measureFont2, Vector2.new(1e6, textObject.TextSize))
					local pieceSize2 = TextService:GetTextSize(piece2, textObject.TextSize, measureFont2, Vector2.new(1e6, textObject.TextSize))
					local fullSize2 = TextService:GetTextSize(plain2, textObject.TextSize, measureFont2, Vector2.new(1e6, textObject.TextSize))

					local baseOffset2 = 0
					if textObject.TextXAlignment == Enum.TextXAlignment.Center then
						baseOffset2 = math.floor((textObject.AbsoluteSize.X - fullSize2.X) / 2)
					elseif textObject.TextXAlignment == Enum.TextXAlignment.Right then
						baseOffset2 = math.floor(textObject.AbsoluteSize.X - fullSize2.X)
					end

					line.Size = UDim2.fromOffset(math.max(1, math.floor(pieceSize2.X)), math.max(1, math.ceil(2)))
					line.Position = UDim2.new(0, baseOffset2 + math.floor(beforeSize2.X), yAnchor, 0)
					line.BackgroundColor3 = parseColorString(options and options.color)
					line.BackgroundTransparency = textObject.TextTransparency
				end

				-- connect signals
				textObject:GetPropertyChangedSignal("Text"):Connect(refresh)
				textObject:GetPropertyChangedSignal("TextSize"):Connect(refresh)
				textObject:GetPropertyChangedSignal("Font"):Connect(refresh)
				textObject:GetPropertyChangedSignal("AbsoluteSize"):Connect(refresh)
			end
		end

		return styled
	end

	-- do replacement (only first occurrence)
	if textPiece then
		self.value = self.value:gsub(textPiece, function(match)
			return applyStyle(match)
		end, 1)
	else
		self.value = applyStyle(self.value)
	end

	return self
end

function Result:GetTextObject()
	return self.textObject
end

-- === Utility methods ===
function AdvancedFormat:toTitleCase(str: string): string
	return (str:gsub("(%a)([%w_']*)", function(first, rest)
		return first:upper() .. rest:lower()
	end))
end

function AdvancedFormat:ordinal(num: number): string
	local suffix = ""
	local suffixes = {
		[1] = "st", 
		[2] = "nd", 
		[3] = "rd", 
		[4] = "th"
	}
	if num % 100 < 11 or num % 100 > 13 then
		local lastDigit = num % 10
		suffix = suffixes[lastDigit] or "th"
	end
	return tostring(num) .. suffix
end

function AdvancedFormat:pluralize(word: string, count: number): string
	return count == 1 and word or word .. "s"
end

-- timeFormat
function AdvancedFormat:timeFormat(number: number, pattern: TimePatterns): string
	local years   = math.floor(number / 31536000)
	local months  = math.floor((number % 31536000) / 2592000)
	local days    = math.floor((number % 2592000) / 86400)
	local hours   = math.floor((number % 86400) / 3600)
	local minutes = math.floor((number % 3600) / 60)
	local seconds = math.floor(number % 60)

	if pattern == "yyyy/mm/dd hh/mm/ss" then
		return string.format("%04d/%02d/%02d %02d:%02d:%02d", years, months, days, hours, minutes, seconds)
	elseif pattern == "hh:mm:ss" then
		return string.format("%02d:%02d:%02d", hours, minutes, seconds)
	elseif pattern == "yyyy/mm/dd" then
		return string.format("%04d/%02d/%02d", years, months, days)
	elseif pattern == "mm/dd/yyyy" then
		return string.format("%02d/%02d/%04d", months, days, years)
	elseif pattern == "dd:hh:mm:ss" then
		return string.format("%02d:%02d:%02d:%02d", days, hours, minutes, seconds)
	elseif pattern == "yyyy/mm" then
		return string.format("%04d/%02d", years, months)
	elseif pattern == "mm/yyyy" then
		return string.format("%02d/%04d", months, years)
	elseif pattern == "yyyy" then
		return tostring(years)
	elseif pattern == "mm" then
		return tostring(months)
	elseif pattern == "dd" then
		return tostring(days)
	elseif pattern == "hh" then
		return tostring(hours)
	elseif pattern == "mm/ss" then
		return string.format("%02d:%02d", minutes, seconds)
	elseif pattern == "ss" then
		return tostring(seconds)
	end
	return tostring(number)
end

-- invert HEX color
function AdvancedFormat:invert(hex: string): string
	if not hex:match("^#%x%x%x%x%x%x$") then
		return "#000000"
	end
	local r = 255 - tonumber(hex:sub(2, 3), 16)
	local g = 255 - tonumber(hex:sub(4, 5), 16)
	local b = 255 - tonumber(hex:sub(6, 7), 16)
	return string.format("#%02x%02x%02x", r, g, b)
end

-- RGB helpers
function AdvancedFormat:ToRGB(r: number?, g: number?, b: number?): string
	r = r or 255
	g = g or r
	b = b or r
	return string.format("rgb(%d,%d,%d)", r, g, b)
end

function AdvancedFormat:ToHex(r: number, g: number, b: number): string
	r = math.clamp(math.floor(r), 0, 255)
	g = math.clamp(math.floor(g), 0, 255)
	b = math.clamp(math.floor(b), 0, 255)
	return string.format("#%02x%02x%02x", r, g, b)
end

function AdvancedFormat:ToHSV(h: number?, s: number?, v: number?): string
	h = (h or 0) / 100
	s = (s or 0) / 100
	v = (v or 0) / 100
	local c = Color3.fromHSV(h, s, v)
	local r = math.floor(c.R * 255)
	local g = math.floor(c.G * 255)
	local b = math.floor(c.B * 255)
	return string.format("rgb(%d,%d,%d)", r, g, b)
end

-- === AdvancedFormat ===
function AdvancedFormat.new(printInitMessage): AdvancedFormat
	local self = setmetatable({}, AdvancedFormat)
	self.placeholders = {}
	checkVersionEvent.OnServerEvent:Connect(function(url)
		warn(scriptPrefix.."Your module version is Up-to update. Please update here: "..url)
	end)
	if not printInitMessage then
		printInitMessage = true
	end
	if printInitMessage then
		print(scriptPrefix.."module initialized.")
	end
	return self
end

function AdvancedFormat:formatString(str: string, TextObject: TextBox? | TextLabel? | TextButton?): Result
	local result = (str:gsub("{(.-)}", function(key)
		return tostring(self.placeholders[key] or "{" .. key .. "}")
	end))
	if not TextObject then
		warn(scriptPrefix.."Text object has not found. Strikethrough and Underline style will not work.")
	end
	return Result.new(result, self, TextObject)
end

return AdvancedFormat