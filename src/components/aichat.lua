local aiChat = {};
aiChat.__index = aiChat;

local function getUtils()
    local loadstring = getfenv().loadstring;
    return {
        ui = loadstring(game:HttpGet("https://raw.githubusercontent.com/testing2122/RobloxNeonIDE/main/src/utils/ui.lua"))(),
        animate = loadstring(game:HttpGet("https://raw.githubusercontent.com/testing2122/RobloxNeonIDE/main/src/utils/animate.lua"))()
    };
end

function aiChat.new(parent)
    local utils = getUtils();
    local self = setmetatable({}, aiChat);
    
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
    
    self.messages = {};
    self.isTyping = false;
    
    return self;
end

function aiChat:mount(parent)
    local utils = getUtils();
    
    self.container = utils.ui.create("Frame", {
        Name = "AIChat",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundColor3 = self.theme.BACKGROUND_SECONDARY,
        BorderSizePixel = 0,
        Parent = parent
    });
    
    -- Chat header
    self.header = utils.ui.create("Frame", {
        Name = "Header",
        Size = UDim2.new(1, 0, 0, 40),
        BackgroundColor3 = self.theme.BACKGROUND_SECONDARY,
        BorderSizePixel = 0,
        Parent = self.container
    });
    
    utils.ui.create("UIStroke", {
        Color = self.theme.BORDER,
        Thickness = 1,
        Parent = self.header
    });
    
    self.headerTitle = utils.ui.create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.GothamBold,
        Text = "AI Assistant",
        TextColor3 = self.theme.ACCENT,
        TextSize = 16,
        Parent = self.header
    });
    
    -- Create AI avatar
    self.avatar = utils.ui.create("ImageLabel", {
        Name = "Avatar",
        Size = UDim2.new(0, 24, 0, 24),
        Position = UDim2.new(0, 10, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = self.theme.ACCENT,
        BorderSizePixel = 0,
        Image = "rbxassetid://11717273791", -- Robot/AI icon
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        Parent = self.header
    });
    
    utils.ui.create("UICorner", {
        CornerRadius = UDim.new(0.5, 0),
        Parent = self.avatar
    });
    
    utils.ui.create("UIStroke", {
        Color = self.theme.ACCENT,
        Thickness = 2,
        Parent = self.avatar
    });
    
    -- AI status indicator (online/typing)
    self.statusIndicator = utils.ui.create("Frame", {
        Name = "StatusIndicator",
        Size = UDim2.new(0, 8, 0, 8),
        Position = UDim2.new(1, -2, 1, -2),
        AnchorPoint = Vector2.new(1, 1),
        BackgroundColor3 = self.theme.SUCCESS,
        BorderSizePixel = 0,
        Parent = self.avatar
    });
    
    utils.ui.create("UICorner", {
        CornerRadius = UDim.new(1, 0),
        Parent = self.statusIndicator
    });
    
    utils.ui.addGlowEffect(self.statusIndicator, self.theme.SUCCESS, 6, 0.7);
    
    -- Chat messages
    self.chatFrame = utils.ui.createSmoothScrollFrame({
        Name = "ChatFrame",
        Size = UDim2.new(1, 0, 1, -100), -- Minus header and input area
        Position = UDim2.new(0, 0, 0, 40),
        CanvasSize = UDim2.new(0, 0, 0, 0),
        ScrollBarThickness = 3,
        Smoothness = 0.1,
        Parent = self.container
    });
    
    utils.ui.create("UIListLayout", {
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 10),
        Parent = self.chatFrame
    });
    
    utils.ui.create("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        Parent = self.chatFrame
    });
    
    -- Input area
    self.inputArea = utils.ui.create("Frame", {
        Name = "InputArea",
        Size = UDim2.new(1, 0, 0, 60),
        Position = UDim2.new(0, 0, 1, 0),
        AnchorPoint = Vector2.new(0, 1),
        BackgroundColor3 = self.theme.BACKGROUND_SECONDARY,
        BorderSizePixel = 0,
        Parent = self.container
    });
    
    utils.ui.create("UIStroke", {
        Color = self.theme.BORDER,
        Thickness = 1,
        Parent = self.inputArea
    });
    
    self.inputBox = utils.ui.create("TextBox", {
        Name = "InputBox",
        Size = UDim2.new(1, -70, 1, -20),
        Position = UDim2.new(0, 10, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = self.theme.BACKGROUND,
        Font = Enum.Font.Gotham,
        PlaceholderText = "Ask the AI assistant...",
        PlaceholderColor3 = self.theme.TEXT_SECONDARY,
        Text = "",
        TextColor3 = self.theme.TEXT_PRIMARY,
        TextSize = 14,
        TextTruncate = Enum.TextTruncate.AtEnd,
        TextXAlignment = Enum.TextXAlignment.Left,
        BorderSizePixel = 0,
        Parent = self.inputArea
    });
    
    utils.ui.create("UICorner", {
        CornerRadius = UDim.new(0, 6),
        Parent = self.inputBox
    });
    
    utils.ui.create("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        Parent = self.inputBox
    });
    
    -- Send button
    self.sendButton = utils.ui.createButton({
        Text = "",
        Size = UDim2.new(0, 40, 0, 40),
        Position = UDim2.new(1, -50, 0.5, 0),
        AnchorPoint = Vector2.new(0, 0.5),
        BackgroundColor3 = self.theme.ACCENT,
        Radius = 6,
        RippleEffect = true,
        Parent = self.inputArea
    });
    
    -- Send icon
    self.sendIcon = utils.ui.create("ImageLabel", {
        Name = "SendIcon",
        Size = UDim2.new(0, 20, 0, 20),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Image = "rbxassetid://6035067836", -- Send icon
        ImageColor3 = Color3.fromRGB(255, 255, 255),
        Parent = self.sendButton
    });
    
    -- Initial welcome message
    self:addInitialMessages();
    
    -- Setup events
    self:setupEvents();
    
    return self;
end

function aiChat:addInitialMessages()
    self:addMessage("ai", "Hello! I'm your AI assistant. How can I help you with your coding today?");
end

function aiChat:setupEvents()
    local utils = getUtils();
    
    -- Send message on button click
    self.sendButton.MouseButton1Click:Connect(function()
        self:sendMessage();
    });
    
    -- Send message on Enter key (without shift)
    self.inputBox.FocusLost:Connect(function(enterPressed)
        if enterPressed then
            self:sendMessage();
        end
    end);
    
    -- Animate the avatar to indicate the AI is online
    spawn(function()
        utils.animate.glow(self.statusIndicator, 0.3, 1.5, 2);
    end);
end

function aiChat:createMessageBubble(author, text)
    local utils = getUtils();
    local isAI = author == "ai";
    
    local bubble = utils.ui.create("Frame", {
        Name = author .. "_Message",
        Size = UDim2.new(0.9, 0, 0, 0), -- Auto size
        BackgroundColor3 = isAI and self.theme.BACKGROUND or self.theme.ACCENT_DARK,
        AutomaticSize = Enum.AutomaticSize.Y,
        BorderSizePixel = 0,
        Parent = self.chatFrame
    });
    
    utils.ui.create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = bubble
    });
    
    if isAI then
        utils.ui.create("UIStroke", {
            Color = self.theme.BORDER,
            Thickness = 1,
            Parent = bubble
        });
    end
    
    -- Position the bubble on the left (AI) or right (user)
    bubble.Position = isAI 
        and UDim2.new(0, 0, 0, 0) 
        or UDim2.new(1, 0, 0, 0);
    
    bubble.AnchorPoint = isAI 
        and Vector2.new(0, 0) 
        or Vector2.new(1, 0);
    
    local messageText = utils.ui.create("TextLabel", {
        Name = "Text",
        Size = UDim2.new(1, 0, 0, 0),
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = text,
        TextColor3 = self.theme.TEXT_PRIMARY,
        TextSize = 14,
        TextWrapped = true,
        TextXAlignment = Enum.TextXAlignment.Left,
        TextYAlignment = Enum.TextYAlignment.Top,
        AutomaticSize = Enum.AutomaticSize.Y,
        Parent = bubble
    });
    
    utils.ui.create("UIPadding", {
        PaddingTop = UDim.new(0, 10),
        PaddingBottom = UDim.new(0, 10),
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 10),
        Parent = bubble
    });
    
    -- Add a subtle glow for AI messages
    if isAI then
        utils.ui.addGlowEffect(bubble, self.theme.ACCENT, 15, 0.93);
    end
    
    -- Animate the bubble appearing
    bubble.BackgroundTransparency = 1;
    messageText.TextTransparency = 1;
    
    utils.animate.spring(bubble, {
        BackgroundTransparency = 0
    }, 0.3, "easeOutQuad");
    
    utils.animate.spring(messageText, {
        TextTransparency = 0
    }, 0.3, "easeOutQuad");
    
    -- Add to messages list
    table.insert(self.messages, {
        author = author,
        text = text,
        bubble = bubble
    });
    
    -- Update canvas size
    self:updateCanvasSize();
    
    -- Scroll to bottom
    self:scrollToBottom();
    
    return bubble, messageText;
end

function aiChat:addMessage(author, text)
    return self:createMessageBubble(author, text);
end

function aiChat:addTypingIndicator()
    local utils = getUtils();
    
    -- Remove previous typing indicator if exists
    self:removeTypingIndicator();
    
    -- Create new typing indicator
    self.typingIndicator = utils.ui.create("Frame", {
        Name = "TypingIndicator",
        Size = UDim2.new(0.3, 0, 0, 40),
        BackgroundColor3 = self.theme.BACKGROUND,
        BorderSizePixel = 0,
        Parent = self.chatFrame
    });
    
    utils.ui.create("UICorner", {
        CornerRadius = UDim.new(0, 8),
        Parent = self.typingIndicator
    });
    
    utils.ui.create("UIStroke", {
        Color = self.theme.BORDER,
        Thickness = 1,
        Parent = self.typingIndicator
    });
    
    -- Dots container
    local dots = utils.ui.create("Frame", {
        Name = "Dots",
        Size = UDim2.new(0.3, 0, 0.5, 0),
        Position = UDim2.new(0.5, 0, 0.5, 0),
        AnchorPoint = Vector2.new(0.5, 0.5),
        BackgroundTransparency = 1,
        Parent = self.typingIndicator
    });
    
    -- Create the typing dots
    for i = 1, 3 do
        local dot = utils.ui.create("Frame", {
            Name = "Dot" .. i,
            Size = UDim2.new(0, 8, 0, 8),
            Position = UDim2.new((i - 1) / 2, 0, 0.5, 0),
            AnchorPoint = Vector2.new(0, 0.5),
            BackgroundColor3 = self.theme.ACCENT,
            BorderSizePixel = 0,
            Parent = dots
        });
        
        utils.ui.create("UICorner", {
            CornerRadius = UDim.new(1, 0),
            Parent = dot
        });
        
        -- Animate each dot with a delay
        spawn(function()
            while self.typingIndicator and self.typingIndicator.Parent do
                utils.animate.spring(dot, {
                    Position = UDim2.new((i - 1) / 2, 0, 0.5, -10)
                }, 0.5, "easeOutQuad");
                
                wait(0.1);
                
                utils.animate.spring(dot, {
                    Position = UDim2.new((i - 1) / 2, 0, 0.5, 0)
                }, 0.5, "easeOutElastic");
                
                wait(0.6 + (i * 0.1));
            end
        end);
    end
    
    self.isTyping = true;
    self:updateCanvasSize();
    self:scrollToBottom();
    
    return self.typingIndicator;
end

function aiChat:removeTypingIndicator()
    if self.typingIndicator then
        self.typingIndicator:Destroy();
        self.typingIndicator = nil;
    end
    
    self.isTyping = false;
    return self;
end

function aiChat:updateCanvasSize()
    local contentHeight = 0;
    local padding = 10;
    
    -- Calculate content height
    for _, message in ipairs(self.messages) do
        contentHeight = contentHeight + message.bubble.AbsoluteSize.Y + padding;
    end
    
    -- Add typing indicator height if active
    if self.isTyping and self.typingIndicator then
        contentHeight = contentHeight + self.typingIndicator.AbsoluteSize.Y + padding;
    end
    
    -- Set canvas size
    self.chatFrame.CanvasSize = UDim2.new(0, 0, 0, contentHeight);
    
    return self;
end

function aiChat:scrollToBottom()
    local utils = getUtils();
    
    wait(); -- Wait for the next frame for sizes to update
    
    local canvasHeight = self.chatFrame.CanvasSize.Y.Offset;
    local containerHeight = self.chatFrame.AbsoluteSize.Y;
    
    if canvasHeight > containerHeight then
        self.chatFrame.CanvasPosition = Vector2.new(0, canvasHeight - containerHeight);
    end
    
    return self;
end

function aiChat:simulateTyping(text, callback)
    local utils = getUtils();
    
    -- Show typing indicator
    self:addTypingIndicator();
    
    -- Simulate AI thinking time
    local thinkingTime = math.max(1, math.min(#text / 80, 3));
    wait(thinkingTime);
    
    -- Add message and remove typing indicator
    self:removeTypingIndicator();
    local bubble, messageText = self:addMessage("ai", "");
    
    -- Simulate typing animation
    utils.animate.typing(messageText, text, 0.01);
    
    if callback then
        callback();
    end
    
    return self;
end

function aiChat:sendMessage()
    local utils = getUtils();
    local text = self.inputBox.Text;
    
    if text == "" then
        return self;
    end
    
    -- Add user message
    self:addMessage("user", text);
    
    -- Clear input
    self.inputBox.Text = "";
    
    -- Process the message (in a real app, this would call an API)
    self:processMessage(text);
    
    return self;
end

function aiChat:processMessage(text)
    local utils = getUtils();
    
    -- Basic responses for demonstration
    local responses = {
        ["hello"] = "Hello there! How can I assist you with your coding today?",
        ["hi"] = "Hi! What would you like help with?",
        ["help"] = "I can help you with code examples, debugging, or explaining programming concepts. What do you need assistance with?",
        ["code"] = "Would you like me to generate some example code for you? Let me know what language and functionality you need.",
        ["lua"] = "Lua is a lightweight, high-level scripting language designed primarily for embedded use in applications. It's widely used in game development, especially in Roblox!",
        ["thanks"] = "You're welcome! Feel free to ask if you need anything else.",
        ["thank you"] = "You're welcome! Is there anything else I can help with?",
    };
    
    -- Find a response or use default
    local response = nil;
    local lowerText = text:lower();
    
    for keyword, resp in pairs(responses) do
        if lowerText:find(keyword) then
            response = resp;
            break;
        end
    end
    
    -- Default response if no match
    if not response then
        response = "I'm here to help with your coding questions. Could you provide more details about what you're working on?";
    end
    
    -- Simulate typing response
    self:simulateTyping(response);
    
    return self;
end

return aiChat;