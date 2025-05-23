local animate = {}

local tweenservice = game:GetService("TweenService");
local runservice = game:GetService("RunService");

-- Easing functions
local easings = {
    linear = function(t) return t end,
    easeInQuad = function(t) return t^2 end,
    easeOutQuad = function(t) return t * (2 - t) end,
    easeInOutQuad = function(t) return t < 0.5 and 2 * t^2 or -1 + (4 - 2 * t) * t end,
    easeInCubic = function(t) return t^3 end,
    easeOutCubic = function(t) return (t - 1)^3 + 1 end,
    easeInOutCubic = function(t) return t < 0.5 and 4 * t^3 or (t - 1) * (2 * t - 2)^2 + 1 end,
    easeInQuart = function(t) return t^4 end,
    easeOutQuart = function(t) return 1 - (t - 1)^4 end,
    easeInOutQuart = function(t) return t < 0.5 and 8 * t^4 or 1 - 8 * (t - 1)^4 end,
    easeOutElastic = function(t)
        local c4 = (2 * math.pi) / 3;
        return t == 0 and 0 or t == 1 and 1 or 2^(-10 * t) * math.sin((t * 10 - 0.75) * c4) + 1;
    end,
    easeInBack = function(t)
        local c1 = 1.70158;
        local c3 = c1 + 1;
        return c3 * t^3 - c1 * t^2;
    end,
    easeOutBack = function(t)
        local c1 = 1.70158;
        local c3 = c1 + 1;
        return 1 + c3 * (t - 1)^3 + c1 * (t - 1)^2;
    end,
    easeInOutBack = function(t)
        local c1 = 1.70158;
        local c2 = c1 * 1.525;
        return t < 0.5 and ((2 * t)^2 * ((c2 + 1) * 2 * t - c2)) / 2 or ((2 * t - 2)^2 * ((c2 + 1) * (t * 2 - 2) + c2) + 2) / 2;
    end
};

-- Spring physics parameters
local spring = {
    stiffness = 170,
    damping = 26,
    mass = 1
};

function animate.tween(object, properties, duration, easing, callback)
    easing = easing or "linear";
    local easingStyle;
    
    -- Convert string easing to TweenService enum
    if easing == "linear" then
        easingStyle = Enum.EasingStyle.Linear;
    elseif easing == "easeInQuad" or easing == "easeIn" then
        easingStyle = Enum.EasingStyle.Quad;
        easingDirection = Enum.EasingDirection.In;
    elseif easing == "easeOutQuad" or easing == "easeOut" then
        easingStyle = Enum.EasingStyle.Quad;
        easingDirection = Enum.EasingDirection.Out;
    elseif easing == "easeInOutQuad" or easing == "easeInOut" then
        easingStyle = Enum.EasingStyle.Quad;
        easingDirection = Enum.EasingDirection.InOut;
    elseif easing == "easeInCubic" then
        easingStyle = Enum.EasingStyle.Cubic;
        easingDirection = Enum.EasingDirection.In;
    elseif easing == "easeOutCubic" then
        easingStyle = Enum.EasingStyle.Cubic;
        easingDirection = Enum.EasingDirection.Out;
    elseif easing == "easeInOutCubic" then
        easingStyle = Enum.EasingStyle.Cubic;
        easingDirection = Enum.EasingDirection.InOut;
    elseif easing == "easeInQuart" then
        easingStyle = Enum.EasingStyle.Quart;
        easingDirection = Enum.EasingDirection.In;
    elseif easing == "easeOutQuart" then
        easingStyle = Enum.EasingStyle.Quart;
        easingDirection = Enum.EasingDirection.Out;
    elseif easing == "easeInOutQuart" then
        easingStyle = Enum.EasingStyle.Quart;
        easingDirection = Enum.EasingDirection.InOut;
    elseif easing == "easeOutElastic" then
        easingStyle = Enum.EasingStyle.Elastic;
        easingDirection = Enum.EasingDirection.Out;
    elseif easing == "easeInBack" then
        easingStyle = Enum.EasingStyle.Back;
        easingDirection = Enum.EasingDirection.In;
    elseif easing == "easeOutBack" then
        easingStyle = Enum.EasingStyle.Back;
        easingDirection = Enum.EasingDirection.Out;
    elseif easing == "easeInOutBack" then
        easingStyle = Enum.EasingStyle.Back;
        easingDirection = Enum.EasingDirection.InOut;
    else
        easingStyle = Enum.EasingStyle.Quad;
        easingDirection = Enum.EasingDirection.Out;
    end
    
    local tinfo = TweenInfo.new(
        duration,
        easingStyle,
        easingDirection
    );
    
    local tween = tweenservice:Create(object, tinfo, properties);
    tween:Play();
    
    if callback then
        tween.Completed:Connect(callback);
    end
    
    return tween;
end

function animate.spring(object, targetProperties, duration, easing, callback)
    duration = duration or 0.5;
    easing = easing or "easeOutElastic";
    
    local startProperties = {};
    local velocity = {};
    local targetReached = {};
    local isDone = false;
    
    -- Initialize properties
    for prop, target in pairs(targetProperties) do
        startProperties[prop] = object[prop];
        velocity[prop] = 0;
        targetReached[prop] = false;
        
        -- Handle special UDim2 case
        if typeof(target) == "UDim2" then
            velocity[prop] = UDim2.new(0, 0, 0, 0);
        elseif typeof(target) == "Vector2" then
            velocity[prop] = Vector2.new(0, 0);
        elseif typeof(target) == "Vector3" then
            velocity[prop] = Vector3.new(0, 0, 0);
        elseif typeof(target) == "CFrame" then
            velocity[prop] = CFrame.new(0, 0, 0);
        end
    end
    
    local conn;
    local startTime = tick();
    
    conn = runservice.RenderStepped:Connect(function(deltaTime)
        local allDone = true;
        local timeFactor = math.min((tick() - startTime) / duration, 1);
        local easeFactor = easings[easing](timeFactor);
        
        for prop, target in pairs(targetProperties) do
            -- Skip if this property is done
            if targetReached[prop] then
                continue;
            end
            
            -- Different handling for different types
            if typeof(target) == "number" then
                local current = object[prop];
                local diff = (target - current) * spring.stiffness * easeFactor;
                velocity[prop] = velocity[prop] * (1 - spring.damping * deltaTime) + diff * deltaTime;
                object[prop] = current + velocity[prop];
                
                if math.abs(target - object[prop]) < 0.001 and math.abs(velocity[prop]) < 0.001 then
                    object[prop] = target;
                    targetReached[prop] = true;
                else
                    allDone = false;
                end
            elseif typeof(target) == "UDim2" then
                local current = object[prop];
                
                -- X Scale
                local diffXS = (target.X.Scale - current.X.Scale) * spring.stiffness * easeFactor;
                velocity[prop] = UDim2.new(
                    velocity[prop].X.Scale * (1 - spring.damping * deltaTime) + diffXS * deltaTime,
                    velocity[prop].X.Offset,
                    velocity[prop].Y.Scale,
                    velocity[prop].Y.Offset
                );
                
                -- X Offset
                local diffXO = (target.X.Offset - current.X.Offset) * spring.stiffness * easeFactor;
                velocity[prop] = UDim2.new(
                    velocity[prop].X.Scale,
                    velocity[prop].X.Offset * (1 - spring.damping * deltaTime) + diffXO * deltaTime,
                    velocity[prop].Y.Scale,
                    velocity[prop].Y.Offset
                );
                
                -- Y Scale
                local diffYS = (target.Y.Scale - current.Y.Scale) * spring.stiffness * easeFactor;
                velocity[prop] = UDim2.new(
                    velocity[prop].X.Scale,
                    velocity[prop].X.Offset,
                    velocity[prop].Y.Scale * (1 - spring.damping * deltaTime) + diffYS * deltaTime,
                    velocity[prop].Y.Offset
                );
                
                -- Y Offset
                local diffYO = (target.Y.Offset - current.Y.Offset) * spring.stiffness * easeFactor;
                velocity[prop] = UDim2.new(
                    velocity[prop].X.Scale,
                    velocity[prop].X.Offset,
                    velocity[prop].Y.Scale,
                    velocity[prop].Y.Offset * (1 - spring.damping * deltaTime) + diffYO * deltaTime
                );
                
                object[prop] = UDim2.new(
                    current.X.Scale + velocity[prop].X.Scale,
                    current.X.Offset + velocity[prop].X.Offset,
                    current.Y.Scale + velocity[prop].Y.Scale,
                    current.Y.Offset + velocity[prop].Y.Offset
                );
                
                if math.abs(target.X.Scale - object[prop].X.Scale) < 0.001 and
                   math.abs(target.X.Offset - object[prop].X.Offset) < 0.001 and
                   math.abs(target.Y.Scale - object[prop].Y.Scale) < 0.001 and
                   math.abs(target.Y.Offset - object[prop].Y.Offset) < 0.001 and
                   math.abs(velocity[prop].X.Scale) < 0.001 and
                   math.abs(velocity[prop].X.Offset) < 0.001 and
                   math.abs(velocity[prop].Y.Scale) < 0.001 and
                   math.abs(velocity[prop].Y.Offset) < 0.001 then
                    object[prop] = target;
                    targetReached[prop] = true;
                else
                    allDone = false;
                end
            elseif typeof(target) == "Color3" then
                -- For simplicity, we'll use direct tweening for colors
                if timeFactor >= 1 then
                    object[prop] = target;
                    targetReached[prop] = true;
                else
                    local r = startProperties[prop].R + (target.R - startProperties[prop].R) * easeFactor;
                    local g = startProperties[prop].G + (target.G - startProperties[prop].G) * easeFactor;
                    local b = startProperties[prop].B + (target.B - startProperties[prop].B) * easeFactor;
                    object[prop] = Color3.new(r, g, b);
                    allDone = false;
                end
            else
                -- For other types, use direct tweening
                if timeFactor >= 1 then
                    object[prop] = target;
                    targetReached[prop] = true;
                else
                    allDone = false;
                end
            end
        end
        
        -- End animation when all done
        if allDone or timeFactor >= 1 then
            -- Set final values
            for prop, target in pairs(targetProperties) do
                object[prop] = target;
            end
            
            conn:Disconnect();
            isDone = true;
            
            if callback then
                callback();
            end
        end
    end);
    
    return {
        cancel = function()
            if not isDone then
                conn:Disconnect();
                isDone = true;
            end
        end,
        finished = function()
            return isDone;
        end
    };
end

-- Modified tween function for glow effect
function animate.glow(object, intensity, duration, interval)
    intensity = intensity or 0.3;
    duration = duration or 1.5;
    interval = interval or 2;
    
    local originalColor = object.ImageColor3 or object.BackgroundColor3 or object.TextColor3;
    local property = object:IsA("ImageLabel") and "ImageColor3" or 
                    object:IsA("TextLabel") and "TextColor3" or "BackgroundColor3";
    
    local brighterColor = Color3.new(
        math.min(originalColor.R + intensity, 1),
        math.min(originalColor.G + intensity, 1),
        math.min(originalColor.B + intensity, 1)
    );
    
    local function cycle()
        animate.tween(object, {[property] = brighterColor}, duration/2, "easeInOutQuad", function()
            animate.tween(object, {[property] = originalColor}, duration/2, "easeInOutQuad");
        end);
    end
    
    cycle();
    local connection;
    
    connection = runservice.Heartbeat:Connect(function()
        if not object or not object.Parent then
            connection:Disconnect();
            return;
        end
    end);
    
    spawn(function()
        while connection.Connected do
            cycle();
            wait(interval);
        end
    end);
    
    return {
        stop = function()
            connection:Disconnect();
            animate.tween(object, {[property] = originalColor}, duration/4, "easeOutQuad");
        end
    };
end

-- Ripple effect for buttons
function animate.ripple(button, color, speed)
    local rippleColor = color or Color3.fromRGB(255, 255, 255);
    local rippleSpeed = speed or 0.5;
    
    button.ClipsDescendants = true;
    
    button.MouseButton1Down:Connect(function(x, y)
        local ripple = Instance.new("Frame");
        ripple.Name = "Ripple";
        ripple.AnchorPoint = Vector2.new(0.5, 0.5);
        ripple.BackgroundColor3 = rippleColor;
        ripple.BackgroundTransparency = 0.6;
        ripple.Position = UDim2.new(0, x - button.AbsolutePosition.X, 0, y - button.AbsolutePosition.Y);
        ripple.Size = UDim2.new(0, 0, 0, 0);
        
        local corner = Instance.new("UICorner");
        corner.CornerRadius = UDim.new(1, 0);
        corner.Parent = ripple;
        
        ripple.Parent = button;
        
        local buttonSize = math.max(button.AbsoluteSize.X, button.AbsoluteSize.Y) * 2;
        
        animate.tween(ripple, {
            Size = UDim2.new(0, buttonSize, 0, buttonSize),
            BackgroundTransparency = 1
        }, rippleSpeed, "easeOut", function()
            ripple:Destroy();
        end);
    end);
end

-- Create typing effect
function animate.typing(textLabel, text, speed)
    speed = speed or 0.03;
    textLabel.Text = "";
    
    local length = string.len(text);
    for i = 1, length do
        textLabel.Text = string.sub(text, 1, i);
        wait(speed);
    end
end

return animate;