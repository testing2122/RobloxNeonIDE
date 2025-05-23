--[[
    NeonIDE Example Usage
    
    This script demonstrates how to load and use the NeonIDE library
    in a Roblox exploit environment.
    
    The example shows:
    1. How to load the library using HttpGet
    2. Creating and configuring the IDE
    3. Adding tabs with example code
    4. Creating UI themes
    
    This library provides a full-featured code editor with AI assistance
    and can be used as a development tool within Roblox exploits.
]]

-- Load the library using the direct GitHub URL
local NeonIDE = loadstring(game:HttpGet("https://raw.githubusercontent.com/testing2122/RobloxNeonIDE/main/src/init.lua"))();

-- Create a new IDE instance
local myIDE = NeonIDE.new();

-- Show the IDE with a smooth animation
myIDE:show();

-- Example Lua code
local exampleLuaCode = [[
local Players = game:GetService("Players");
local RunService = game:GetService("RunService");
local LocalPlayer = Players.LocalPlayer;

-- Simple ESP module
local ESP = {
    enabled = true,
    boxes = true,
    names = true,
    distance = true,
    maxDistance = 1000,
    teamCheck = false
};

-- Create container for ESP objects
local espContainer = Instance.new("Folder");
espContainer.Name = "ESPContainer";
espContainer.Parent = game:GetService("CoreGui");

-- Custom ESP drawing function
local function createESPObject(player)
    local esp = {};
    
    -- Box elements
    esp.box = Drawing.new("Square");
    esp.box.Visible = false;
    esp.box.Thickness = 1;
    esp.box.Color = Color3.fromRGB(255, 255, 255);
    esp.box.Transparency = 0.7;
    esp.box.Filled = false;
    
    -- Name label
    esp.name = Drawing.new("Text");
    esp.name.Visible = false;
    esp.name.Text = player.Name;
    esp.name.Size = 14;
    esp.name.Color = Color3.fromRGB(255, 255, 255);
    esp.name.Center = true;
    esp.name.Outline = true;
    esp.name.OutlineColor = Color3.fromRGB(0, 0, 0);
    
    -- Distance label
    esp.distance = Drawing.new("Text");
    esp.distance.Visible = false;
    esp.distance.Size = 12;
    esp.distance.Color = Color3.fromRGB(255, 255, 255);
    esp.distance.Center = true;
    esp.distance.Outline = true;
    esp.distance.OutlineColor = Color3.fromRGB(0, 0, 0);
    
    -- Health bar
    esp.healthBar = Drawing.new("Square");
    esp.healthBar.Visible = false;
    esp.healthBar.Thickness = 1;
    esp.healthBar.Color = Color3.fromRGB(0, 255, 0);
    esp.healthBar.Transparency = 0.7;
    esp.healthBar.Filled = true;
    
    return esp;
end

-- Player ESP objects
local espObjects = {};

-- Update ESP for a player
local function updateESP(player, esp)
    if not ESP.enabled or not player.Character or not player.Character:FindFirstChild("HumanoidRootPart") then
        esp.box.Visible = false;
        esp.name.Visible = false;
        esp.distance.Visible = false;
        esp.healthBar.Visible = false;
        return;
    end
    
    -- Get character parts
    local hrp = player.Character:FindFirstChild("HumanoidRootPart");
    local humanoid = player.Character:FindFirstChild("Humanoid");
    
    if not hrp or not humanoid then return; end
    
    -- Check distance
    local distance = (hrp.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude;
    if distance > ESP.maxDistance then
        esp.box.Visible = false;
        esp.name.Visible = false;
        esp.distance.Visible = false;
        esp.healthBar.Visible = false;
        return;
    end
    
    -- Team check
    if ESP.teamCheck and player.Team == LocalPlayer.Team then
        esp.box.Visible = false;
        esp.name.Visible = false;
        esp.distance.Visible = false;
        esp.healthBar.Visible = false;
        return;
    end
    
    -- Get 2D position on screen
    local camera = workspace.CurrentCamera;
    local vector, onScreen = camera:WorldToViewportPoint(hrp.Position);
    
    if not onScreen then
        esp.box.Visible = false;
        esp.name.Visible = false;
        esp.distance.Visible = false;
        esp.healthBar.Visible = false;
        return;
    end
    
    -- Update ESP elements
    if ESP.boxes then
        -- Get character size
        local topPoint = camera:WorldToViewportPoint(hrp.Position + Vector3.new(0, 3, 0));
        local bottomPoint = camera:WorldToViewportPoint(hrp.Position - Vector3.new(0, 3, 0));
        local size = bottomPoint.Y - topPoint.Y;
        
        esp.box.Size = Vector2.new(size / 2, size);
        esp.box.Position = Vector2.new(vector.X - size / 4, vector.Y - size / 2);
        esp.box.Visible = true;
    else
        esp.box.Visible = false;
    end
    
    if ESP.names then
        esp.name.Position = Vector2.new(vector.X, vector.Y - 40);
        esp.name.Visible = true;
    else
        esp.name.Visible = false;
    end
    
    if ESP.distance then
        esp.distance.Text = math.floor(distance) .. "m";
        esp.distance.Position = Vector2.new(vector.X, vector.Y + 20);
        esp.distance.Visible = true;
    else
        esp.distance.Visible = false;
    end
    
    -- Update health bar
    if humanoid then
        local health = humanoid.Health;
        local maxHealth = humanoid.MaxHealth;
        local healthPercent = health / maxHealth;
        
        local barHeight = esp.box.Size.Y;
        esp.healthBar.Size = Vector2.new(3, barHeight * healthPercent);
        esp.healthBar.Position = Vector2.new(esp.box.Position.X - 6, esp.box.Position.Y + (barHeight - esp.healthBar.Size.Y));
        esp.healthBar.Color = Color3.fromRGB(255 * (1 - healthPercent), 255 * healthPercent, 0);
        esp.healthBar.Visible = ESP.boxes;
    else
        esp.healthBar.Visible = false;
    end
end

-- Create ESP for each player
for _, player in ipairs(Players:GetPlayers()) do
    if player ~= LocalPlayer then
        espObjects[player] = createESPObject(player);
    end
end

-- Handle player joining/leaving
Players.PlayerAdded:Connect(function(player)
    espObjects[player] = createESPObject(player);
end);

Players.PlayerRemoving:Connect(function(player)
    if espObjects[player] then
        for _, drawing in pairs(espObjects[player]) do
            if typeof(drawing) == "table" and drawing.Remove then
                drawing:Remove();
            end
        end
        espObjects[player] = nil;
    end
end);

-- Main update loop
local connection;
connection = RunService.RenderStepped:Connect(function()
    if not ESP.enabled then return; end
    
    for player, esp in pairs(espObjects) do
        if player.Parent == Players then
            updateESP(player, esp);
        end
    end
end);

-- Toggle ESP function
local function toggleESP()
    ESP.enabled = not ESP.enabled;
    
    if not ESP.enabled then
        for _, esp in pairs(espObjects) do
            for _, drawing in pairs(esp) do
                if typeof(drawing) == "table" and drawing.Visible ~= nil then
                    drawing.Visible = false;
                end
            end
        end
    end
end

-- Cleanup function
local function cleanup()
    connection:Disconnect();
    
    for _, esp in pairs(espObjects) do
        for _, drawing in pairs(esp) do
            if typeof(drawing) == "table" and drawing.Remove then
                drawing:Remove();
            end
        end
    end
    
    espContainer:Destroy();
end

-- Return the ESP API
return {
    toggle = toggleESP,
    cleanup = cleanup,
    settings = ESP
};
]];

-- More example code snippets
local aimAssistCode = [[
-- Simple Aim Assist Module
local AimAssist = {
    enabled = false,
    key = Enum.KeyCode.Q,
    smoothness = 0.5,
    fov = 200,
    teamCheck = true,
    targetPart = "Head"
};

local Players = game:GetService("Players");
local RunService = game:GetService("RunService");
local UserInputService = game:GetService("UserInputService");
local LocalPlayer = Players.LocalPlayer;
local Camera = workspace.CurrentCamera;

-- Create FOV circle
local fovCircle = Drawing.new("Circle");
fovCircle.Visible = true;
fovCircle.Thickness = 1;
fovCircle.Color = Color3.fromRGB(255, 255, 255);
fovCircle.Transparency = 0.7;
fovCircle.NumSides = 60;
fovCircle.Radius = AimAssist.fov;

-- Update FOV circle position
RunService.RenderStepped:Connect(function()
    fovCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2);
    fovCircle.Radius = AimAssist.fov;
    fovCircle.Visible = AimAssist.enabled;
end);

-- Find closest player to aim at
local function getClosestPlayerInFOV()
    local closestPlayer = nil;
    local shortestDistance = AimAssist.fov;
    
    for _, player in ipairs(Players:GetPlayers()) do
        if player ~= LocalPlayer and player.Character and player.Character:FindFirstChild(AimAssist.targetPart) then
            -- Team check
            if AimAssist.teamCheck and player.Team == LocalPlayer.Team then
                continue;
            end
            
            local targetPart = player.Character[AimAssist.targetPart];
            local screenPoint, onScreen = Camera:WorldToScreenPoint(targetPart.Position);
            
            if onScreen then
                local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2);
                local distance = (Vector2.new(screenPoint.X, screenPoint.Y) - screenCenter).Magnitude;
                
                if distance < shortestDistance then
                    closestPlayer = player;
                    shortestDistance = distance;
                end
            end
        end
    end
    
    return closestPlayer;
end

-- Aim assist loop
local aimActive = false;
local connection;

connection = RunService.RenderStepped:Connect(function()
    if AimAssist.enabled and aimActive then
        local target = getClosestPlayerInFOV();
        
        if target and target.Character and target.Character:FindFirstChild(AimAssist.targetPart) then
            local targetPos = target.Character[AimAssist.targetPart].Position;
            local targetCFrame = CFrame.lookAt(Camera.CFrame.Position, targetPos);
            
            Camera.CFrame = Camera.CFrame:Lerp(targetCFrame, AimAssist.smoothness);
        end
    end
end);

-- Input handling
UserInputService.InputBegan:Connect(function(input)
    if input.KeyCode == AimAssist.key then
        aimActive = true;
    end
end);

UserInputService.InputEnded:Connect(function(input)
    if input.KeyCode == AimAssist.key then
        aimActive = false;
    end
end);

-- Toggle function
local function toggle()
    AimAssist.enabled = not AimAssist.enabled;
    return AimAssist.enabled;
end

-- Cleanup function
local function cleanup()
    connection:Disconnect();
    fovCircle:Remove();
end

-- Return API
return {
    toggle = toggle,
    cleanup = cleanup,
    settings = AimAssist
};
]];

-- Get the code editor and add example tabs
local editor = myIDE.editor;
editor:setCode(exampleLuaCode);

-- Optional: Create custom buttons or UI
local themeBtn = myIDE.editor.container:FindFirstChildOfClass("TextButton");
if not themeBtn then
    local ui = loadstring(game:HttpGet("https://raw.githubusercontent.com/testing2122/RobloxNeonIDE/main/src/utils/ui.lua"))();
    
    themeBtn = ui.createButton({
        Text = "Dark Theme",
        Size = UDim2.new(0, 100, 0, 30),
        Position = UDim2.new(1, -110, 0, 10),
        BackgroundColor3 = Color3.fromRGB(40, 40, 60),
        HoverColor = Color3.fromRGB(60, 60, 80),
        PressColor = Color3.fromRGB(30, 30, 50),
        Parent = myIDE.editor.container
    });
    
    local darkMode = true;
    themeBtn.MouseButton1Click:Connect(function()
        darkMode = not darkMode;
        
        if darkMode then
            -- Dark theme
            myIDE:setTheme({
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
            });
            themeBtn.Text = "Light Theme";
        else
            -- Light theme
            myIDE:setTheme({
                BACKGROUND = Color3.fromRGB(240, 240, 250),
                BACKGROUND_SECONDARY = Color3.fromRGB(230, 230, 240),
                ACCENT = Color3.fromRGB(100, 80, 220),
                ACCENT_DARK = Color3.fromRGB(80, 60, 180),
                TEXT_PRIMARY = Color3.fromRGB(30, 30, 40),
                TEXT_SECONDARY = Color3.fromRGB(80, 80, 100),
                BORDER = Color3.fromRGB(200, 200, 220),
                SHADOW = Color3.fromRGB(180, 180, 200),
                SUCCESS = Color3.fromRGB(60, 180, 100),
                ERROR = Color3.fromRGB(200, 60, 60),
                WARNING = Color3.fromRGB(210, 160, 40)
            });
            themeBtn.Text = "Dark Theme";
        end
    end);
end

-- Create keyboard shortcuts for common actions
local uis = game:GetService("UserInputService");
uis.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return; end
    
    -- Ctrl+S: Save code
    if input.KeyCode == Enum.KeyCode.S and uis:IsKeyDown(Enum.KeyCode.LeftControl) then
        local code = editor:getCode();
        -- Implement save functionality here
        print("Code saved! Length:", #code);
    end
    
    -- Ctrl+R: Run code
    if input.KeyCode == Enum.KeyCode.R and uis:IsKeyDown(Enum.KeyCode.LeftControl) then
        local code = editor:getCode();
        -- Execute the code
        local func, err = loadstring(code);
        if func then
            func();
        else
            print("Error:", err);
        end
    end
    
    -- Escape: Hide IDE
    if input.KeyCode == Enum.KeyCode.Escape then
        myIDE:hide();
    end
end);

-- Return the IDE instance so it can be controlled from the calling script
return myIDE;