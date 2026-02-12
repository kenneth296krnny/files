--[[
    ORBIT RADIAL HUB - BETA 1.7 (THE REAL UPDATE)
    Build: 20261102_2245_g
    Status: Production Kernel (No Examples)
    
    Features: 
      + Atmospheric Blur Engine
      + Staggered Spiral Animation
      + Integrated Save/Load Manager
      + SafeCallback Error Trapping
      + .plnt Hex Persistence
]]

local Orbit = {}
Orbit.__index = Orbit
Orbit.Version = "Orbit_1.7_Real"

-- [ 1. INTERNAL STORAGE ]
Orbit.Icons = {}
Orbit.Toggles = {}
Orbit.Options = {}
Orbit.Cooldowns = {}
Orbit.GlobalLastInput = 0
Orbit.SoundCache = {}
Orbit.SoundFolder = "OrbitSounds"

-- [ 2. CONFIGURATION ]
local TweenService = game:GetService("TweenService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local SoundService = game:GetService("SoundService")
local Lighting = game:GetService("Lighting")

local CONFIG = {
    BUTTON_SIZE = 50,
    MAIN_SIZE = 60,
    RADIUS_INNER = 115,  
    RADIUS_OUTER = 175,  
    ANIM_SPEED = 0.35, -- Tuned for Spiral
    GLOBAL_THROTTLE = 0.05,
    ELEMENT_COOLDOWN = 0.15,
    KEYBIND = Enum.KeyCode.RightShift,
    
    -- THEME
    COLOR_BG = Color3.fromRGB(12, 12, 12),
    COLOR_ACCENT = Color3.fromRGB(0, 255, 160), -- Updated "Real" Mint
    COLOR_TEXT = Color3.fromRGB(245, 245, 245),
    COLOR_DESKTOP_BG = Color3.fromRGB(18, 18, 18),
    COLOR_INPUT_BG = Color3.fromRGB(30, 30, 30)
}

-- [ 3. CORE LOGIC & SAFETY ]

function Orbit:SafeCallback(func, ...)
    if not func or type(func) ~= "function" then return end
    local success, err = pcall(func, ...)
    if not success then
        warn("[ORBIT KERNEL PANIC]: " .. tostring(err))
        self:Notify("System Error", "Callback Failed. Check Console.", 4)
        self:PlaySound("Notify")
    end
end

function Orbit:CanInteract(id)
    local now = tick()
    if now - Orbit.GlobalLastInput < CONFIG.GLOBAL_THROTTLE then return false end
    if id then
        local last = Orbit.Cooldowns[id] or 0
        if now - last < CONFIG.ELEMENT_COOLDOWN then return false end
        Orbit.Cooldowns[id] = now
    end
    Orbit.GlobalLastInput = now
    return true
end

-- .plnt Save System
function Orbit:SaveConfig()
    if not writefile then return end
    local data = "PLNT|1.7|ORB\n; orbit_real save\n"
    for id, state in pairs(Orbit.Toggles) do
        data = data .. "t." .. id .. "=" .. (state and "0x1" or "0x0") .. "\n"
    end
    for id, val in pairs(Orbit.Options) do
        data = data .. "d." .. id .. "=" .. tostring(val) .. "\n"
    end
    writefile("orbit_config.plnt", data)
    self:Notify("Persistence", "Configuration Saved (.plnt)", 2)
end

function Orbit:LoadConfig()
    if not (readfile and isfile and isfile("orbit_config.plnt")) then return end
    local content = readfile("orbit_config.plnt")
    for line in content:gmatch("[^\r\n]+") do
        if not line:match("^;") and not line:match("^PLNT") then
            if line:sub(1,2) == "t." then
                local id, hex = line:match("t%.([^=]+)=(.*)")
                if id and hex then Orbit.Toggles[id] = (hex == "0x1") end
            end
            if line:sub(1,2) == "d." then
                local id, val = line:match("d%.([^=]+)=(.*)")
                if id and val then Orbit.Options[id] = val end
            end
        end
    end
    self:Notify("Persistence", "Configuration Loaded", 2)
end

-- [ 4. VISUAL ENGINE (BLUR & ICONS) ]
spawn(function()
    local s, d = pcall(function()
        return loadstring(game:HttpGet("https://raw.githubusercontent.com/deedlemcdoodledeedlemcdoodle-creator/SpectravaxHub/main/everylucideassetin.lua"))()
    end)
    if s and type(d) == "table" then Orbit.Icons = d end
end)

function Orbit:GetIcon(name) return Orbit.Icons[name] or "" end

-- Sound Engine
local function PlayAsset(id, vol, pitch)
    local s = Instance.new("Sound", SoundService)
    s.SoundId = id
    s.Volume = vol
    s.PlaybackSpeed = pitch or 1
    s:Play()
    game.Debris:AddItem(s, 2)
end

function Orbit:PlaySound(type, state)
    local sounds = {
        PageTurn = "rbxassetid://6895079853",
        Toggle = "rbxassetid://6895079853",
        Button = "rbxassetid://6895079853",
        Notify = "rbxassetid://5797548176"
    }
    if type == "Toggle" then PlayAsset(sounds.Toggle, 0.5, state and 1.2 or 0.8)
    elseif type == "PageTurn" then PlayAsset(sounds.PageTurn, 0.5, 1)
    elseif type == "Button" then PlayAsset(sounds.Button, 0.4, 1.05)
    elseif type == "Notify" then PlayAsset(sounds.Notify, 0.4, 1) end
end

-- [ 5. UI INITIALIZATION ]

function Orbit.new()
    local self = setmetatable({}, Orbit)
    self.Pages = {}
    self.History = {}
    self.IsOpen = false
    self.RingDrift = 0
    
    self.Gui = Instance.new("ScreenGui", game.CoreGui)
    self.Gui.Name = Orbit.Version
    self.Gui.ResetOnSpawn = false

    -- Blur Effect
    self.Blur = Instance.new("BlurEffect", Lighting)
    self.Blur.Size = 0
    self.Blur.Name = "OrbitAtmosphere"

    self:LoadConfig()

    -- Keybind
    UserInputService.InputBegan:Connect(function(input, gpe)
        if not gpe and not UserInputService:GetFocusedTextBox() and input.KeyCode == CONFIG.KEYBIND then
            self:ToggleMenu()
        end
    end)

    -- Radial Container
    self.RadialFrame = Instance.new("Frame", self.Gui)
    self.RadialFrame.Size = UDim2.new(0,0,0,0)
    self.RadialFrame.Position = UDim2.new(0.5,0,0.5,0)
    self.RadialFrame.BackgroundTransparency = 1

    -- Trigger Button
    self.Trigger = Instance.new("ImageButton", self.RadialFrame)
    self.Trigger.Size = UDim2.new(0, CONFIG.MAIN_SIZE, 0, CONFIG.MAIN_SIZE)
    self.Trigger.AnchorPoint = Vector2.new(0.5, 0.5)
    self.Trigger.BackgroundColor3 = CONFIG.COLOR_BG
    self.Trigger.BackgroundTransparency = 0.1
    Instance.new("UICorner", self.Trigger).CornerRadius = UDim.new(1,0)
    
    local ts = Instance.new("UIStroke", self.Trigger)
    ts.Color = CONFIG.COLOR_ACCENT
    ts.Thickness = 2
    
    local ti = Instance.new("ImageLabel", self.Trigger)
    ti.Name = "Icon"
    ti.Size = UDim2.new(0.5,0,0.5,0)
    ti.Position = UDim2.new(0.5,0,0.5,0)
    ti.AnchorPoint = Vector2.new(0.5,0.5)
    ti.BackgroundTransparency = 1
    ti.ImageColor3 = CONFIG.COLOR_ACCENT
    ti.Image = "rbxassetid://6031091004"

    -- Idle Animation Loop
    RunService.RenderStepped:Connect(function(dt)
        if self.IsOpen then
            self.RingDrift = self.RingDrift + (dt * 1.5)
            for _, child in pairs(self.RadialFrame:GetChildren()) do
                if child:IsA("ImageButton") and child.Name ~= "CenterNode" then
                    local wave = math.sin(self.RingDrift + (child.AbsolutePosition.X/150)) * 4
                    child.Rotation = wave
                end
            end
        end
    end)

    -- Info Label
    self.InfoLabel = Instance.new("TextLabel", self.RadialFrame)
    self.InfoLabel.Size = UDim2.new(0, 200, 0, 30)
    self.InfoLabel.Position = UDim2.new(0.5, 0, 0.5, CONFIG.MAIN_SIZE + 20)
    self.InfoLabel.AnchorPoint = Vector2.new(0.5, 0)
    self.InfoLabel.BackgroundTransparency = 1
    self.InfoLabel.TextColor3 = CONFIG.COLOR_TEXT
    self.InfoLabel.Font = Enum.Font.GothamBold
    self.InfoLabel.TextSize = 14
    self.InfoLabel.TextTransparency = 1
    self.InfoLabel.Text = "Menu"

    -- Desktop UI
    self.DesktopFrame = Instance.new("CanvasGroup", self.Gui)
    self.DesktopFrame.Size = UDim2.new(0, 450, 0, 350)
    self.DesktopFrame.Position = UDim2.new(0.5, -225, 0.5, -175)
    self.DesktopFrame.BackgroundColor3 = CONFIG.COLOR_DESKTOP_BG
    self.DesktopFrame.Visible = false
    self.DesktopFrame.GroupTransparency = 1
    self.DesktopFrame.Draggable = true
    self.DesktopFrame.Active = true
    Instance.new("UICorner", self.DesktopFrame).CornerRadius = UDim.new(0, 10)
    
    local deskStroke = Instance.new("UIStroke", self.DesktopFrame)
    deskStroke.Color = CONFIG.COLOR_ACCENT
    deskStroke.Thickness = 1.5

    -- Notification Container
    self.NotifContainer = Instance.new("Frame", self.Gui)
    self.NotifContainer.Size = UDim2.new(0, 300, 1, 0)
    self.NotifContainer.Position = UDim2.new(0.5, -150, 0, 10)
    self.NotifContainer.BackgroundTransparency = 1
    local nl = Instance.new("UIListLayout", self.NotifContainer)
    nl.HorizontalAlignment = Enum.HorizontalAlignment.Center
    nl.VerticalAlignment = Enum.VerticalAlignment.Top
    nl.Padding = UDim.new(0, 8)

    self.ConfigList = Instance.new("ScrollingFrame", self.DesktopFrame)
    self.ConfigList.Size = UDim2.new(1, -20, 1, -60)
    self.ConfigList.Position = UDim2.new(0, 10, 0, 50)
    self.ConfigList.BackgroundTransparency = 1
    Instance.new("UIListLayout", self.ConfigList).Padding = UDim.new(0, 8)

    -- Internal Close Desktop
    local close = Instance.new("TextButton", self.DesktopFrame)
    close.Size = UDim2.new(0, 30, 0, 30)
    close.Position = UDim2.new(1, -40, 0, 10)
    close.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    close.Text = "X"
    close.TextColor3 = Color3.new(1,1,1)
    Instance.new("UICorner", close)
    close.MouseButton1Click:Connect(function() self:CloseDesktop() end)

    self.Trigger.MouseButton1Click:Connect(function() self:ToggleMenu() end)

    -- AUTO-INJECT SAVE MANAGER
    self:AddDesktopButton("SAVE CONFIG (.PLNT)", function() self:SaveConfig() end)
    self:AddDesktopButton("LOAD CONFIG", function() self:LoadConfig() end)
    self:AddDesktopButton("UNLOAD ORBIT", function() self.Gui:Destroy(); self.Blur:Destroy() end)

    return self
end

-- [ 6. API FUNCTIONS ]

function Orbit:Notify(title, text, dur)
    self:PlaySound("Notify")
    local frame = Instance.new("Frame", self.NotifContainer)
    frame.Size = UDim2.new(1, 0, 0, 50)
    frame.BackgroundColor3 = CONFIG.COLOR_DESKTOP_BG
    frame.BackgroundTransparency = 0.1
    Instance.new("UICorner", frame).CornerRadius = UDim.new(0, 6)
    
    local line = Instance.new("Frame", frame)
    line.Size = UDim2.new(0, 3, 1, 0)
    line.BackgroundColor3 = CONFIG.COLOR_ACCENT
    Instance.new("UICorner", line)
    
    local t = Instance.new("TextLabel", frame)
    t.Text = title
    t.Size = UDim2.new(1, -15, 0, 20)
    t.Position = UDim2.new(0, 10, 0, 5)
    t.TextColor3 = CONFIG.COLOR_ACCENT
    t.Font = Enum.Font.GothamBold
    t.BackgroundTransparency = 1
    t.TextXAlignment = Enum.TextXAlignment.Left
    
    local c = Instance.new("TextLabel", frame)
    c.Text = text
    c.Size = UDim2.new(1, -15, 0, 20)
    c.Position = UDim2.new(0, 10, 0, 25)
    c.TextColor3 = CONFIG.COLOR_TEXT
    c.Font = Enum.Font.Gotham
    c.TextSize = 12
    c.BackgroundTransparency = 1
    c.TextXAlignment = Enum.TextXAlignment.Left

    -- Pop In
    frame.Size = UDim2.new(1,0,0,0)
    TweenService:Create(frame, TweenInfo.new(0.3, Enum.EasingStyle.Back), {Size = UDim2.new(1,0,0,50)}):Play()
    
    task.delay(dur or 3, function()
        TweenService:Create(frame, TweenInfo.new(0.3), {Size = UDim2.new(1,0,0,0), BackgroundTransparency = 1}):Play()
        task.wait(0.3)
        frame:Destroy()
    end)
end

function Orbit:AddDesktopButton(name, callback)
    local btn = Instance.new("TextButton", self.ConfigList)
    btn.Size = UDim2.new(1, 0, 0, 35)
    btn.BackgroundColor3 = CONFIG.COLOR_INPUT_BG
    btn.Text = name
    btn.TextColor3 = CONFIG.COLOR_TEXT
    btn.Font = Enum.Font.GothamBold
    Instance.new("UICorner", btn)
    
    btn.MouseEnter:Connect(function() 
        self:PlaySound("Hover")
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(40,40,40)}):Play()
    end)
    btn.MouseLeave:Connect(function() 
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = CONFIG.COLOR_INPUT_BG}):Play()
    end)
    
    btn.MouseButton1Click:Connect(function() 
        self:PlaySound("Button")
        self:SafeCallback(callback) 
    end)
end

function Orbit:AddDesktopToggle(name, id, callback)
    local f = Instance.new("Frame", self.ConfigList)
    f.Size = UDim2.new(1, 0, 0, 40)
    f.BackgroundTransparency = 1
    
    local lbl = Instance.new("TextLabel", f)
    lbl.Text = name
    lbl.Size = UDim2.new(0.8, 0, 1, 0)
    lbl.TextColor3 = CONFIG.COLOR_TEXT
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.GothamBold
    
    local btn = Instance.new("TextButton", f)
    btn.Size = UDim2.new(0, 20, 0, 20)
    btn.Position = UDim2.new(1, -30, 0.5, -10)
    btn.BackgroundColor3 = Orbit.Toggles[id] and CONFIG.COLOR_ACCENT or CONFIG.COLOR_INPUT_BG
    btn.Text = ""
    Instance.new("UICorner", btn)
    
    btn.MouseButton1Click:Connect(function()
        Orbit.Toggles[id] = not Orbit.Toggles[id]
        TweenService:Create(btn, TweenInfo.new(0.2), {BackgroundColor3 = Orbit.Toggles[id] and CONFIG.COLOR_ACCENT or CONFIG.COLOR_INPUT_BG}):Play()
        self:PlaySound("Toggle", Orbit.Toggles[id])
        self:SafeCallback(callback, Orbit.Toggles[id])
    end)
end

function Orbit:AddDesktopInput(name, default, placeholder, callback)
    local f = Instance.new("Frame", self.ConfigList)
    f.Size = UDim2.new(1, 0, 0, 45)
    f.BackgroundTransparency = 1
    
    local lbl = Instance.new("TextLabel", f)
    lbl.Text = name
    lbl.Size = UDim2.new(0.4, 0, 1, 0)
    lbl.TextColor3 = CONFIG.COLOR_TEXT
    lbl.BackgroundTransparency = 1
    lbl.TextXAlignment = Enum.TextXAlignment.Left
    lbl.Font = Enum.Font.GothamBold
    
    local bg = Instance.new("Frame", f)
    bg.Size = UDim2.new(0.55, -10, 0.7, 0)
    bg.Position = UDim2.new(0.45, 0, 0.15, 0)
    bg.BackgroundColor3 = CONFIG.COLOR_INPUT_BG
    Instance.new("UICorner", bg)
    
    local box = Instance.new("TextBox", bg)
    box.Size = UDim2.new(1, -10, 1, 0)
    box.Position = UDim2.new(0, 5, 0, 0)
    box.BackgroundTransparency = 1
    box.TextColor3 = CONFIG.COLOR_TEXT
    box.Text = tostring(default)
    box.PlaceholderText = placeholder
    box.Font = Enum.Font.Gotham
    
    local stroke = Instance.new("UIStroke", bg)
    stroke.Color = CONFIG.COLOR_INPUT_BG
    
    box.Focused:Connect(function() stroke.Color = CONFIG.COLOR_ACCENT; self:PlaySound("Hover") end)
    box.FocusLost:Connect(function() 
        stroke.Color = CONFIG.COLOR_INPUT_BG
        self:SafeCallback(callback, box.Text) 
    end)
end

function Orbit:RegisterPage(id, items) self.Pages[id] = items end

function Orbit:Navigate(pageId)
    if self.CurrentPage then table.insert(self.History, self.CurrentPage) end
    self.CurrentPage = pageId
    self:RenderRing(self.Pages[pageId], CONFIG.RADIUS_INNER, "InnerRing")
    self:PlaySound("PageTurn")
    self.Trigger.Icon.Image = self:GetIcon("arrow-left")
end

function Orbit:GoBack()
    if #self.History > 0 then
        local prev = table.remove(self.History)
        self.CurrentPage = prev
        self:RenderRing(self.Pages[prev], CONFIG.RADIUS_INNER, "InnerRing")
        self:PlaySound("PageTurn")
        if #self.History == 0 then self.Trigger.Icon.Image = self:GetIcon("menu") end
    else
        self:ToggleMenu()
    end
end

-- [ ANIMATION ENGINE 1.7 ]
function Orbit:RenderRing(items, radius, tag)
    -- Clear Old
    for _, child in pairs(self.RadialFrame:GetChildren()) do
        if child.Name == tag then
            local t = TweenService:Create(child, TweenInfo.new(0.25, Enum.EasingStyle.Back, Enum.EasingDirection.In), {
                Position = UDim2.new(0,0,0,0), Size = UDim2.new(0,0,0,0), ImageTransparency = 1
            })
            t:Play()
            game.Debris:AddItem(child, 0.25)
        end
    end
    
    if not items then return end
    
    -- Spawn New
    for i, item in ipairs(items) do
        local angle = (i * (360/#items)) - 90
        local rad = math.rad(angle)
        local tx, ty = math.cos(rad) * radius, math.sin(rad) * radius
        
        local btn = Instance.new("ImageButton", self.RadialFrame)
        btn.Name = tag
        btn.Size = UDim2.new(0, 0, 0, 0) -- Start scaled down (Bloom effect)
        btn.AnchorPoint = Vector2.new(0.5, 0.5)
        btn.BackgroundColor3 = CONFIG.COLOR_BG
        btn.BackgroundTransparency = 0.2
        btn.ClipsDescendants = true
        
        Instance.new("UICorner", btn).CornerRadius = UDim.new(1,0)
        local stroke = Instance.new("UIStroke", btn)
        stroke.Color = CONFIG.COLOR_ACCENT
        stroke.Thickness = 1.5
        
        local icon = Instance.new("ImageLabel", btn)
        icon.Size = UDim2.new(0.55,0,0.55,0)
        icon.Position = UDim2.new(0.5,0,0.5,0)
        icon.AnchorPoint = Vector2.new(0.5,0.5)
        icon.BackgroundTransparency = 1
        icon.Image = self:GetIcon(item.Icon)
        icon.ImageColor3 = CONFIG.COLOR_TEXT
        
        -- State Logic
        local active = false
        if item.Type == "Toggle" and Orbit.Toggles[item.Id] then active = true end
        if item.Type == "Dropdown" and self.ActiveDropdown == item.Id then active = true end
        
        if active then 
            btn.BackgroundColor3 = CONFIG.COLOR_ACCENT
            icon.ImageColor3 = Color3.new(0,0,0)
        end
        
        -- [[ ANIMATION: STAGGERED SPIRAL BLOOM ]]
        local spinOffset = math.rad(i * 35) -- Tighter spiral
        local startX = math.cos(rad + spinOffset) * (radius * 0.1)
        local startY = math.sin(rad + spinOffset) * (radius * 0.1)
        
        btn.Position = UDim2.new(0, startX, 0, startY)
        btn.Rotation = -90
        
        -- Tween Position
        TweenService:Create(btn, TweenInfo.new(CONFIG.ANIM_SPEED, Enum.EasingStyle.Quad, Enum.EasingDirection.Out), {
            Position = UDim2.new(0, tx, 0, ty),
            Rotation = 0
        }):Play()
        
        -- Tween Scale (Bloom)
        TweenService:Create(btn, TweenInfo.new(CONFIG.ANIM_SPEED + 0.1, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {
            Size = UDim2.new(0, CONFIG.BUTTON_SIZE, 0, CONFIG.BUTTON_SIZE)
        }):Play()
        
        -- Interaction
        btn.MouseButton1Click:Connect(function()
            if not self:CanInteract(item.Id) then return end
            self.InfoLabel.Text = item.Name
            
            -- Pop Animation
            TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(0, CONFIG.BUTTON_SIZE+10, 0, CONFIG.BUTTON_SIZE+10)}):Play()
            task.delay(0.1, function()
                TweenService:Create(btn, TweenInfo.new(0.1), {Size = UDim2.new(0, CONFIG.BUTTON_SIZE, 0, CONFIG.BUTTON_SIZE)}):Play()
            end)
            
            if item.Type == "Action" then 
                self:PlaySound("Button")
                self:SafeCallback(item.Callback)
            elseif item.Type == "Toggle" then
                Orbit.Toggles[item.Id] = not Orbit.Toggles[item.Id]
                self:PlaySound("Toggle", Orbit.Toggles[item.Id])
                self:SaveConfig()
                self:SafeCallback(item.Callback, Orbit.Toggles[item.Id])
                self:RenderRing(items, radius, tag)
            elseif item.Type == "Folder" then
                self:Navigate(item.Dest)
            elseif item.Type == "Dropdown" then
                self:PlaySound("Dropdown", self.ActiveDropdown ~= item.Id)
                if self.ActiveDropdown == item.Id then
                    self:ClearRing("OuterRing")
                    self.ActiveDropdown = nil
                else
                    self.ActiveDropdown = item.Id
                    self:RenderRing(item.Options, CONFIG.RADIUS_OUTER, "OuterRing")
                end
                self:RenderRing(items, radius, tag)
            end
        end)
    end
end

function Orbit:ToggleMenu()
    self.IsOpen = not self.IsOpen
    self:PlaySound("Dropdown", self.IsOpen)
    
    if self.IsOpen then
        -- Open
        self.History = {}
        self.CurrentPage = "Main"
        self:RenderRing(self.Pages["Main"], CONFIG.RADIUS_INNER, "InnerRing")
        TweenService:Create(self.Trigger, TweenInfo.new(CONFIG.ANIM_SPEED), {Rotation = 90}):Play()
        TweenService:Create(self.InfoLabel, TweenInfo.new(0.3), {TextTransparency = 0}):Play()
        TweenService:Create(self.Blur, TweenInfo.new(0.5), {Size = 15}):Play() -- Blur In
        self.Trigger.Icon.Image = self:GetIcon("x")
    else
        -- Close
        self:ClearRing("InnerRing")
        self:ClearRing("OuterRing")
        TweenService:Create(self.Trigger, TweenInfo.new(CONFIG.ANIM_SPEED), {Rotation = 0}):Play()
        TweenService:Create(self.InfoLabel, TweenInfo.new(0.3), {TextTransparency = 1}):Play()
        TweenService:Create(self.Blur, TweenInfo.new(0.5), {Size = 0}):Play() -- Blur Out
        self.Trigger.Icon.Image = self:GetIcon("menu")
    end
end

function Orbit:OpenDesktop()
    self.DesktopFrame.Visible = true
    self:PlaySound("Dropdown", true)
    TweenService:Create(self.Blur, TweenInfo.new(0.5), {Size = 24}):Play() -- Heavier blur for desktop
    
    -- Pop In
    self.DesktopFrame.Size = UDim2.new(0, 420, 0, 320)
    self.DesktopFrame.GroupTransparency = 1
    TweenService:Create(self.DesktopFrame, TweenInfo.new(0.35, Enum.EasingStyle.Elastic, Enum.EasingDirection.Out), {Size = UDim2.new(0, 450, 0, 350)}):Play()
    TweenService:Create(self.DesktopFrame, TweenInfo.new(0.2), {GroupTransparency = 0}):Play()
end

function Orbit:CloseDesktop()
    local t = TweenService:Create(self.DesktopFrame, TweenInfo.new(0.2), {Size = UDim2.new(0, 420, 0, 320), GroupTransparency = 1})
    t:Play()
    TweenService:Create(self.Blur, TweenInfo.new(0.5), {Size = 0}):Play()
    t.Completed:Connect(function() self.DesktopFrame.Visible = false end)
end

return Orbit
