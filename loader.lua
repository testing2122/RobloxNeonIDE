--[[
    NeonIDE Loader
    
    This script provides a simple way to load and use the NeonIDE in one line.
    Just loadstring this file to get started.
]]

return function(config)
    config = config or {};
    
    -- Load the main library
    local NeonIDE = loadstring(game:HttpGet("https://raw.githubusercontent.com/testing2122/RobloxNeonIDE/refs/heads/main/src/init.lua"))();
    
    -- Create a new IDE instance
    local ide = NeonIDE.new();
    
    -- Configure based on provided options
    if config.theme then
        ide:setTheme(config.theme);
    end
    
    if config.code then
        ide.editor:setCode(config.code);
    end
    
    -- Show the IDE
    if config.show ~= false then
        ide:show();
    end
    
    -- Register keyboard shortcuts
    local uis = game:GetService("UserInputService");
    uis.InputBegan:Connect(function(input, gameProcessed)
        if gameProcessed then return; end
        
        -- Ctrl+S: Save code
        if input.KeyCode == Enum.KeyCode.S and uis:IsKeyDown(Enum.KeyCode.LeftControl) then
            local code = ide.editor:getCode();
            
            if config.onSave then
                config.onSave(code);
            end
        end
        
        -- Ctrl+R: Run code
        if input.KeyCode == Enum.KeyCode.R and uis:IsKeyDown(Enum.KeyCode.LeftControl) then
            local code = ide.editor:getCode();
            
            if config.onRun then
                config.onRun(code);
            else
                -- Execute the code
                local func, err = loadstring(code);
                if func then
                    func();
                else
                    print("Error:", err);
                end
            end
        end
        
        -- Escape: Hide IDE
        if input.KeyCode == Enum.KeyCode.Escape and not config.disableEscapeHide then
            ide:hide();
        end
    end);
    
    return ide;
end

--[[
    Usage example:

    loadstring(game:HttpGet("https://raw.githubusercontent.com/testing2122/RobloxNeonIDE/refs/heads/main/loader.lua"))()(
    {
        code = "print('Hello World!')",
        onSave = function(code)
            writefile("saved_code.lua", code)
        end,
        onRun = function(code)
            loadstring(code)()
        end
    })
]]