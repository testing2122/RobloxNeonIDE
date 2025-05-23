local tabSystem = {};
tabSystem.__index = tabSystem;

local function getUtils()
    local loadstring = getfenv().loadstring;
    return {
        ui = loadstring(game:HttpGet("https://raw.githubusercontent.com/testing2122/RobloxNeonIDE/main/src/utils/ui.lua"))(),
        animate = loadstring(game:HttpGet("https://raw.githubusercontent.com/testing2122/RobloxNeonIDE/main/src/utils/animate.lua"))()
    };
end

function tabSystem.new(parent)
    local utils = getUtils();
    local self = setmetatable({}, tabSystem);
    
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
    
    self.tabs = {};
    self.activeTab = nil;
    self.onTabChanged = nil;
    
    return self;
end

function tabSystem:mount(parent)
    local utils = getUtils();
    
    self.container = utils.ui.create("Frame", {
        Name = "TabSystem",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Parent = parent
    });
    
    -- Tab bar
    self.tabBar = utils.ui.create("Frame", {
        Name = "TabBar",
        Size = UDim2.new(1, 0, 0, 32),
        BackgroundColor3 = self.theme.BACKGROUND_SECONDARY,
        BorderSizePixel = 0,
        Parent = self.container
    });
    
    utils.ui.create("UIStroke", {
        Color = self.theme.BORDER,
        Thickness = 1,
        ApplyStrokeMode = Enum.ApplyStrokeMode.Border,
        Parent = self.tabBar
    });
    
    -- Tab list layout
    self.tabList = utils.ui.create("Frame", {
        Name = "TabList",
        Size = UDim2.new(1, -40, 1, 0),
        BackgroundTransparency = 1,
        Parent = self.tabBar
    });
    
    utils.ui.create("UIListLayout", {
        FillDirection = Enum.FillDirection.Horizontal,
        SortOrder = Enum.SortOrder.LayoutOrder,
        Padding = UDim.new(0, 2),
        Parent = self.tabList
    });
    
    -- New tab button
    self.newTabButton = utils.ui.create("TextButton", {
        Name = "NewTab",
        Size = UDim2.new(0, 32, 0, 32),
        Position = UDim2.new(1, 0, 0, 0),
        AnchorPoint = Vector2.new(1, 0),
        BackgroundTransparency = 1,
        Text = "+",
        TextSize = 22,
        Font = Enum.Font.GothamBold,
        TextColor3 = self.theme.TEXT_SECONDARY,
        Parent = self.tabBar
    });
    
    -- Hover effect for new tab button
    self.newTabButton.MouseEnter:Connect(function()
        utils.animate.tween(self.newTabButton, {TextColor3 = self.theme.TEXT_PRIMARY}, 0.2, "easeOut");
    end);
    
    self.newTabButton.MouseLeave:Connect(function()
        utils.animate.tween(self.newTabButton, {TextColor3 = self.theme.TEXT_SECONDARY}, 0.2, "easeOut");
    end);
    
    -- Content area
    self.contentArea = utils.ui.create("Frame", {
        Name = "ContentArea",
        Size = UDim2.new(1, 0, 1, -32),
        Position = UDim2.new(0, 0, 0, 32),
        BackgroundTransparency = 1,
        Parent = self.container
    });
    
    -- Event for new tab button
    self.newTabButton.MouseButton1Click:Connect(function()
        self:addTab("New Tab", "");
    end);
    
    return self;
end

function tabSystem:createTab(title, content)
    local utils = getUtils();
    
    -- Tab button
    local tab = utils.ui.create("Frame", {
        Name = "Tab_" .. title,
        Size = UDim2.new(0, 0, 1, 0), -- Will be auto-sized
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundColor3 = self.theme.BACKGROUND,
        BorderSizePixel = 0,
        LayoutOrder = #self.tabs + 1,
        Parent = self.tabList
    });
    
    -- Top accent bar for active tabs
    local accentBar = utils.ui.create("Frame", {
        Name = "AccentBar",
        Size = UDim2.new(1, 0, 0, 2),
        BackgroundColor3 = self.theme.ACCENT,
        BorderSizePixel = 0,
        Visible = false, -- Only shown when active
        ZIndex = 2,
        Parent = tab
    });
    
    -- Tab title
    local tabTitle = utils.ui.create("TextLabel", {
        Name = "Title",
        Size = UDim2.new(0, 0, 1, 0),
        AutomaticSize = Enum.AutomaticSize.X,
        BackgroundTransparency = 1,
        Font = Enum.Font.Gotham,
        Text = title,
        TextColor3 = self.theme.TEXT_SECONDARY,
        TextSize = 14,
        Parent = tab
    });
    
    utils.ui.create("UIPadding", {
        PaddingLeft = UDim.new(0, 10),
        PaddingRight = UDim.new(0, 30),
        Parent = tabTitle
    });
    
    -- Close button
    local closeButton = utils.ui.create("TextButton", {
        Name = "Close",
        Size = UDim2.new(0, 16, 0, 16),
        Position = UDim2.new(1, -8, 0.5, 0),
        AnchorPoint = Vector2.new(1, 0.5),
        BackgroundTransparency = 1,
        Text = "×",
        TextSize = 16,
        Font = Enum.Font.GothamBold,
        TextColor3 = self.theme.TEXT_SECONDARY,
        Parent = tab
    });
    
    -- Make tab clickable
    local tabButton = utils.ui.create("TextButton", {
        Name = "Button",
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Text = "",
        ZIndex = 3,
        Parent = tab
    });
    
    -- Create content frame
    local contentFrame = utils.ui.create("Frame", {
        Name = "Content_" .. title,
        Size = UDim2.new(1, 0, 1, 0),
        BackgroundTransparency = 1,
        Visible = false,
        Parent = self.contentArea
    });
    
    -- Tab events
    tabButton.MouseButton1Click:Connect(function()
        self:selectTab(title);
    end);
    
    closeButton.MouseButton1Click:Connect(function()
        self:removeTab(title);
    end);
    
    -- Hover effects
    tabButton.MouseEnter:Connect(function()
        if self.activeTab ~= title then
            utils.animate.tween(tab, {BackgroundColor3 = self.theme.BACKGROUND_SECONDARY}, 0.2, "easeOut");
            utils.animate.tween(tabTitle, {TextColor3 = self.theme.TEXT_PRIMARY}, 0.2, "easeOut");
        end
    end);
    
    tabButton.MouseLeave:Connect(function()
        if self.activeTab ~= title then
            utils.animate.tween(tab, {BackgroundColor3 = self.theme.BACKGROUND}, 0.2, "easeOut");
            utils.animate.tween(tabTitle, {TextColor3 = self.theme.TEXT_SECONDARY}, 0.2, "easeOut");
        end
    end);
    
    closeButton.MouseEnter:Connect(function()
        utils.animate.tween(closeButton, {TextColor3 = self.theme.ERROR}, 0.2, "easeOut");
    end);
    
    closeButton.MouseLeave:Connect(function()
        utils.animate.tween(closeButton, {TextColor3 = self.theme.TEXT_SECONDARY}, 0.2, "easeOut");
    end);
    
    -- Store tab data
    local tabData = {
        title = title,
        content = content,
        button = tab,
        contentFrame = contentFrame,
        titleLabel = tabTitle,
        accentBar = accentBar
    };
    
    table.insert(self.tabs, tabData);
    
    return tabData;
end

function tabSystem:addTab(title, content)
    local tabData = self:createTab(title, content);
    
    -- If this is the first tab, select it
    if #self.tabs == 1 then
        self:selectTab(title);
    end
    
    -- Create a code editor for the content if needed
    if content ~= nil then
        local loadstring = getfenv().loadstring;
        local codeEditor = loadstring(game:HttpGet("https://raw.githubusercontent.com/testing2122/RobloxNeonIDE/main/src/components/codeeditor.lua"))();
        local editor = codeEditor.new(self);
        
        editor:mount(tabData.contentFrame);
        editor:setCode(content);
        
        tabData.editor = editor;
    end
    
    return tabData;
end

function tabSystem:selectTab(title)
    local utils = getUtils();
    
    -- Find the tab data
    local selectedTab = nil;
    
    for _, tab in ipairs(self.tabs) do
        if tab.title == title then
            selectedTab = tab;
            break;
        end
    end
    
    if not selectedTab then return; end
    
    -- Deactivate current active tab
    if self.activeTab then
        for _, tab in ipairs(self.tabs) do
            if tab.title == self.activeTab then
                utils.animate.tween(tab.button, {BackgroundColor3 = self.theme.BACKGROUND}, 0.2, "easeOut");
                utils.animate.tween(tab.titleLabel, {TextColor3 = self.theme.TEXT_SECONDARY}, 0.2, "easeOut");
                tab.accentBar.Visible = false;
                tab.contentFrame.Visible = false;
                break;
            end
        end
    end
    
    -- Activate the selected tab
    utils.animate.tween(selectedTab.button, {BackgroundColor3 = self.theme.BACKGROUND_SECONDARY}, 0.2, "easeOut");
    utils.animate.tween(selectedTab.titleLabel, {TextColor3 = self.theme.ACCENT}, 0.2, "easeOut");
    selectedTab.accentBar.Visible = true;
    selectedTab.contentFrame.Visible = true;
    
    -- Update the active tab
    self.activeTab = title;
    
    -- Call the callback if set
    if self.onTabChanged then
        self.onTabChanged(selectedTab);
    end
    
    return self;
end

function tabSystem:removeTab(title)
    local utils = getUtils();
    
    -- Find the tab index
    local tabIndex = nil;
    
    for i, tab in ipairs(self.tabs) do
        if tab.title == title then
            tabIndex = i;
            break;
        end
    end
    
    if not tabIndex then return; end
    
    local tabData = self.tabs[tabIndex];
    
    -- Animate tab removal
    utils.animate.spring(tabData.button, {
        Size = UDim2.new(0, 0, 1, 0)
    }, 0.2, "easeInQuad", function()
        tabData.button:Destroy();
        tabData.contentFrame:Destroy();
        
        -- Remove from the tabs array
        table.remove(self.tabs, tabIndex);
        
        -- Update layout orders for remaining tabs
        for i, tab in ipairs(self.tabs) do
            tab.button.LayoutOrder = i;
        end
        
        -- If this was the active tab, select another tab
        if self.activeTab == title then
            self.activeTab = nil;
            if #self.tabs > 0 then
                self:selectTab(self.tabs[math.min(tabIndex, #self.tabs)].title);
            end
        end
    end);
    
    return self;
end

function tabSystem:getTabContent(title)
    for _, tab in ipairs(self.tabs) do
        if tab.title == title then
            if tab.editor then
                return tab.editor:getCode();
            end
            return tab.content;
        end
    end
    
    return nil;
end

function tabSystem:setTabContent(title, content)
    for _, tab in ipairs(self.tabs) do
        if tab.title == title then
            tab.content = content;
            if tab.editor then
                tab.editor:setCode(content);
            end
            return true;
        end
    end
    
    return false;
end

function tabSystem:renameTab(oldTitle, newTitle)
    for _, tab in ipairs(self.tabs) do
        if tab.title == oldTitle then
            tab.title = newTitle;
            tab.titleLabel.Text = newTitle;
            tab.button.Name = "Tab_" .. newTitle;
            tab.contentFrame.Name = "Content_" .. newTitle;
            
            if self.activeTab == oldTitle then
                self.activeTab = newTitle;
            end
            
            return true;
        end
    end
    
    return false;
end

function tabSystem:clear()
    for _, tab in ipairs(self.tabs) do
        tab.button:Destroy();
        tab.contentFrame:Destroy();
    end
    
    self.tabs = {};
    self.activeTab = nil;
    
    return self;
end

return tabSystem;