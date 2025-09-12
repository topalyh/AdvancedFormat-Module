**⚠️ MODULE STILL IN WORK!**

    AdvancedFormat Version 1.0.0
    Author: @topalyh
    License: MIT
**📦 Installation**

    Put this module into ReplicatedStorage and require it from there.

    Example:
        local AdvancedFormat = require(game.ReplicatedStorage:FindFirstChild("AdvancedFormat"))
        local format = AdvancedFormat.new()
**🚀 Quick Example**

    local Name = "John Doe"
    local Points = 100
    local Time = 3600

   	local text = format:formatString("Hello {name}, you earned {points} in {time}!")
   	text:connectPlaceholder("name", Name)
    text:connectPlaceholder("points", Points)
    text:connectPlaceholder("time", format:formatTime(Time, "hh/mm/ss"))
    
    print(text:GetResult())
    -- Hello John Doe, you earned 100 in 01:00:00!
**📖 Documentation**

    AdvancedFormat is a Roblox Lua module that provides advanced string formatting
    with placeholders and rich text styling (colors, fonts, bold, italic, strikethrough, underline).

    ✅ Works with Roblox RichText
    ✅ Has multi-function support (method chaining like :func1():func2():func3())  
    ✅ Support color functions (like RGB, Hex and HSV)
    ✅ Has custom style support (like Strikethrough and Underline, but it buggy and requires turned off TextWrapped and TextScaled)
**📑 API Reference**

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
    format:ToHSV(100, 100, 100) -- "255, 0, 0"
**🎨 Notes**

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
        - None (default)
   	⚠️ Experemental styles:
   		- Strikethrough
        - Underline
**📝 Changelog**

    1.0.0
        - Initial release with placeholders and rich text styling
        - Added support for RGB, HEX and HSV color utilities
        - Added style editing (Bold / Italic / Strikethrough / Underline / None)
        - Added font support
