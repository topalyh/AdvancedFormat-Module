# `⚠️ MODULE STILL IN WORK!`

    AdvancedFormat Version 1.0.0
    Author: @topalyh
    License: MIT
# 📦 File Installation

1. Download file
2. Open Roblox studio (if you dont have Roblox studio, download here: [https://create.roblox.com](https://create.roblox.com))
3. Open any place
4. RMB(Right Mouse Button) to Workspace > Insert > Insert from file
5. Select your file (file name should be AdvancedFormat_Module.rbxm)
6. Click open
7. Done
# 📦 Roblox Installation

Put this module into ReplicatedStorage and require it from there.

Example:
```lua
local AdvancedFormat = require(game.ReplicatedStorage:FindFirstChild("AdvancedFormat"))
local format = AdvancedFormat.new()
```
# 🚀 Quick Example
```lua
local Name = "John Doe"
local Points = 100
local Time = 3600

local text = format:formatString("Hello {name}, you earned {points} in {time}!")
text:connectPlaceholder("name", Name)
text:connectPlaceholder("points", Points)
text:connectPlaceholder("time", format:formatTime(Time, "hh/mm/ss"))
    
print(text:GetResult())
-- Hello John Doe, you earned 100 in 01:00:00!
```
# 📖 Documentation

    AdvancedFormat is a Roblox Lua module that provides advanced string formatting
    with placeholders and rich text styling (colors, fonts, bold, italic, strikethrough, underline).

    ✅ Works with Roblox RichText
    ✅ Has multi-function support (method chaining like :func1():func2():func3())  
    ✅ Support color functions (like RGB, Hex, HSV, HSL and CMYK)
# 📑 API Reference
```lua
-- Formatter
local format = AdvancedFormat.new()
local text = format:formatString("Hello {name}")

-- Placeholders
text:connectPlaceholder("name", "John Doe")

-- Styling
text:setStyle("name", {
    color = "255,255,255",   -- or format:ToRGB(255,255,255) / format:ToHex("#ff00ff")
    font  = "Oswald",
    style = "Bold"
})

-- Alternative
text:editText("name", "Italic", "BuilderSans")
text:setColor("name", "255, 255, 255")

-- Result
print(text:GetResult())
-- Output: Hello <font color="rgb(255,255,255)"><font face="Oswald"><b>John Doe</b></font></font>
    
-- Additional functions
    
format:toTitleCase("hello world") -- "Hello World"
format:ordinal(1) -- "1st"
format:ordinal(2) -- "2nd"
format:ordinal(3) -- "3rd"
format:ordinal(4) -- "4th"
format:pluralize("point", 1) -- "point"
format:pluralize("point", 2) -- "points"
format:timeFormat(3661, "hh/mm/ss") -- "01/01/01"
format:timeFormat(61, "mm:ss") -- "01:01"
format:invert("#ffffff") -- #000000
format:ToRGB(255, 255, 255) -- "255, 255, 255"
format:ToHex(255, 0, 255) -- "#ff00ff"
format:ToHSV(100, 0, 100) -- 255, 255, 255
format:ToHSV(1, 1, 1) -- 255, 0, 0
format:ToHSL(120, 100, 50) -- 0, 255, 0
format:ToCMYK(0, 100, 0, 0) -- 255, 0, 255
```
# 🎨 Notes

⚠️ Important: Make sure "RichText" is enabled on your TextLabel, TextButton or TextBox.

Available utilities:
- format:ToRGB(r, g, b)
- format:ToHex("#rrggbb")

Supported fonts:
- SourceSansPro (default)
- Gotham
- Oswald
- Arial
- Cartoon
- Fantasy
- BuilderSans
Supported styles:
- Bold
- Italic
- Strikethrough
- Underline
- None (default)
# 📝 Changelog

1.0.0
- Initial release with placeholders and rich text styling
- Added support for RGB, HEX, HSV, HSL and CMYK color utilities
- Added style editing (Bold / Italic / Strikethrough / Underline)
- Added font support
