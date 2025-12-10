-- Universal Mobile UI Library
-- Modern Semi-Flat Style (iOS 7 / Android 8 Inspired)
-- Red/Black Color Scheme

local UILibrary = {}

local Players = game:GetService("Players")
local UserInputService = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local CoreGui = game:GetService("CoreGui")

local player = Players.LocalPlayer

-- Create ScreenGui
local screenGui = Instance.new("ScreenGui")
screenGui.Name = "UILibrary"
screenGui.ResetOnSpawn = false
screenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
screenGui.Parent = CoreGui

-- Notification System
local notificationContainer = Instance.new("Frame")
notificationContainer.Name = "NotificationContainer"
notificationContainer.Size = UDim2.new(0, 300, 0, 0)
notificationContainer.Position = UDim2.new(0.5, -150, 0, 10)
notificationContainer.BackgroundTransparency = 1
notificationContainer.Parent = screenGui

local notificationLayout = Instance.new("UIListLayout")
notificationLayout.SortOrder = Enum.SortOrder.LayoutOrder
notificationLayout.Padding = UDim.new(0, 5)
notificationLayout.Parent = notificationContainer

function UILibrary:Notify(title, text, duration)
    spawn(function()
        local notification = Instance.new("Frame")
        notification.Size = UDim2.new(1, 0, 0, 70)
        notification.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
        notification.BorderSizePixel = 0
        notification.Parent = notificationContainer
        
        local notifCorner = Instance.new("UICorner")
        notifCorner.CornerRadius = UDim.new(0, 8)
        notifCorner.Parent = notification
        
        local accent = Instance.new("Frame")
        accent.Size = UDim2.new(0, 4, 1, 0)
        accent.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
        accent.BorderSizePixel = 0
        accent.Parent = notification
        
        local accentCorner = Instance.new("UICorner")
        accentCorner.CornerRadius = UDim.new(0, 8)
        accentCorner.Parent = accent
        
        local titleLabel = Instance.new("TextLabel")
        titleLabel.Size = UDim2.new(1, -15, 0, 25)
        titleLabel.Position = UDim2.new(0, 10, 0, 5)
        titleLabel.BackgroundTransparency = 1
        titleLabel.Text = title
        titleLabel.TextColor3 = Color3.fromRGB(220, 50, 50)
        titleLabel.TextSize = 15
        titleLabel.Font = Enum.Font.GothamBold
        titleLabel.TextXAlignment = Enum.TextXAlignment.Left
        titleLabel.Parent = notification
        
        local textLabel = Instance.new("TextLabel")
        textLabel.Size = UDim2.new(1, -15, 0, 35)
        textLabel.Position = UDim2.new(0, 10, 0, 30)
        textLabel.BackgroundTransparency = 1
        textLabel.Text = text
        textLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        textLabel.TextSize = 13
        textLabel.Font = Enum.Font.Gotham
        textLabel.TextXAlignment = Enum.TextXAlignment.Left
        textLabel.TextWrapped = true
        textLabel.Parent = notification
        
        notification.Position = UDim2.new(0, 300, 0, 0)
        TweenService:Create(notification, TweenInfo.new(0.4, Enum.EasingStyle.Quart, Enum.EasingDirection.Out), {Position = UDim2.new(0, 0, 0, 0)}):Play()
        
        task.wait(duration or 3)
        
        TweenService:Create(notification, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {Position = UDim2.new(0, -300, 0, 0)}):Play()
        task.wait(0.3)
        notification:Destroy()
    end)
end

function UILibrary:CreateWindow(title)
    local window = {}
    window.Tabs = {}
    window.CurrentTab = nil
    
    -- Main Frame
    local mainFrame = Instance.new("Frame")
    mainFrame.Name = "MainFrame"
    mainFrame.Size = UDim2.new(0, 500, 0, 380)
    mainFrame.Position = UDim2.new(0.5, -250, 0.5, -190)
    mainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
    mainFrame.BorderSizePixel = 0
    mainFrame.Active = true
    mainFrame.Parent = screenGui
    
    local mainCorner = Instance.new("UICorner")
    mainCorner.CornerRadius = UDim.new(0, 10)
    mainCorner.Parent = mainFrame
    
    -- Shadow effect
    local shadow = Instance.new("ImageLabel")
    shadow.Name = "Shadow"
    shadow.Size = UDim2.new(1, 20, 1, 20)
    shadow.Position = UDim2.new(0, -10, 0, -10)
    shadow.BackgroundTransparency = 1
    shadow.Image = "rbxasset://textures/ui/Shadow.png"
    shadow.ImageColor3 = Color3.fromRGB(0, 0, 0)
    shadow.ImageTransparency = 0.7
    shadow.ScaleType = Enum.ScaleType.Slice
    shadow.SliceCenter = Rect.new(10, 10, 118, 118)
    shadow.ZIndex = 0
    shadow.Parent = mainFrame
    
    -- Top Bar
    local topBar = Instance.new("Frame")
    topBar.Name = "TopBar"
    topBar.Size = UDim2.new(1, 0, 0, 40)
    topBar.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    topBar.BorderSizePixel = 0
    topBar.Parent = mainFrame
    
    local topCorner = Instance.new("UICorner")
    topCorner.CornerRadius = UDim.new(0, 10)
    topCorner.Parent = topBar
    
    local topFix = Instance.new("Frame")
    topFix.Size = UDim2.new(1, 0, 0, 10)
    topFix.Position = UDim2.new(0, 0, 1, -10)
    topFix.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
    topFix.BorderSizePixel = 0
    topFix.Parent = topBar
    
    local titleLabel = Instance.new("TextLabel")
    titleLabel.Size = UDim2.new(1, -80, 1, 0)
    titleLabel.Position = UDim2.new(0, 15, 0, 0)
    titleLabel.BackgroundTransparency = 1
    titleLabel.Text = title
    titleLabel.TextColor3 = Color3.fromRGB(220, 50, 50)
    titleLabel.TextSize = 18
    titleLabel.Font = Enum.Font.GothamBold
    titleLabel.TextXAlignment = Enum.TextXAlignment.Left
    titleLabel.Parent = topBar
    
    -- Minimize Button
    local minimizeBtn = Instance.new("TextButton")
    minimizeBtn.Size = UDim2.new(0, 30, 0, 30)
    minimizeBtn.Position = UDim2.new(1, -70, 0, 5)
    minimizeBtn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    minimizeBtn.BorderSizePixel = 0
    minimizeBtn.Text = "—"
    minimizeBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
    minimizeBtn.TextSize = 16
    minimizeBtn.Font = Enum.Font.GothamBold
    minimizeBtn.Parent = topBar
    
    local minCorner = Instance.new("UICorner")
    minCorner.CornerRadius = UDim.new(0, 6)
    minCorner.Parent = minimizeBtn
    
    local isMinimized = false
    minimizeBtn.MouseButton1Click:Connect(function()
        isMinimized = not isMinimized
        TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
            Size = isMinimized and UDim2.new(0, 500, 0, 40) or UDim2.new(0, 500, 0, 380)
        }):Play()
    end)
    
    minimizeBtn.MouseEnter:Connect(function()
        TweenService:Create(minimizeBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(60, 60, 60)}):Play()
    end)
    
    minimizeBtn.MouseLeave:Connect(function()
        TweenService:Create(minimizeBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}):Play()
    end)
    
    -- Close Button
    local closeBtn = Instance.new("TextButton")
    closeBtn.Size = UDim2.new(0, 30, 0, 30)
    closeBtn.Position = UDim2.new(1, -35, 0, 5)
    closeBtn.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
    closeBtn.BorderSizePixel = 0
    closeBtn.Text = "×"
    closeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    closeBtn.TextSize = 20
    closeBtn.Font = Enum.Font.GothamBold
    closeBtn.Parent = topBar
    
    local closeCorner = Instance.new("UICorner")
    closeCorner.CornerRadius = UDim.new(0, 6)
    closeCorner.Parent = closeBtn
    
    closeBtn.MouseButton1Click:Connect(function()
        TweenService:Create(mainFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart, Enum.EasingDirection.In), {
            Size = UDim2.new(0, 0, 0, 0)
        }):Play()
        task.wait(0.3)
        screenGui:Destroy()
    end)
    
    closeBtn.MouseEnter:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(255, 70, 70)}):Play()
    end)
    
    closeBtn.MouseLeave:Connect(function()
        TweenService:Create(closeBtn, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(220, 50, 50)}):Play()
    end)
    
    -- Tab Container (Side)
    local tabContainer = Instance.new("Frame")
    tabContainer.Size = UDim2.new(0, 120, 1, -45)
    tabContainer.Position = UDim2.new(0, 5, 0, 45)
    tabContainer.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    tabContainer.BorderSizePixel = 0
    tabContainer.Parent = mainFrame
    
    local tabCorner = Instance.new("UICorner")
    tabCorner.CornerRadius = UDim.new(0, 8)
    tabCorner.Parent = tabContainer
    
    local tabLayout = Instance.new("UIListLayout")
    tabLayout.SortOrder = Enum.SortOrder.LayoutOrder
    tabLayout.Padding = UDim.new(0, 3)
    tabLayout.Parent = tabContainer
    
    local tabPadding = Instance.new("UIPadding")
    tabPadding.PaddingTop = UDim.new(0, 5)
    tabPadding.PaddingBottom = UDim.new(0, 5)
    tabPadding.PaddingLeft = UDim.new(0, 5)
    tabPadding.PaddingRight = UDim.new(0, 5)
    tabPadding.Parent = tabContainer
    
    -- Content Container
    local contentContainer = Instance.new("Frame")
    contentContainer.Size = UDim2.new(1, -135, 1, -50)
    contentContainer.Position = UDim2.new(0, 130, 0, 45)
    contentContainer.BackgroundTransparency = 1
    contentContainer.BorderSizePixel = 0
    contentContainer.Parent = mainFrame
    
    -- Dragging
    local dragging, dragInput, dragStart, startPos
    
    local function update(input)
        local delta = input.Position - dragStart
        mainFrame.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    
    topBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = mainFrame.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    topBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
    end)
    
    function window:CreateTab(name)
        local tab = {}
        tab.Elements = {}
        
        local tabButton = Instance.new("TextButton")
        tabButton.Size = UDim2.new(1, 0, 0, 40)
        tabButton.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
        tabButton.BorderSizePixel = 0
        tabButton.Text = name
        tabButton.TextColor3 = Color3.fromRGB(180, 180, 180)
        tabButton.TextSize = 14
        tabButton.Font = Enum.Font.GothamSemibold
        tabButton.Parent = tabContainer
        
        local tabBtnCorner = Instance.new("UICorner")
        tabBtnCorner.CornerRadius = UDim.new(0, 6)
        tabBtnCorner.Parent = tabButton
        
        local tabContent = Instance.new("ScrollingFrame")
        tabContent.Size = UDim2.new(1, -10, 1, -5)
        tabContent.Position = UDim2.new(0, 0, 0, 0)
        tabContent.BackgroundTransparency = 1
        tabContent.BorderSizePixel = 0
        tabContent.ScrollBarThickness = 6
        tabContent.ScrollBarImageColor3 = Color3.fromRGB(220, 50, 50)
        tabContent.CanvasSize = UDim2.new(0, 0, 0, 0)
        tabContent.Visible = false
        tabContent.Parent = contentContainer
        
        local contentLayout = Instance.new("UIListLayout")
        contentLayout.SortOrder = Enum.SortOrder.LayoutOrder
        contentLayout.Padding = UDim.new(0, 8)
        contentLayout.Parent = tabContent
        
        contentLayout:GetPropertyChangedSignal("AbsoluteContentSize"):Connect(function()
            tabContent.CanvasSize = UDim2.new(0, 0, 0, contentLayout.AbsoluteContentSize.Y + 8)
        end)
        
        tabButton.MouseButton1Click:Connect(function()
            for _, t in pairs(window.Tabs) do
                t.Content.Visible = false
                t.Button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
                t.Button.TextColor3 = Color3.fromRGB(180, 180, 180)
            end
            tabContent.Visible = true
            tabButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
            tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            window.CurrentTab = tab
        end)
        
        tabButton.MouseEnter:Connect(function()
            if tabButton.BackgroundColor3 ~= Color3.fromRGB(220, 50, 50) then
                TweenService:Create(tabButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}):Play()
            end
        end)
        
        tabButton.MouseLeave:Connect(function()
            if tabButton.BackgroundColor3 ~= Color3.fromRGB(220, 50, 50) then
                TweenService:Create(tabButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
            end
        end)
        
        tab.Button = tabButton
        tab.Content = tabContent
        
        if #window.Tabs == 0 then
            tabContent.Visible = true
            tabButton.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
            tabButton.TextColor3 = Color3.fromRGB(255, 255, 255)
            window.CurrentTab = tab
        end
        
        table.insert(window.Tabs, tab)
        
        function tab:CreateButton(text, callback)
            local button = Instance.new("TextButton")
            button.Size = UDim2.new(1, -5, 0, 40)
            button.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            button.BorderSizePixel = 0
            button.Text = text
            button.TextColor3 = Color3.fromRGB(200, 200, 200)
            button.TextSize = 14
            button.Font = Enum.Font.GothamSemibold
            button.Parent = tabContent
            
            local btnCorner = Instance.new("UICorner")
            btnCorner.CornerRadius = UDim.new(0, 8)
            btnCorner.Parent = button
            
            button.MouseButton1Click:Connect(callback)
            
            button.MouseEnter:Connect(function()
                TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(220, 50, 50)}):Play()
            end)
            
            button.MouseLeave:Connect(function()
                TweenService:Create(button, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(35, 35, 35)}):Play()
            end)
            
            return button
        end
        
        function tab:CreateToggle(text, default, callback)
            local toggled = default or false
            
            local toggleFrame = Instance.new("Frame")
            toggleFrame.Size = UDim2.new(1, -5, 0, 40)
            toggleFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            toggleFrame.BorderSizePixel = 0
            toggleFrame.Parent = tabContent
            
            local toggleCorner = Instance.new("UICorner")
            toggleCorner.CornerRadius = UDim.new(0, 8)
            toggleCorner.Parent = toggleFrame
            
            local toggleLabel = Instance.new("TextLabel")
            toggleLabel.Size = UDim2.new(1, -60, 1, 0)
            toggleLabel.Position = UDim2.new(0, 10, 0, 0)
            toggleLabel.BackgroundTransparency = 1
            toggleLabel.Text = text
            toggleLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            toggleLabel.TextSize = 14
            toggleLabel.Font = Enum.Font.GothamSemibold
            toggleLabel.TextXAlignment = Enum.TextXAlignment.Left
            toggleLabel.Parent = toggleFrame
            
            local toggleButton = Instance.new("TextButton")
            toggleButton.Size = UDim2.new(0, 45, 0, 24)
            toggleButton.Position = UDim2.new(1, -50, 0.5, -12)
            toggleButton.BackgroundColor3 = toggled and Color3.fromRGB(220, 50, 50) or Color3.fromRGB(50, 50, 50)
            toggleButton.BorderSizePixel = 0
            toggleButton.Text = ""
            toggleButton.Parent = toggleFrame
            
            local toggleBtnCorner = Instance.new("UICorner")
            toggleBtnCorner.CornerRadius = UDim.new(1, 0)
            toggleBtnCorner.Parent = toggleButton
            
            local toggleIndicator = Instance.new("Frame")
            toggleIndicator.Size = UDim2.new(0, 18, 0, 18)
            toggleIndicator.Position = toggled and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
            toggleIndicator.BackgroundColor3 = Color3.fromRGB(255, 255, 255)
            toggleIndicator.BorderSizePixel = 0
            toggleIndicator.Parent = toggleButton
            
            local indicatorCorner = Instance.new("UICorner")
            indicatorCorner.CornerRadius = UDim.new(1, 0)
            indicatorCorner.Parent = toggleIndicator
            
            toggleButton.MouseButton1Click:Connect(function()
                toggled = not toggled
                
                TweenService:Create(toggleButton, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
                    BackgroundColor3 = toggled and Color3.fromRGB(220, 50, 50) or Color3.fromRGB(50, 50, 50)
                }):Play()
                
                TweenService:Create(toggleIndicator, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
                    Position = toggled and UDim2.new(1, -21, 0.5, -9) or UDim2.new(0, 3, 0.5, -9)
                }):Play()
                
                callback(toggled)
            end)
            
            return toggleFrame
        end
        
        function tab:CreateTextBox(text, placeholder, callback)
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, -5, 0, 70)
            container.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            container.BorderSizePixel = 0
            container.Parent = tabContent
            
            local containerCorner = Instance.new("UICorner")
            containerCorner.CornerRadius = UDim.new(0, 8)
            containerCorner.Parent = container
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -10, 0, 25)
            label.Position = UDim2.new(0, 10, 0, 5)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = Color3.fromRGB(220, 50, 50)
            label.TextSize = 13
            label.Font = Enum.Font.GothamBold
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = container
            
            local textBox = Instance.new("TextBox")
            textBox.Size = UDim2.new(1, -20, 0, 32)
            textBox.Position = UDim2.new(0, 10, 0, 33)
            textBox.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            textBox.BorderSizePixel = 0
            textBox.PlaceholderText = placeholder
            textBox.PlaceholderColor3 = Color3.fromRGB(120, 120, 120)
            textBox.Text = ""
            textBox.TextColor3 = Color3.fromRGB(200, 200, 200)
            textBox.TextSize = 13
            textBox.Font = Enum.Font.Gotham
            textBox.Parent = container
            
            local textBoxCorner = Instance.new("UICorner")
            textBoxCorner.CornerRadius = UDim.new(0, 6)
            textBoxCorner.Parent = textBox
            
            textBox.FocusLost:Connect(function(enterPressed)
                if enterPressed and textBox.Text ~= "" then
                    callback(textBox.Text)
                    textBox.Text = ""
                end
            end)
            
            return container
        end
        
        function tab:CreateLabel(text)
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -5, 0, text == "" and 5 or 30)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = Color3.fromRGB(150, 150, 150)
            label.TextSize = 13
            label.Font = Enum.Font.Gotham
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.TextWrapped = true
            label.Parent = tabContent
            
            return label
        end
        
        function tab:CreateSlider(text, min, max, default, callback)
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, -5, 0, 65)
            container.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            container.BorderSizePixel = 0
            container.Parent = tabContent
            
            local containerCorner = Instance.new("UICorner")
            containerCorner.CornerRadius = UDim.new(0, 8)
            containerCorner.Parent = container
            
            local label = Instance.new("TextLabel")
            label.Size = UDim2.new(1, -60, 0, 25)
            label.Position = UDim2.new(0, 10, 0, 5)
            label.BackgroundTransparency = 1
            label.Text = text
            label.TextColor3 = Color3.fromRGB(220, 50, 50)
            label.TextSize = 13
            label.Font = Enum.Font.GothamBold
            label.TextXAlignment = Enum.TextXAlignment.Left
            label.Parent = container
            
            local valueLabel = Instance.new("TextLabel")
            valueLabel.Size = UDim2.new(0, 50, 0, 25)
            valueLabel.Position = UDim2.new(1, -60, 0, 5)
            valueLabel.BackgroundTransparency = 1
            valueLabel.Text = tostring(default)
            valueLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
            valueLabel.TextSize = 13
            valueLabel.Font = Enum.Font.GothamBold
            valueLabel.TextXAlignment = Enum.TextXAlignment.Right
            valueLabel.Parent = container
            
            local sliderBack = Instance.new("Frame")
            sliderBack.Size = UDim2.new(1, -20, 0, 6)
            sliderBack.Position = UDim2.new(0, 10, 0, 45)
            sliderBack.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
            sliderBack.BorderSizePixel = 0
            sliderBack.Parent = container
            
            local sliderBackCorner = Instance.new("UICorner")
            sliderBackCorner.CornerRadius = UDim.new(1, 0)
            sliderBackCorner.Parent = sliderBack
            
            local sliderFill = Instance.new("Frame")
            sliderFill.Size = UDim2.new((default - min) / (max - min), 0, 1, 0)
            sliderFill.BackgroundColor3 = Color3.fromRGB(220, 50, 50)
            sliderFill.BorderSizePixel = 0
            sliderFill.Parent = sliderBack
            
            local sliderFillCorner = Instance.new("UICorner")
            sliderFillCorner.CornerRadius = UDim.new(1, 0)
            sliderFillCorner.Parent = sliderFill
            
            local dragging = false
            
            local function update(input)
                local pos = math.clamp((input.Position.X - sliderBack.AbsolutePosition.X) / sliderBack.AbsoluteSize.X, 0, 1)
                local value = math.floor(min + (max - min) * pos)
                sliderFill.Size = UDim2.new(pos, 0, 1, 0)
                valueLabel.Text = tostring(value)
                callback(value)
            end
            
            sliderBack.InputBegan:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = true
                    update(input)
                end
            end)
            
            sliderBack.InputEnded:Connect(function(input)
                if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
                    dragging = false
                end
            end)
            
            UserInputService.InputChanged:Connect(function(input)
                if dragging and (input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch) then
                    update(input)
                end
            end)
            
            return container
        end
        
        function tab:CreateDropdown(text, options, callback)
            local container = Instance.new("Frame")
            container.Size = UDim2.new(1, -5, 0, 45)
            container.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
            container.BorderSizePixel = 0
            container.Parent = tabContent
            
            local containerCorner = Instance.new("UICorner")
            containerCorner.CornerRadius = UDim.new(0, 8)
            containerCorner.Parent = container
            
            local dropdownButton = Instance.new("TextButton")
            dropdownButton.Size = UDim2.new(1, -20, 0, 35)
            dropdownButton.Position = UDim2.new(0, 10, 0, 5)
            dropdownButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
            dropdownButton.BorderSizePixel = 0
            dropdownButton.Text = text .. ": " .. (options[1] or "None")
            dropdownButton.TextColor3 = Color3.fromRGB(200, 200, 200)
            dropdownButton.TextSize = 13
            dropdownButton.Font = Enum.Font.GothamSemibold
            dropdownButton.Parent = container
            
            local dropBtnCorner = Instance.new("UICorner")
            dropBtnCorner.CornerRadius = UDim.new(0, 6)
            dropBtnCorner.Parent = dropdownButton
            
            local dropdownFrame = Instance.new("Frame")
            dropdownFrame.Size = UDim2.new(1, -20, 0, 0)
            dropdownFrame.Position = UDim2.new(0, 10, 1, 5)
            dropdownFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
            dropdownFrame.BorderSizePixel = 0
            dropdownFrame.Visible = false
            dropdownFrame.ZIndex = 10
            dropdownFrame.Parent = container
            
            local dropFrameCorner = Instance.new("UICorner")
            dropFrameCorner.CornerRadius = UDim.new(0, 6)
            dropFrameCorner.Parent = dropdownFrame
            
            local dropdownLayout = Instance.new("UIListLayout")
            dropdownLayout.SortOrder = Enum.SortOrder.LayoutOrder
            dropdownLayout.Padding = UDim.new(0, 2)
            dropdownLayout.Parent = dropdownFrame
            
            local dropPadding = Instance.new("UIPadding")
            dropPadding.PaddingTop = UDim.new(0, 5)
            dropPadding.PaddingBottom = UDim.new(0, 5)
            dropPadding.PaddingLeft = UDim.new(0, 5)
            dropPadding.PaddingRight = UDim.new(0, 5)
            dropPadding.Parent = dropdownFrame
            
            local isOpen = false
            
            dropdownButton.MouseButton1Click:Connect(function()
                isOpen = not isOpen
                dropdownFrame.Visible = isOpen
                if isOpen then
                    TweenService:Create(dropdownFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
                        Size = UDim2.new(1, -20, 0, math.min(#options * 32 + 10, 150))
                    }):Play()
                    TweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
                        Size = UDim2.new(1, -5, 0, 45 + math.min(#options * 32 + 15, 165))
                    }):Play()
                else
                    TweenService:Create(dropdownFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
                        Size = UDim2.new(1, -20, 0, 0)
                    }):Play()
                    TweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
                        Size = UDim2.new(1, -5, 0, 45)
                    }):Play()
                end
            end)
            
            for _, option in ipairs(options) do
                local optionButton = Instance.new("TextButton")
                optionButton.Size = UDim2.new(1, -10, 0, 30)
                optionButton.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
                optionButton.BorderSizePixel = 0
                optionButton.Text = option
                optionButton.TextColor3 = Color3.fromRGB(200, 200, 200)
                optionButton.TextSize = 12
                optionButton.Font = Enum.Font.Gotham
                optionButton.Parent = dropdownFrame
                
                local optCorner = Instance.new("UICorner")
                optCorner.CornerRadius = UDim.new(0, 5)
                optCorner.Parent = optionButton
                
                optionButton.MouseButton1Click:Connect(function()
                    dropdownButton.Text = text .. ": " .. option
                    isOpen = false
                    dropdownFrame.Visible = false
                    TweenService:Create(dropdownFrame, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
                        Size = UDim2.new(1, -20, 0, 0)
                    }):Play()
                    TweenService:Create(container, TweenInfo.new(0.3, Enum.EasingStyle.Quart), {
                        Size = UDim2.new(1, -5, 0, 45)
                    }):Play()
                    callback(option)
                end)
                
                optionButton.MouseEnter:Connect(function()
                    TweenService:Create(optionButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(220, 50, 50)}):Play()
                end)
                
                optionButton.MouseLeave:Connect(function()
                    TweenService:Create(optionButton, TweenInfo.new(0.2), {BackgroundColor3 = Color3.fromRGB(45, 45, 45)}):Play()
                end)
            end
            
            return container
        end
        
        return tab
    end
    
    return window
end

return UILibrary