local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")
local HttpService = game:GetService("HttpService")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")

local DEFAULT_COLORS = {
    Main = Color3.fromRGB(200, 180, 255),
    Background = Color3.fromRGB(30, 30, 40),
    Text = Color3.fromRGB(255, 255, 255),
    Button = Color3.fromRGB(100, 80, 160),
    ButtonHover = Color3.fromRGB(120, 100, 180),
    Accent = Color3.fromRGB(180, 160, 220)
}

local ANIMATIONS = {
    FadeIn = function(gui, duration)
        gui.BackgroundTransparency = 1
        for _, child in ipairs(gui:GetDescendants()) do
            if child:IsA("GuiObject") then
                child.BackgroundTransparency = 1
                if child:IsA("TextLabel") or child:IsA("TextButton") or child:IsA("TextBox") then
                    child.TextTransparency = 1
                end
                if child:IsA("ImageLabel") or child:IsA("ImageButton") then
                    child.ImageTransparency = 1
                end
            end
        end
        
        local tweenInfo = TweenInfo.new(duration or 0.5, Enum.EasingStyle.Quad, Enum.EasingDirection.Out)
        
        local function fadeIn(obj)
            if obj:IsA("GuiObject") then
                TweenService:Create(obj, tweenInfo, {BackgroundTransparency = obj.BackgroundTransparency - 1}):Play()
                
                if obj:IsA("TextLabel") or obj:IsA("TextButton") or obj:IsA("TextBox") then
                    TweenService:Create(obj, tweenInfo, {TextTransparency = 0}):Play()
                elseif obj:IsA("ImageLabel") or obj:IsA("ImageButton") then
                    TweenService:Create(obj, tweenInfo, {ImageTransparency = 0}):Play()
                end
            end
        end
        
        fadeIn(gui)
        for _, child in ipairs(gui:GetDescendants()) do
            fadeIn(child)
        end
    end,
    
    ButtonHover = function(button, isHovering)
        local targetColor = isHovering and DEFAULT_COLORS.ButtonHover or DEFAULT_COLORS.Button
        TweenService:Create(
            button,
            TweenInfo.new(0.2, Enum.EasingStyle.Quad, Enum.EasingDirection.Out),
            {BackgroundColor3 = targetColor}
        ):Play()
    end
}

local function createCorner(radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    return corner
end

local function createPadding(padding)
    local uiPadding = Instance.new("UIPadding")
    uiPadding.PaddingBottom = UDim.new(0, padding or 8)
    uiPadding.PaddingTop = UDim.new(0, padding or 8)
    uiPadding.PaddingLeft = UDim.new(0, padding or 8)
    uiPadding.PaddingRight = UDim.new(0, padding or 8)
    return uiPadding
end

local Viper = {}
Viper.__index = Viper

function Viper.new()
    local self = setmetatable({}, Viper)
    
    self.gui = Instance.new("ScreenGui")
    self.gui.Name = "ViperUI"
    self.gui.ResetOnSpawn = false
    self.gui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    
    self.mainFrame = Instance.new("Frame")
    self.mainFrame.Name = "MainFrame"
    self.mainFrame.Size = UDim2.new(0, 600, 0, 400)
    self.mainFrame.Position = UDim2.new(0.5, -300, 0.5, -200)
    self.mainFrame.BackgroundColor3 = DEFAULT_COLORS.Background
    self.mainFrame.BackgroundTransparency = 0.2
    self.mainFrame.BorderSizePixel = 0
    
    local blur = game.Lighting:FindFirstChild("ViperUIBlur")
    if not blur then
        blur = Instance.new("BlurEffect")
        blur.Name = "ViperUIBlur"
        blur.Size = 24
        blur.Parent = game.Lighting
    end
    
    createCorner(12).Parent = self.mainFrame
    
    self.titleBar = Instance.new("Frame")
    self.titleBar.Name = "TitleBar"
    self.titleBar.Size = UDim2.new(0, 150, 1, 0)
    self.titleBar.BackgroundTransparency = 1
    self.titleBar.BorderSizePixel = 0
    self.titleBar.Parent = self.mainFrame
    
    self.icon = Instance.new("ImageLabel")
    self.icon.Name = "Icon"
    self.icon.Size = UDim2.new(0, 64, 0, 64)
    self.icon.Position = UDim2.new(0.5, -32, 0.3, -32)
    self.icon.AnchorPoint = Vector2.new(0.5, 0.5)
    self.icon.BackgroundTransparency = 1
    self.icon.Image = "rbxassetid://0"
    self.icon.Parent = self.titleBar
    
    self.gameName = Instance.new("TextLabel")
    self.gameName.Name = "GameName"
    self.gameName.Size = UDim2.new(1, -20, 0, 60)
    self.gameName.Position = UDim2.new(0, 10, 0.4, 40)
    self.gameName.BackgroundTransparency = 1
    self.gameName.Text = MarketplaceService:GetProductInfo(game.PlaceId).Name or "Game"
    self.gameName.TextColor3 = DEFAULT_COLORS.Text
    self.gameName.TextSize = 16
    self.gameName.Font = Enum.Font.GothamMedium
    self.gameName.TextWrapped = true
    self.gameName.TextXAlignment = Enum.TextXAlignment.Center
    self.gameName.Parent = self.titleBar
    
    self.closeButton = Instance.new("TextButton")
    self.closeButton.Name = "CloseButton"
    self.closeButton.Size = UDim2.new(0, 24, 0, 24)
    self.closeButton.Position = UDim2.new(1, -32, 0, 8)
    self.closeButton.BackgroundColor3 = Color3.fromRGB(255, 80, 80)
    self.closeButton.Text = "X"
    self.closeButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    self.closeButton.TextSize = 14
    self.closeButton.Font = Enum.Font.GothamBold
    self.closeButton.Parent = self.mainFrame
    
    createCorner(12).Parent = self.closeButton
    
    self.contentFrame = Instance.new("Frame")
    self.contentFrame.Name = "ContentFrame"
    self.contentFrame.Size = UDim2.new(1, -170, 1, -40)
    self.contentFrame.Position = UDim2.new(0, 160, 0, 20)
    self.contentFrame.BackgroundTransparency = 0.9
    self.contentFrame.BackgroundColor3 = Color3.fromRGB(40, 40, 50)
    self.contentFrame.ClipsDescendants = true
    createCorner(8).Parent = self.contentFrame
    self.contentFrame.Parent = self.mainFrame
    
    self.mainFrame.Parent = self.gui
    
    self.closeButton.MouseButton1Click:Connect(function()
        self:Close()
    end)
    
    local dragging = false
    local dragStart, startPos
    
    self.titleBar.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            dragStart = input.Position
            startPos = self.mainFrame.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)
    
    self.titleBar.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement and dragging then
            local delta = input.Position - dragStart
            self.mainFrame.Position = UDim2.new(
                startPos.X.Scale,
                startPos.X.Offset + delta.X,
                startPos.Y.Scale,
                startPos.Y.Offset + delta.Y
            )
        end
    end)
    
    self.closeButton.MouseEnter:Connect(function()
        ANIMATIONS.ButtonHover(self.closeButton, true)
    end)
    
    self.closeButton.MouseLeave:Connect(function()
        ANIMATIONS.ButtonHover(self.closeButton, false)
    end)
    
    self.gui.Parent = game:GetService("CoreGui")
    ANIMATIONS.FadeIn(self.mainFrame, 0.5)
    
    self:CreateConfirmationDialog()
    
    return self
end

function Viper:CreateConfirmationDialog()
    self.overlay = Instance.new("Frame")
    self.overlay.Name = "Overlay"
    self.overlay.Size = UDim2.new(1, 0, 1, 0)
    self.overlay.BackgroundColor3 = Color3.new(0, 0, 0)
    self.overlay.BackgroundTransparency = 0.7
    self.overlay.ZIndex = 5
    
    self.dialog = Instance.new("Frame")
    self.dialog.Name = "ConfirmationDialog"
    self.dialog.Size = UDim2.new(0, 400, 0, 200)
    self.dialog.Position = UDim2.new(0.5, -200, 0.5, -100)
    self.dialog.BackgroundColor3 = DEFAULT_COLORS.Background
    self.dialog.BackgroundTransparency = 0.2
    self.dialog.BorderSizePixel = 0
    self.dialog.ZIndex = 6
    
    createCorner(12).Parent = self.dialog
    
    local title = Instance.new("TextLabel")
    title.Name = "Title"
    title.Size = UDim2.new(1, -40, 0, 60)
    title.Position = UDim2.new(0, 20, 0, 20)
    title.BackgroundTransparency = 1
    title.Text = "Load Viper Hub?"
    title.TextColor3 = DEFAULT_COLORS.Text
    title.TextSize = 20
    title.Font = Enum.Font.GothamSemibold
    title.TextWrapped = true
    title.TextXAlignment = Enum.TextXAlignment.Center
    title.ZIndex = 7
    title.Parent = self.dialog
    
    local buttonContainer = Instance.new("Frame")
    buttonContainer.Name = "ButtonContainer"
    buttonContainer.Size = UDim2.new(1, -40, 0, 40)
    buttonContainer.Position = UDim2.new(0, 20, 1, -70)
    buttonContainer.BackgroundTransparency = 1
    buttonContainer.ZIndex = 7
    
    local buttonLayout = Instance.new("UIListLayout")
    buttonLayout.FillDirection = Enum.FillDirection.Horizontal
    buttonLayout.HorizontalAlignment = Enum.HorizontalAlignment.Center
    buttonLayout.SortOrder = Enum.SortOrder.LayoutOrder
    buttonLayout.Padding = UDim.new(0, 20)
    buttonLayout.Parent = buttonContainer
    
    local yesButton = Instance.new("TextButton")
    yesButton.Name = "YesButton"
    yesButton.Size = UDim2.new(0.4, 0, 1, 0)
    yesButton.BackgroundColor3 = DEFAULT_COLORS.Button
    yesButton.Text = "Yes"
    yesButton.TextColor3 = DEFAULT_COLORS.Text
    yesButton.TextSize = 14
    yesButton.Font = Enum.Font.GothamSemibold
    yesButton.ZIndex = 8
    yesButton.LayoutOrder = 1
    
    local noButton = yesButton:Clone()
    noButton.Name = "NoButton"
    noButton.Text = "No"
    noButton.LayoutOrder = 2
    
    local buttonCorner = createCorner(8)
    buttonCorner.Parent = yesButton
    buttonCorner:Clone().Parent = noButton
    
    yesButton.MouseEnter:Connect(function() ANIMATIONS.ButtonHover(yesButton, true) end)
    yesButton.MouseLeave:Connect(function() ANIMATIONS.ButtonHover(yesButton, false) end)
    noButton.MouseEnter:Connect(function() ANIMATIONS.ButtonHover(noButton, true) end)
    noButton.MouseLeave:Connect(function() ANIMATIONS.ButtonHover(noButton, false) end)
    
    yesButton.MouseButton1Click:Connect(function()
        self:CloseDialog()
    end)
    
    noButton.MouseButton1Click:Connect(function()
        self:Close()
    end)
    
    yesButton.Parent = buttonContainer
    noButton.Parent = buttonContainer
    buttonContainer.Parent = self.dialog
    self.dialog.Parent = self.overlay
    self.overlay.Parent = self.gui
    
    self.dialog.Size = UDim2.new(0, 0, 0, 0)
    self.dialog.Position = UDim2.new(0.5, 0, 0.5, 0)
    
    TweenService:Create(
        self.dialog,
        TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.Out),
        {Size = UDim2.new(0, 400, 0, 200), Position = UDim2.new(0.5, -200, 0.5, -100)}
    ):Play()
end

function Viper:CloseDialog()
    if self.dialog and self.overlay then
        TweenService:Create(
            self.dialog,
            TweenInfo.new(0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In),
            {Size = UDim2.new(0, 0, 0, 0), Position = UDim2.new(0.5, 0, 0.5, 0)}
        ).Completed:Connect(function()
            self.overlay:Destroy()
            self.overlay = nil
            self.dialog = nil
        end):Play()
    end
end

function Viper:Close()
    TweenService:Create(
        self.mainFrame, 
        TweenInfo.new(0.3, Enum.EasingStyle.Quad, Enum.EasingDirection.In), 
        {BackgroundTransparency = 1}
    ).Completed:Connect(function()
        self.gui:Destroy()
    end):Play()
end

-- Example usage
--[[
local Viper = loadstring(game:HttpGet("https://raw.githubusercontent.com/yourusername/viper-ui/main/library.luau"))()

-- Create a new Viper UI instance
local ui = Viper.new()

-- You can customize the UI after creation
ui.title.Text = "My Awesome Game"
ui.icon.Image = "rbxassetid://1234567890" -- Replace with your icon asset id
]]

return Viper
