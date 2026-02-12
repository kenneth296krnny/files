-- [[ DYNAHAX UI - FRONTEND ]]
local DynahaxUI = {}

-- 1. SILENTLY LOAD THE KERNEL
-- The user never sees this line. It happens in the background.
local ORE = loadstring(game:HttpGet("https://raw.githubusercontent.com/kenneth296krnny/files/refs/heads/main/OreUi/kernel.lua"))().new()

-- 2. CREATE THE WINDOW (Visuals)
function DynahaxUI.new(title)
    local Window = {}
    local ScreenGui = Instance.new("ScreenGui", game.CoreGui)
    -- ... (Insert your GUI creation code here) ...
    
    -- 3. DEFINE ELEMENTS (The Bridge)
    function Window:AddToggle(config)
        -- config = { Text = "Aimbot", ID = "Aim_Main", Default = false, Callback = ... }
        
        -- A. Draw the Visual Button
        local Button = Instance.new("TextButton") -- Your nice UI button
        Button.Text = config.Text
        
        -- B. Define "What happens visually" (The Hook)
        local function UpdateVisuals(state)
            if state then
                Button.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- ON Color
                Button.Text = config.Text .. " [ON]"
            else
                Button.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- OFF Color
                Button.Text = config.Text .. " [OFF]"
            end
        end
        
        -- C. Register to Kernel (The Brain)
        ORE:Register(config.ID, {
            Type = "Toggle",
            Default = config.Default or false,
            Callback = config.Callback,   -- The Script Logic (Aimbot on/off)
            UIHook = UpdateVisuals        -- The Visual Logic (Color change)
        })
        
        -- D. Connect Input
        Button.MouseButton1Click:Connect(function()
            -- We DO NOT change color here. We tell ORE to handle it.
            ORE:HandleToggle(config.ID)
        end)
    end
    
    -- 4. THE MAGIC SYNC (Anti-Glitch)
    -- Once all buttons are created, we force ORE to apply the saved config.
    -- This makes the UI instantly snap to the user's saved settings.
    function Window:LoadConfig()
        ORE:SyncAll()
    end

    return Window
end

return DynahaxUI
