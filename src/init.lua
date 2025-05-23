local NeonIDE = {}
NeonIDE.__index = NeonIDE;

-- Services
local players = game:GetService("Players");
local runservice = game:GetService("RunService");
local tweenservice = game:GetService("TweenService");
local uis = game:GetService("UserInputService");
local coregui = game:GetService("CoreGui");

-- Constants
local THEME = {
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

-- Imports (using loadstring for exploits)
local components = {};
components.codeeditor = loadstring(game:HttpGet("https://raw.githubusercontent.com/testing2122/RobloxNeonIDE/main/src/components/codeeditor.lua"))();
components.aichat = loadstring(game:HttpGet("https://raw.githubusercontent.com/testing2122/RobloxNeonIDE/main/src/components/aichat.lua"))();
components.tabsystem = loadstring(game:HttpGet("https://raw.githubusercontent.com/testing2122/RobloxNeonIDE/main/src/components/tabsystem.lua"))();

local utils = {};
utils.animate = loadstring(game:HttpGet("https://raw.githubusercontent.com/testing2122/RobloxNeonIDE/main/src/utils/animate.lua"))();
utils.ui = loadstring(game:HttpGet("https://raw.githubusercontent.com/testing2122/RobloxNeonIDE/main/src/utils/ui.lua"))();

-- Constructor
function NeonIDE.new()
    local self = setmetatable({}, NeonIDE);
    
    -- Properties
    self.visible = false;
    self.theme = THEME;
    self.components = {};
    
    -- Create main container
    self.gui = utils.ui.create("ScreenGui", {
        Name = "NeonIDE",
        ResetOnSpawn = false,
        ZIndexBehavior = Enum.ZIndexBehavior.Sibling,
        Parent = gethui and gethui() or coregui
    });
    
    self.container = utils.ui.create("Frame", {
        Name = "Container",
        Size = UDim2.new(0.9, 0, 0.8, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = self.theme.BACKGROUND,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = self.gui
    });
    
    -- Add corner and shadow
    utils.ui.create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = self.container
    });
    
    utils.ui.create("UIStroke", {
        Color = self.theme.BORDER,
        Thickness = 1,
        Transparency = 0,
        Parent = self.container
    });
    
    local shadow = utils.ui.create("ImageLabel", {
        Name = "Shadow",
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1.02, 0, 1.02, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        ZIndex = -1,
        Image = "rbxassetid://6014261993", -- Shadow asset
        ImageColor3 = self.theme.SHADOW,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(49, 49, 450, 450),
        Parent = self.container
    });
    
    -- Header
    self.header = utils.ui.create("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 30),
        BackgroundColor3 = self.theme.BACKGROUND_SECONDARY,
        BorderSizePixel = 0,
        Parent = self.container
    });
    
    utils.ui.create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = self.header
    });
    
    utils.ui.create("Frame", {
        Name = "CornerFix",
        Size = UDim2.new(1, 0, 0.5, 0),
        Position = UDim2.new(0, 0, 0.5, 0),
        BackgroundColor3 = self.theme.BACKGROUND_SECONDARY,
        BorderSizePixel = 0,
        Parent = self.header
    });
    
    self.title = utils.ui.create("TextLabel", {
        Name = "Title",
        BackgroundTransparency = 1,
        Position = UDim2.new(0, 10, 0, 0),
        Size = UDim2.new(0.5, 0, 1, 0),
        Font = Enum.Font.GothamBold,
        Text = "NeonIDE",
        TextColor3 = self.theme.ACCENT,
        TextSize = 14,
        TextXAlignment = Enum.TextXAlignment.Left,
        Parent = self.header
    });
    
    -- Close button
    self.closeBtn = utils.ui.create("TextButton", {
        Name = "CloseButton",
        BackgroundTransparency = 1,
        Position = UDim2.new(1, -25, 0, 5),
        Size = UDim2.new(0, 20, 0, 20),
        Font = Enum.Font.GothamBold,
        Text = "X",
        TextColor3 = self.theme.TEXT_SECONDARY,
        TextSize = 14,
        Parent = self.header
    });
    
    -- Main content frame
    self.content = utils.ui.create("Frame", {
        Name = "Content",
        Size = UDim2.new(1, 0, 1, -30),
        Position = UDim2.new(0, 0, 0, 30),
        BackgroundColor3 = self.theme.BACKGROUND,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = self.container
    });
    
    -- Split view: Code editor (left) and AI Chat (right)
    self.editorFrame = utils.ui.create("Frame", {
        Name = "EditorFrame",
        Size = UDim2.new(0.75, -1, 1, 0),
        BackgroundColor3 = self.theme.BACKGROUND,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = self.content
    });
    
    self.chatFrame = utils.ui.create("Frame", {
        Name = "ChatFrame",
        Size = UDim2.new(0.25, 0, 1, 0),
        Position = UDim2.new(0.75, 0, 0, 0),
        BackgroundColor3 = self.theme.BACKGROUND_SECONDARY,
        BorderSizePixel = 0,
        ClipsDescendants = true,
        Parent = self.content
    });
    
    -- Add separator
    self.separator = utils.ui.create("Frame", {
        Name = "Separator",
        Size = UDim2.new(0, 1, 1, 0),
        Position = UDim2.new(0.75, -1, 0, 0),
        BackgroundColor3 = self.theme.BORDER,
        BorderSizePixel = 0,
        Parent = self.content
    });
    
    -- Initialize components
    self.editor = components.codeeditor.new(self);
    self.editor:mount(self.editorFrame);
    
    self.chat = components.aichat.new(self);
    self.chat:mount(self.chatFrame);
    
    -- Register events
    self.closeBtn.MouseButton1Click:Connect(function()
        self:hide();
    });
    
    self.dragging = false;
    self.dragInput = nil;
    self.dragStart = nil;
    self.startPos = nil;
    
    self.header.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.dragging = true;
            self.dragStart = input.Position;
            self.startPos = self.container.Position;
        end
    end);
    
    self.header.InputEnded:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            self.dragging = false;
        end
    end);
    
    uis.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and self.dragging then
            local delta = input.Position - self.dragStart;
            self.container.Position = UDim2.new(
                self.startPos.X.Scale, 
                self.startPos.X.Offset + delta.X,
                self.startPos.Y.Scale,
                self.startPos.Y.Offset + delta.Y
            );
        end
    end);
    
    return self;
end

-- Show/hide methods
function NeonIDE:show()
    if self.visible then return; end
    self.visible = true;
    
    self.gui.Enabled = true;
    self.container.Position = UDim2.new(0.5, 0, 0.5, 25);
    self.container.BackgroundTransparency = 1;
    
    -- Animate the appearance
    utils.animate.spring(self.container, {
        Position = UDim2.new(0.5, 0, 0.5, 0),
        BackgroundTransparency = 0
    }, 0.8, "easeOutElastic");
    
    return self;
end

function NeonIDE:hide()
    if not self.visible then return; end
    self.visible = false;
    
    -- Animate the disappearance
    utils.animate.spring(self.container, {
        Position = UDim2.new(0.5, 0, 0.5, 25),
        BackgroundTransparency = 1
    }, 0.5, "easeInQuad", function()
        self.gui.Enabled = false;
    end);
    
    return self;
end

-- API methods
function NeonIDE:setCode(code)
    self.editor:setCode(code);
    return self;
end

function NeonIDE:getCode()
    return self.editor:getCode();
end

function NeonIDE:setTheme(theme)
    self.theme = theme;
    -- Apply theming logic here
    return self;
end

return NeonIDE;