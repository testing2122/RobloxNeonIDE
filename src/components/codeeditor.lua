local codeEditor = {};
codeEditor.__index = codeEditor;

local function getUtils()
    local loadstring = getfenv().loadstring;
    return {
        ui = loadstring(game:HttpGet("https://raw.githubusercontent.com/testing2122/RobloxNeonIDE/main/src/utils/ui.lua"))(),
        animate = loadstring(game:HttpGet("https://raw.githubusercontent.com/testing2122/RobloxNeonIDE/main/src/utils/animate.lua"))()
    };
end

-- Keywords for syntax highlighting
local keywords = {
    ["and"] = true,
    ["break"] = true,
    ["do"] = true,
    ["else"] = true,
    ["elseif"] = true,
    ["end"] = true,
    ["false"] = true,
    ["for"] = true,
    ["function"] = true,
    ["if"] = true,
    ["in"] = true,
    ["local"] = true,
    ["nil"] = true,
    ["not"] = true,
    ["or"] = true,
    ["repeat"] = true,
    ["return"] = true,
    ["then"] = true,
    ["true"] = true,
    ["until"] = true,
    ["while"] = true,
    ["continue"] = true
};

-- Common Roblox globals and services
local builtins = {
    -- Roblox globals
    ["game"] = true,
    ["workspace"] = true,
    ["script"] = true,
    ["math"] = true,
    ["string"] = true,
    ["table"] = true,
    ["task"] = true,
    ["wait"] = true,
    ["spawn"] = true,
    ["delay"] = true,
    ["tick"] = true,
    ["pcall"] = true,
    ["xpcall"] = true,
    ["select"] = true,
    ["type"] = true,
    ["typeof"] = true,
    ["ipairs"] = true,
    ["pairs"] = true,
    ["next"] = true,
    ["require"] = true,
    ["setmetatable"] = true,
    ["getmetatable"] = true,
    ["rawget"] = true,
    ["rawset"] = true,
    ["rawequal"] = true,
    ["tonumber"] = true,
    ["tostring"] = true,
    ["warn"] = true,
    ["error"] = true,
    ["assert"] = true,
    ["print"] = true,
    ["Instance"] = true,
    ["Vector2"] = true,
    ["Vector3"] = true,
    ["CFrame"] = true,
    ["Color3"] = true,
    ["UDim"] = true,
    ["UDim2"] = true,
    ["Enum"] = true,
    ["Ray"] = true,
    ["Random"] = true,
    ["BrickColor"] = true,
    ["ColorSequence"] = true,
    ["NumberSequence"] = true,
    ["Region3"] = true,
    ["Rect"] = true,
    ["TweenInfo"] = true,
    
    -- Services
    ["Players"] = true,
    ["Workspace"] = true,
    ["ReplicatedStorage"] = true,
    ["RunService"] = true,
    ["UserInputService"] = true,
    ["TweenService"] = true,
    ["Debris"] = true,
    ["ContentProvider"] = true,
    ["CoreGui"] = true,
    ["CorePackages"] = true,
    ["StarterGui"] = true,
    ["StarterPack"] = true,
    ["StarterPlayer"] = true,
    ["SoundService"] = true,
    ["HttpService"] = true,
    ["Lighting"] = true,
    ["MarketplaceService"] = true,
    ["Chat"] = true,
    ["Teams"] = true,
    
    -- Exploits
    ["gethui"] = true,
    ["getgenv"] = true,
    ["hookfunction"] = true,
    ["checkcaller"] = true,
    ["getrawmetatable"] = true,
    ["setrawmetatable"] = true,
    ["newcclosure"] = true,
    ["setclipboard"] = true,
    ["setfpscap"] = true,
    ["loadstring"] = true,
    ["isfolder"] = true,
    ["makefolder"] = true,
    ["delfolder"] = true,
    ["isfile"] = true,
    ["writefile"] = true,
    ["appendfile"] = true,
    ["readfile"] = true,
    ["delfile"] = true,
    ["listfiles"] = true,
    ["getcustomasset"] = true,
    ["getconnections"] = true,
    ["firesignal"] = true,
    ["fireclickdetector"] = true,
    ["fireproximityprompt"] = true,
    ["hookmetamethod"] = true
};

local operators = {
    ["+"] = true,
    ["-"] = true,
    ["*"] = true,
    ["/"] = true,
    ["^"] = true,
    ["%"] = true,
    ["="] = true,
    ["=="] = true,
    ["~="] = true,
    [">"] = true,
    ["<"] = true,
    [">="] = true,
    ["<="] = true,
    [".."] = true,
    ["#"] = true
};

function codeEditor.new(parent)
    local utils = getUtils();
    local self = setmetatable({}, codeEditor);
    
    self.theme = parent and parent.theme or {
        BACKGROUND = Color3.fromRGB(15, 15, 25),
        BACKGROUND_SECONDARY = Color3.fromRGB(20, 20, 32),
        ACCENT = Color3.fromRGB(128, 64, 255),
        ACCENT_DARK = Color3.fromRGB(90, 45, 180),
        TEXT_PRIMARY = Color3.fromRGB(240, 240, 255),
        TEXT_SECONDARY = Color3.fromRGB(180, 180, 195),
        BORDER = Color3.fromRGB(40, 40, 60),
        SHADOW = Color3.fromRGB(0, 0, 10),
        SUCCESS = Color3.fromRGB(80, 200, 120),
        ERROR = Color3.fromRGB(220, 70, 70),
        WARNING = Color3.fromRGB(230, 180, 60)
    };
    
    self.colors = {
        normal = self.theme.TEXT_PRIMARY,
        keyword = Color3.fromRGB(200, 120, 255),
        string = Color3.fromRGB(120, 220, 160),
        number = Color3.fromRGB(255, 180, 100),
        comment = Color3.fromRGB(110, 110, 130),
        builtin = Color3.fromRGB(100, 160, 255),
        operator = Color3.fromRGB(255, 150, 150),
        background = self.theme.BACKGROUND,
        gutter = self.theme.BACKGROUND_SECONDARY,
        selection = Color3.fromRGB(70, 70, 90),
        linenumber = self.theme.TEXT_SECONDARY,
        cursor = self.theme.ACCENT,
        highlight = Color3.fromRGB(40, 40, 60)
    };
    
    self.code = "";
    self.lines = {""};
    self.focused = false;
    self.cursorPosition = {line = 1, column = 1};
    self.selectionStart = nil;
    self.selectionEnd = nil;
    self.scrollPosition = 0;
    
    return self;
end

function codeEditor:mount(parent)
    local utils = getUtils();
    
    self.container = utils.ui.create("Frame", {
        Name = "CodeEditor",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = self.colors.background,
        BorderSizePixel = 0,
        Parent = parent
    });
    
    -- Create gutter (line numbers)
    self.gutter = utils.ui.create("Frame", {
        Name = "Gutter",
        Size = UDim2.new(0, 50, 1, 0),
        BackgroundColor3 = self.colors.gutter,
        BorderSizePixel = 0,
        Parent = self.container
    });
    
    self.lineNumbers = utils.ui.create("ScrollingFrame", {
        Name = "LineNumbers",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        BorderSizePixel = 0,
        ScrollBarThickness = 0,
        ScrollingEnabled = false,
        Parent = self.gutter
    });
    
    utils.ui.create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 0),
        Parent = self.lineNumbers
    });
    
    -- Create editor area
    self.editorArea = utils.ui.create("ScrollingFrame", {
        Name = "EditorArea",
        Size = UDim2.new(1, -50, 1, 0),
        Position = UDim2.new(0, 50, 0, 0),
        BackgroundColor3 = self.colors.background,
        BorderSizePixel = 0,
        ScrollBarThickness = 4,
        ScrollBarImageColor3 = self.theme.ACCENT,
        ScrollBarImageTransparency = 0.5,
        CanvasSize = UDim2.new(0, 0, 0, 0),
        Parent = self.container
    });
    
    -- Cursor
    self.cursor = utils.ui.create("Frame", {
        Name = "Cursor",
        Size = UDim2.new(0, 2, 0, 16),
        BackgroundColor3 = self.colors.cursor,
        BorderSizePixel = 0,
        Visible = false,
        ZIndex = 3,
        Parent = self.editorArea
    });
    
    -- Line highlight
    self.lineHighlight = utils.ui.create("Frame", {
        Name = "LineHighlight",
        Size = UDim2.new(1, 0, 0, 18),
        BackgroundColor3 = self.colors.highlight,
        BorderSizePixel = 0,
        BackgroundTransparency = 0.6,
        ZIndex = 1,
        Visible = false,
        Parent = self.editorArea
    });
    
    -- Create text input
    self.textInput = utils.ui.create("TextBox", {
        Name = "TextInput",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        TextSize = 14,
        Font = Enum.Font.Code,
        MultiLine = true,
        ClearTextOnFocus = false,
        TextEditable = true,
        TextColor3 = self.colors.normal,
        PlaceholderText = "Type your code here...",
        PlaceholderColor3 = Color3.fromRGB(120, 120, 140),
        Visible = false, -- Hidden, we'll use our own rendering
        Parent = self.editorArea
    });
    
    -- Content holder for syntax highlighting
    self.contentHolder = utils.ui.create("Frame", {
        Name = "ContentHolder",
        Size = UDim2.new(1, -10, 1, 0),
        BackgroundTransparency = 1,
        Parent = self.editorArea
    });
    
    utils.ui.create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 0),
        Parent = self.contentHolder
    });
    
    -- Set up event handling
    self:setupEvents();
    self:updateLineNumbers();
    
    return self;
end

function codeEditor:setupEvents()
    local utils = getUtils();
    local uis = game:GetService("UserInputService");
    local runservice = game:GetService("RunService");
    
    -- Handle focus and cursor blinking
    local blinkInterval = 0.5;
    local lastBlinkTime = 0;
    local cursorVisible = false;
    
    self.container.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            -- Focus the editor and place cursor
            self.focused = true;
            self:updateCursorPosition(input);
        end
    end);
    
    self.textInput.Focused:Connect(function()
        self.focused = true;
    end);
    
    self.textInput.FocusLost:Connect(function()
        self.focused = false;
        self.cursor.Visible = false;
        self.lineHighlight.Visible = false;
    end);
    
    -- Handle mouse clicks for cursor positioning
    self.editorArea.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self:updateCursorPosition(input);
            self.textInput:CaptureFocus();
        end
    end);
    
    -- Handle text input
    self.textInput:GetPropertyChangedSignal("Text"):Connect(function()
        local newText = self.textInput.Text;
        if newText ~= self.code then
            self:setCode(newText);
        end
    end);
    
    -- Cursor blinking
    runservice.RenderStepped:Connect(function(delta)
        lastBlinkTime = lastBlinkTime + delta;
        
        if lastBlinkTime > blinkInterval then
            lastBlinkTime = 0;
            
            if self.focused then
                cursorVisible = not cursorVisible;
                self.cursor.Visible = cursorVisible;
            else
                self.cursor.Visible = false;
            end
        end
        
        -- Update line highlight position
        if self.focused then
            self.lineHighlight.Visible = true;
            self.lineHighlight.Position = UDim2.new(0, 0, 0, (self.cursorPosition.line - 1) * 18);
        else
            self.lineHighlight.Visible = false;
        end
    end);
    
    -- Handle scrolling
    self.editorArea:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
        self.scrollPosition = self.editorArea.CanvasPosition.Y;
        self.lineNumbers.CanvasPosition = Vector2.new(0, self.scrollPosition);
    end);
    
    -- Sync line numbers with editor scrolling
    self.lineNumbers:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
        if self.lineNumbers.CanvasPosition.Y ~= self.scrollPosition then
            self.lineNumbers.CanvasPosition = Vector2.new(0, self.scrollPosition);
        end
    end);
    
    -- Keyboard input handling
    local keyboardEnabled = true;
    
    uis.InputBegan:Connect(function(input, gameProcessed)
        if not self.focused or gameProcessed then return; end
        
        if input.KeyCode == Enum.KeyCode.Tab then
            -- Insert tab character
            local line = self.lines[self.cursorPosition.line];
            local newLine = line:sub(1, self.cursorPosition.column - 1) .. "    " .. line:sub(self.cursorPosition.column);
            self.lines[self.cursorPosition.line] = newLine;
            self.cursorPosition.column = self.cursorPosition.column + 4;
            self:updateCode();
        end
    end);
    
    -- Make cursor visible immediately on focus
    self.container.MouseEnter:Connect(function()
        if self.focused then
            cursorVisible = true;
            self.cursor.Visible = true;
            lastBlinkTime = 0;
        end
    end);
end

function codeEditor:updateCursorPosition(input)
    local utils = getUtils();
    local mousePos = input.Position;
    local editorPos = self.editorArea.AbsolutePosition;
    local editorSize = self.editorArea.AbsoluteSize;
    
    -- Calculate line
    local y = mousePos.Y - editorPos.Y + self.editorArea.CanvasPosition.Y;
    local line = math.ceil(y / 18);
    line = math.max(1, math.min(line, #self.lines));
    
    -- Calculate column
    local x = mousePos.X - editorPos.X;
    local text = self.lines[line]:sub(1, 100); -- Limit for performance
    local column = 1;
    
    -- Approximate character width (for monospace font)
    local charWidth = 8;
    column = math.ceil(x / charWidth);
    column = math.max(1, math.min(column, #self.lines[line] + 1));
    
    self.cursorPosition = {line = line, column = column};
    
    -- Update cursor visual position
    self.cursor.Position = UDim2.new(0, (column - 1) * charWidth + 5, 0, (line - 1) * 18);
    self.cursor.Size = UDim2.new(0, 2, 0, 16);
    
    -- Update line highlight
    self.lineHighlight.Position = UDim2.new(0, 0, 0, (line - 1) * 18);
    self.lineHighlight.Size = UDim2.new(1, 0, 0, 18);
    
    return self;
end

function codeEditor:updateLineNumbers()
    local utils = getUtils();
    
    -- Clear existing line numbers
    for _, child in pairs(self.lineNumbers:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy();
        end
    end
    
    -- Add new line numbers
    for i = 1, #self.lines do
        utils.ui.create("TextLabel", {
            Name = "Line_" .. i,
            Size = UDim2.new(1, -10, 0, 18),
            Position = UDim2.new(0, 0, 0, (i - 1) * 18),
            BackgroundTransparency = 1,
            Text = tostring(i),
            TextColor3 = self.colors.linenumber,
            TextSize = 14,
            Font = Enum.Font.Code,
            TextXAlignment = Enum.TextXAlignment.Right,
            LayoutOrder = i,
            Parent = self.lineNumbers
        });
    end
    
    -- Update canvas size
    self.lineNumbers.CanvasSize = UDim2.new(0, 0, 0, #self.lines * 18);
    self.editorArea.CanvasSize = UDim2.new(0, 0, 0, #self.lines * 18);
    
    return self;
end

function codeEditor:tokenize(line)
    local tokens = {};
    local i = 1;
    local length = #line;
    
    while i <= length do
        local char = line:sub(i, i);
        
        -- Comments
        if char == "-" and i < length and line:sub(i + 1, i + 1) == "-" then
            local tokenText = line:sub(i);
            table.insert(tokens, {text = tokenText, type = "comment"});
            break;
        -- Strings
        elseif char == "'" or char == "\"" then
            local quote = char;
            local startIdx = i;
            i = i + 1;
            
            while i <= length do
                if line:sub(i, i) == "\\" and i < length then
                    i = i + 2; -- Skip escaped character
                elseif line:sub(i, i) == quote then
                    break;
                else
                    i = i + 1;
                end
            end
            
            if i <= length then
                local tokenText = line:sub(startIdx, i);
                table.insert(tokens, {text = tokenText, type = "string"});
                i = i + 1;
            else
                -- Unclosed string, just treat rest of line as a string
                local tokenText = line:sub(startIdx);
                table.insert(tokens, {text = tokenText, type = "string"});
                break;
            end
        -- Numbers
        elseif char:match("%d") then
            local startIdx = i;
            i = i + 1;
            
            while i <= length and line:sub(i, i):match("[%d%.]") do
                i = i + 1;
            end
            
            local tokenText = line:sub(startIdx, i - 1);
            table.insert(tokens, {text = tokenText, type = "number"});
        -- Identifiers and keywords
        elseif char:match("[%a_]") then
            local startIdx = i;
            i = i + 1;
            
            while i <= length and line:sub(i, i):match("[%w_]") do
                i = i + 1;
            end
            
            local tokenText = line:sub(startIdx, i - 1);
            local tokenType = "normal";
            
            if keywords[tokenText] then
                tokenType = "keyword";
            elseif builtins[tokenText] then
                tokenType = "builtin";
            end
            
            table.insert(tokens, {text = tokenText, type = tokenType});
        -- Operators
        elseif operators[char] or char:match("[%+%-%*%/%^%%=<>%.#]") then
            local startIdx = i;
            i = i + 1;
            
            -- Check for multi-character operators
            if i <= length then
                local twoChars = line:sub(startIdx, i);
                if operators[twoChars] then
                    table.insert(tokens, {text = twoChars, type = "operator"});
                    i = i + 1;
                else
                    table.insert(tokens, {text = char, type = "operator"});
                end
            else
                table.insert(tokens, {text = char, type = "operator"});
            end
        -- Whitespace and other characters
        else
            local tokenText = char;
            table.insert(tokens, {text = tokenText, type = "normal"});
            i = i + 1;
        end
    end
    
    return tokens;
end

function codeEditor:highlight()
    local utils = getUtils();
    
    -- Clear existing content
    for _, child in pairs(self.contentHolder:GetChildren()) do
        if child:IsA("TextLabel") then
            child:Destroy();
        end
    end
    
    -- Highlight each line
    for i, line in ipairs(self.lines) do
        local lineLabel = utils.ui.create("TextLabel", {
            Name = "SyntaxLine_" .. i,
            Size = UDim2.new(1, 0, 0, 18),
            Position = UDim2.new(0, 0, 0, (i - 1) * 18),
            BackgroundTransparency = 1,
            Text = "",
            TextSize = 14,
            Font = Enum.Font.Code,
            TextXAlignment = Enum.TextXAlignment.Left,
            TextYAlignment = Enum.TextYAlignment.Center,
            RichText = true,
            LayoutOrder = i,
            Parent = self.contentHolder
        });
        
        local tokens = self:tokenize(line);
        local richText = "";
        
        for _, token in ipairs(tokens) do
            local color;
            
            if token.type == "keyword" then
                color = self.colors.keyword;
            elseif token.type == "string" then
                color = self.colors.string;
            elseif token.type == "number" then
                color = self.colors.number;
            elseif token.type == "comment" then
                color = self.colors.comment;
            elseif token.type == "builtin" then
                color = self.colors.builtin;
            elseif token.type == "operator" then
                color = self.colors.operator;
            else
                color = self.colors.normal;
            end
            
            local r = math.floor(color.R * 255);
            local g = math.floor(color.G * 255);
            local b = math.floor(color.B * 255);
            local hexColor = string.format("#%02X%02X%02X", r, g, b);
            
            -- Escape < and > for RichText
            local escapedText = token.text:gsub("<", "&lt;"):gsub(">", "&gt;");
            
            richText = richText .. string.format('<font color="%s">%s</font>', hexColor, escapedText);
        end
        
        lineLabel.Text = richText;
    end
    
    return self;
end

function codeEditor:updateCode()
    self.code = table.concat(self.lines, "\n");
    self.textInput.Text = self.code;
    
    self:updateLineNumbers();
    self:highlight();
    
    return self;
end

function codeEditor:setCode(code)
    self.code = code or "";
    self.lines = {};
    
    for line in string.gmatch(self.code .. "\n", "(.-)\n") do
        table.insert(self.lines, line);
    end
    
    if #self.lines == 0 then
        table.insert(self.lines, "");
    end
    
    self:updateLineNumbers();
    self:highlight();
    
    return self;
end

function codeEditor:getCode()
    return self.code;
end

return codeEditor;