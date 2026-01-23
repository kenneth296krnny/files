-- Example Script for Cleaned Library
local OutputFile = "GULPITY_CLEAN.LUA"

if not isfile(OutputFile) then
    warn("GULPITY_CLEAN.LUA not found. Run clean_segments.lua first!")
    return
end

local Library = loadstring(readfile(OutputFile))()

if not Library then
    warn("Library failed to load even after cleaning.")
    return
end

-- Create Window
local Window = Library:CreateWindow({
    Name = "Gulpity Clean Test",
    Size = UDim2.fromOffset(600, 450),
    Theme = "Void" 
})

-- Tab 1: Main Features
local MainTab = Window:Tab("Main", "rbxassetid://3926305904")
local MainSection = MainTab:Section("Clean Test")

MainSection:Button({
    Name = "Notify Test",
    Callback = function()
        Library:Notify({
            Title = "Success",
            Content = "The library is now clean and working!",
            Duration = 3
        })
    end
})

-- Initialize
Library:Init()
