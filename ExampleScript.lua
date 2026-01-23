-- Load the Library
local Library = loadstring(game:HttpGet("https://raw.githubusercontent.com/kenneth296krnny/files/refs/heads/main/GULPITY.LUA"))()

-- Create Window
local Window = Library:CreateWindow({
    Name = "Gulpity Example",
    Size = UDim2.fromOffset(600, 450),
    Theme = "Void" -- Uses one of the built-in presets
})

-- Tab 1: Main Features
local MainTab = Window:Tab("Main", "rbxassetid://3926305904")
local MainSection = MainTab:Section("Basic Inputs")

MainSection:Button({
    Name = "Test Button",
    Callback = function()
        Library:Notify({
            Title = "Clicked",
            Content = "You clicked the test button!",
            Duration = 3
        })
    end
})

MainSection:Toggle({
    Name = "Auto Farm",
    Default = false,
    Callback = function(state)
        print("Auto Farm is now:", state)
    end
})

MainSection:Slider({
    Name = "WalkSpeed",
    Min = 16,
    Max = 500,
    Default = 16,
    Decimals = 1,
    Callback = function(val)
        if game.Players.LocalPlayer.Character then
            game.Players.LocalPlayer.Character.Humanoid.WalkSpeed = val
        end
    end
})

MainSection:Dropdown({
    Name = "Teleport Method",
    Items = {"CFrame", "Pivot", "MoveTo"},
    Default = "CFrame",
    Callback = function(val)
        Library:Notify({Title = "Selected", Content = val, Duration = 2})
    end
})

-- Tab 2: Visuals & Colors
local VisualsTab = Window:Tab("Visuals", "rbxassetid://3926307971")
local VisualsSection = VisualsTab:Section("ESP Settings")

VisualsSection:Toggle({
    Name = "Enable ESP",
    Default = false,
    Callback = function(v)
        -- Accessing the internal ESP module if exposed, or just toggle variable
        if Library.Visuals then Library.Visuals.Enabled = v end
    end
})

VisualsSection:ColorPicker({
    Name = "ESP Color",
    Default = Color3.fromRGB(255, 0, 0),
    Callback = function(color)
        print("ESP Color changed to:", color)
    end
})

-- Tab 3: Settings
local SettingsTab = Window:Tab("Settings", "rbxassetid://3926305904")
local SettingsSection = SettingsTab:Section("Keybinds")

SettingsSection:Keybind({
    Name = "Menu Toggle",
    Default = Enum.KeyCode.RightShift,
    Callback = function(key)
        Library.ToggleKey = key
    end
})

SettingsSection:Textbox({
    Name = "Custom Message",
    Placeholder = "Type something...",
    Callback = function(text)
        print("User typed:", text)
    end
})

-- Initialize
Library:Init()
