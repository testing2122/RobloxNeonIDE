local ui = {}

-- Create an Instance with properties
function ui.create(className, properties)
    local instance = Instance.new(className);
    
    for property, value in pairs(properties) do
        if property ~= "Parent" then
            instance[property] = value;
        end
    end
    
    if properties.Parent then
        instance.Parent = properties.Parent;
    end
    
    return instance;
end

-- Add hover effect to a button
function ui.addHoverEffect(button, hoverColor, normalColor)
    normalColor = normalColor or button.BackgroundColor3;
    
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = hoverColor;
    end);
    
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = normalColor;
    end);
end

-- Create a glowing border effect
function ui.addGlowEffect(frame, glowColor, glowSize, transparency)
    glowSize = glowSize or 15;
    transparency = transparency or 0.9;
    
    local glow = ui.create("ImageLabel", {
        Name = "Glow",
        BackgroundTransparency = 1,
        Position = UDim2.new(0.5, 0, 0.5, 0),
        Size = UDim2.new(1, glowSize, 1, glowSize),
        AnchorPoint = Vector2.new(0.5, 0.5),
        Image = "rbxassetid://4996891970", -- Radial gradient
        ImageColor3 = glowColor,
        ImageTransparency = transparency,
        ScaleType = Enum.ScaleType.Slice,
        SliceCenter = Rect.new(20, 20, 20, 20),
        ZIndex = frame.ZIndex - 1,
        Parent = frame
    });
    
    return glow;
end

-- Create scrolling frame with smooth scrolling
function ui.createSmoothScrollFrame(properties)
    properties = properties or {};
    
    local frame = ui.create("ScrollingFrame", {
        BackgroundTransparency = properties.BackgroundTransparency or 1,
        BorderSizePixel = properties.BorderSizePixel or 0,
        Position = properties.Position or UDim2.new(0, 0, 0, 0),
        Size = properties.Size or UDim2.new(1, 0, 1, 0),
        CanvasSize = properties.CanvasSize or UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = properties.ScrollBarThickness or 4,
        ScrollBarImageColor3 = properties.ScrollBarImageColor3 or Color3.fromRGB(128, 64, 255),
        ScrollBarImageTransparency = properties.ScrollBarImageTransparency or 0.5,
        VerticalScrollBarInset = Enum.ScrollBarInset.ScrollBar,
        Parent = properties.Parent,
        ZIndex = properties.ZIndex or 1,
        ClipsDescendants = true
    });
    
    local uis = game:GetService("UserInputService");
    local targetPosition = 0;
    local smoothness = properties.Smoothness or 0.16;
    local connections = {};
    
    table.insert(connections, frame:GetPropertyChangedSignal("CanvasPosition"):Connect(function()
        targetPosition = frame.CanvasPosition.Y;
    end));
    
    local vel = 0;
    table.insert(connections, game:GetService("RunService").RenderStepped:Connect(function(dt)
        if not frame or not frame.Parent then
            for _, conn in ipairs(connections) do
                conn:Disconnect();
            end
            return;
        end
        
        local currentPos = frame.CanvasPosition.Y;
        local diff = (targetPosition - currentPos);
        vel = vel * 0.8 + diff * smoothness;
        
        if math.abs(diff) > 0.5 then
            frame.CanvasPosition = Vector2.new(0, currentPos + vel);
        end
    end));
    
    table.insert(connections, frame.MouseWheelForward:Connect(function()
        targetPosition = math.max(0, targetPosition - 80);
    end));
    
    table.insert(connections, frame.MouseWheelBackward:Connect(function()
        targetPosition = math.min(frame.CanvasSize.Y.Offset - frame.AbsoluteSize.Y, targetPosition + 80);
    end));
    
    frame:GetPropertyChangedSignal("CanvasSize"):Connect(function()
        frame.CanvasPosition = Vector2.new(0, math.min(frame.CanvasSize.Y.Offset, frame.CanvasPosition.Y));
        targetPosition = frame.CanvasPosition.Y;
    end);
    
    return frame;
end

-- Create a blurred effect behind a frame (glass-like)
function ui.addBlurEffect(frame, blurSize)
    blurSize = blurSize or 10;
    
    local blur = ui.create("BlurEffect", {
        Name = "Blur",
        Size = blurSize,
        Parent = frame
    });
    
    return blur;
end

-- Create a rounded button with click effect
function ui.createButton(properties)
    local textColor = properties.TextColor3 or Color3.fromRGB(240, 240, 240);
    local bgColor = properties.BackgroundColor3 or Color3.fromRGB(128, 64, 255);
    local hoverColor = properties.HoverColor or Color3.fromRGB(160, 100, 255);
    local pressColor = properties.PressColor or Color3.fromRGB(100, 50, 200);
    
    local button = ui.create("TextButton", {
        Text = properties.Text or "",
        TextColor3 = textColor,
        TextSize = properties.TextSize or 14,
        Font = properties.Font or Enum.Font.Gotham,
        BackgroundColor3 = bgColor,
        BorderSizePixel = 0,
        Size = properties.Size or UDim2.new(0, 100, 0, 30),
        Position = properties.Position or UDim2.new(0, 0, 0, 0),
        Parent = properties.Parent,
        ZIndex = properties.ZIndex or 1,
        AutoButtonColor = false
    });
    
    ui.create("UICorner", {
        CornerRadius = UDim.new(0, properties.Radius or 6),
        Parent = button
    });
    
    button.MouseEnter:Connect(function()
        button.BackgroundColor3 = hoverColor;
    end);
    
    button.MouseLeave:Connect(function()
        button.BackgroundColor3 = bgColor;
    end);
    
    button.MouseButton1Down:Connect(function()
        button.BackgroundColor3 = pressColor;
    end);
    
    button.MouseButton1Up:Connect(function()
        button.BackgroundColor3 = hoverColor;
    end);
    
    if properties.RippleEffect then
        local loadstring = getfenv().loadstring;
        local animate = loadstring(game:HttpGet("https://raw.githubusercontent.com/testing2122/RobloxNeonIDE/main/src/utils/animate.lua"))();
        animate.ripple(button, Color3.fromRGB(255, 255, 255), 0.5);
    end
    
    return button;
end

-- Create a toggle button
function ui.createToggle(properties)
    local enabled = properties.Enabled or false;
    local bgColor = properties.BackgroundColor3 or Color3.fromRGB(60, 60, 70);
    local toggleColor = properties.ToggleColor or Color3.fromRGB(128, 64, 255);
    
    local toggle = ui.create("Frame", {
        Name = "Toggle",
        Size = properties.Size or UDim2.new(0, 40, 0, 20),
        Position = properties.Position or UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = enabled and toggleColor or bgColor,
        BorderSizePixel = 0,
        Parent = properties.Parent,
        ZIndex = properties.ZIndex or 1
    });
    
    ui.create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = toggle
    });
    
    local toggleButton = ui.create("Frame", {
        Name = "Button",
        Size = UDim2.new(0, 16, 0, 16),
        Position = enabled and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = Color3.fromRGB(255, 255, 255),
        BorderSizePixel = 0,
        Parent = toggle,
        ZIndex = properties.ZIndex and properties.ZIndex + 1 or 2
    });
    
    ui.create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = toggleButton
    });
    
    local clickRegion = ui.create("TextButton", {
        Name = "ClickRegion",
        Text = "",
        BackgroundTransparency = 1,
        Size = UDim2.new(1, 0, 1, 0),
        ZIndex = properties.ZIndex and properties.ZIndex + 2 or 3,
        Parent = toggle
    });
    
    local loadstring = getfenv().loadstring;
    local animate = loadstring(game:HttpGet("https://raw.githubusercontent.com/testing2122/RobloxNeonIDE/main/src/utils/animate.lua"))();
    
    local function updateToggle(newState)
        enabled = newState;
        
        animate.tween(toggle, {
            BackgroundColor3 = enabled and toggleColor or bgColor
        }, 0.2, "easeInOutQuad");
        
        animate.tween(toggleButton, {
            Position = enabled and UDim2.new(1, -18, 0.5, 0) or UDim2.new(0, 2, 0.5, 0)
        }, 0.2, "easeOutBack");
        
        if properties.Callback then
            properties.Callback(enabled);
        end
    end
    
    clickRegion.MouseButton1Click:Connect(function()
        updateToggle(not enabled);
    end);
    
    local toggleObject = {
        instance = toggle,
        button = toggleButton,
        isEnabled = function()
            return enabled;
        end,
        setEnabled = function(state)
            updateToggle(state);
        end,
        toggle = function()
            updateToggle(not enabled);
        end
    };
    
    return toggleObject;
end

-- Create a simple toast notification
function ui.showToast(text, parent, duration, color)
    duration = duration or 3;
    color = color or Color3.fromRGB(50, 50, 60);
    
    local screenGui = parent or (gethui and gethui() or game:GetService("CoreGui"));
    
    local toast = ui.create("Frame", {
        Name = "Toast",
        Size = UDim2.new(0, 300, 0, 40),
        Position = UDim2.new(0.5, 0, 0.9, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundColor3 = color,
        BorderSizePixel = 0,
        Parent = screenGui,
        ZIndex = 10
    });
    
    ui.create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = toast
    });
    
    ui.create("TextLabel", {
        Name = "Text",
        Text = text,
        Size = UDim2.new(1, -20, 1, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        TextColor3 = Color3.fromRGB(240, 240, 240),
        TextSize = 14,
        Font = Enum.Font.Gotham,
        Parent = toast,
        ZIndex = 11
    });
    
    ui.addGlowEffect(toast, Color3.fromRGB(128, 64, 255), 20, 0.9);
    
    local loadstring = getfenv().loadstring;
    local animate = loadstring(game:HttpGet("https://raw.githubusercontent.com/testing2122/RobloxNeonIDE/main/src/utils/animate.lua"))();
    
    -- Animate in
    toast.Position = UDim2.new(0.5, 0, 1.1, 0);
    animate.spring(toast, {
        Position = UDim2.new(0.5, 0, 0.9, 0),
    }, 0.5, "easeOutBack");
    
    -- Animate out
    delay(duration, function()
        animate.spring(toast, {
            Position = UDim2.new(0.5, 0, 1.1, 0),
        }, 0.4, "easeInBack", function()
            toast:Destroy();
        end);
    end);
    
    return toast;
end

-- Create a dropdown menu
function ui.createDropdown(properties)
    local options = properties.Options or {};
    local selected = properties.Selected or options[1] or "";
    local width = properties.Width or 150;
    local height = properties.Height or 30;
    local dropdownColor = properties.BackgroundColor3 or Color3.fromRGB(40, 40, 50);
    local accentColor = properties.AccentColor or Color3.fromRGB(128, 64, 255);
    local textColor = properties.TextColor3 or Color3.fromRGB(240, 240, 240);
    
    local dropdown = ui.create("Frame", {
        Name = "Dropdown",
        Size = UDim2.new(0, width, 0, height),
        Position = properties.Position or UDim2.new(0, 0, 0, 0),
        BackgroundColor3 = dropdownColor,
        BorderSizePixel = 0,
        Parent = properties.Parent,
        ClipsDescendants = true,
        ZIndex = properties.ZIndex or 1
    });
    
    ui.create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = dropdown
    });
    
    local header = ui.create("TextButton", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, height),
        BackgroundTransparency = 1,
        Text = selected,
        TextColor3 = textColor,
        TextSize = 14,
        Font = Enum.Font.Gotham,
        Parent = dropdown,
        ZIndex = properties.ZIndex and properties.ZIndex + 1 or 2
    });
    
    local arrow = ui.create("ImageLabel", {
        Name = "Arrow",
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(1, -20, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://7072706663", -- Arrow icon
        ImageColor3 = accentColor,
        Rotation = 0,
        Parent = header,
        ZIndex = properties.ZIndex and properties.ZIndex + 2 or 3
    });
    
    local optionContainer = ui.create("Frame", {
        Name = "OptionContainer",
        Size = UDim2.new(1, 0, 0, 0),
        Position = UDim2.new(0, 0, 0, height),
        BackgroundColor3 = dropdownColor,
        BackgroundTransparency = 0.2,
        BorderSizePixel = 0,
        Parent = dropdown,
        ClipsDescendants = true,
        ZIndex = properties.ZIndex and properties.ZIndex + 3 or 4
    });
    
    ui.create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = optionContainer
    });
    
    local loadstring = getfenv().loadstring;
    local animate = loadstring(game:HttpGet("https://raw.githubusercontent.com/testing2122/RobloxNeonIDE/main/src/utils/animate.lua"))();
    
    local isOpen = false;
    local optionHeight = 30;
    local optionButtons = {};
    
    -- Create option buttons
    for i, option in ipairs(options) do
        local optionButton = ui.create("TextButton", {
            Name = "Option_" .. option,
            Size = UDim2.new(1, 0, 0, optionHeight),
            Position = UDim2.new(0, 0, 0, (i-1) * optionHeight),
            BackgroundTransparency = 1,
            Text = option,
            TextColor3 = textColor,
            TextSize = 14,
            Font = Enum.Font.Gotham,
            Parent = optionContainer,
            ZIndex = properties.ZIndex and properties.ZIndex + 4 or 5
        });
        
        optionButton.MouseEnter:Connect(function()
            animate.tween(optionButton, {
                BackgroundTransparency = 0.7,
                BackgroundColor3 = accentColor
            }, 0.2, "easeOutQuad");
        end);
        
        optionButton.MouseLeave:Connect(function()
            animate.tween(optionButton, {
                BackgroundTransparency = 1
            }, 0.2, "easeOutQuad");
        end);
        
        optionButton.MouseButton1Click:Connect(function()
            selected = option;
            header.Text = selected;
            
            if properties.Callback then
                properties.Callback(selected);
            end
            
            toggleDropdown();
        end);
        
        table.insert(optionButtons, optionButton);
    end
    
    local function toggleDropdown()
        isOpen = not isOpen;
        
        animate.tween(arrow, {
            Rotation = isOpen and 180 or 0
        }, 0.3, "easeInOutQuad");
        
        animate.tween(optionContainer, {
            Size = UDim2.new(1, 0, 0, isOpen and optionHeight * #options or 0)
        }, 0.3, "easeInOutQuad");
        
        animate.tween(dropdown, {
            Size = UDim2.new(0, width, 0, isOpen and height + (optionHeight * #options) or height)
        }, 0.3, "easeInOutQuad");
    end
    
    header.MouseButton1Click:Connect(toggleDropdown);
    
    local dropdownObject = {
        instance = dropdown,
        getSelected = function()
            return selected;
        end,
        setSelected = function(option)
            if table.find(options, option) then
                selected = option;
                header.Text = selected;
                
                if properties.Callback then
                    properties.Callback(selected);
                end
            end
        end,
        setOptions = function(newOptions)
            options = newOptions;
            
            -- Clear current options
            for _, button in ipairs(optionButtons) do
                button:Destroy();
            end
            optionButtons = {};
            
            -- Create new options
            for i, option in ipairs(options) do
                local optionButton = ui.create("TextButton", {
                    Name = "Option_" .. option,
                    Size = UDim2.new(1, 0, 0, optionHeight),
                    Position = UDim2.new(0, 0, 0, (i-1) * optionHeight),
                    BackgroundTransparency = 1,
                    Text = option,
                    TextColor3 = textColor,
                    TextSize = 14,
                    Font = Enum.Font.Gotham,
                    Parent = optionContainer,
                    ZIndex = properties.ZIndex and properties.ZIndex + 4 or 5
                });
                
                optionButton.MouseEnter:Connect(function()
                    animate.tween(optionButton, {
                        BackgroundTransparency = 0.7,
                        BackgroundColor3 = accentColor
                    }, 0.2, "easeOutQuad");
                end);
                
                optionButton.MouseLeave:Connect(function()
                    animate.tween(optionButton, {
                        BackgroundTransparency = 1
                    }, 0.2, "easeOutQuad");
                end);
                
                optionButton.MouseButton1Click:Connect(function()
                    selected = option;
                    header.Text = selected;
                    
                    if properties.Callback then
                        properties.Callback(selected);
                    end
                    
                    toggleDropdown();
                end);
                
                table.insert(optionButtons, optionButton);
            end
            
            if isOpen then
                optionContainer.Size = UDim2.new(1, 0, 0, optionHeight * #options);
                dropdown.Size = UDim2.new(0, width, 0, height + (optionHeight * #options));
            end
        end,
        toggle = toggleDropdown
    };
    
    return dropdownObject;
end

return ui;