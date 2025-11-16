local Viper = {}
Viper.__index = Viper

local TweenService = game:GetService("TweenService")
local MarketplaceService = game:GetService("MarketplaceService")
local UserInputService = game:GetService("UserInputService")
local Players = game:GetService("Players")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")

local Player = Players.LocalPlayer
local PlayerGui = Player:WaitForChild("PlayerGui")

local COLORS = {
    Background = Color3.fromRGB(15, 15, 20),
    Sidebar = Color3.fromRGB(20, 20, 25),
    Accent = Color3.fromRGB(180, 160, 220),
    AccentHover = Color3.fromRGB(200, 180, 240),
    Text = Color3.fromRGB(255, 255, 255),
    SubText = Color3.fromRGB(180, 180, 190),
    Button = Color3.fromRGB(35, 35, 45),
    ButtonHover = Color3.fromRGB(45, 45, 55)
}

local function CreateTween(instance, properties, duration, easingStyle, easingDirection)
    easingStyle = easingStyle or Enum.EasingStyle.Quart
    easingDirection = easingDirection or Enum.EasingDirection.Out
    duration = duration or 0.3

    local tweenInfo = TweenInfo.new(duration, easingStyle, easingDirection)
    local tween = TweenService:Create(instance, tweenInfo, properties)
    return tween
end

local function AddCorner(instance, radius)
    local corner = Instance.new("UICorner")
    corner.CornerRadius = UDim.new(0, radius or 8)
    corner.Parent = instance
    return corner
end

local function AddStroke(instance, color, thickness, transparency)
    local stroke = Instance.new("UIStroke")
    stroke.Color = color or Color3.fromRGB(255, 255, 255)
    stroke.Thickness = thickness or 1
    stroke.Transparency = transparency or 0.8
    stroke.Parent = instance
    return stroke
end

local function GetGameInfo()
    local gameId = game.PlaceId
    local success, result = pcall(function()
        return MarketplaceService:GetProductInfo(gameId)
    end)

    if success then
        return {
            Name = result.Name,
            IconUrl = "rbxassetid://" .. tostring(result.IconImageAssetId or 0)
        }
    else
        return {
            Name = "Unknown Game",
            IconUrl = "rbxassetid://0"
        }
    end
end

function Viper.new(iconAsset)
    local self = setmetatable({}, Viper)

    self.IconAsset = iconAsset or "rbxassetid://0"
    self.GameInfo = GetGameInfo()
    self.Loaded = false

    self:CreateLoadPrompt()

    return self
end

function Viper:CreateLoadPrompt()
    local ScreenGui = Instance.new("ScreenGui")
    ScreenGui.Name = "ViperLoadPrompt"
    ScreenGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    ScreenGui.Parent = CoreGui

    local Overlay = Instance.new("Frame")
    Overlay.Name = "Overlay"
    Overlay.Size = UDim2.new(1, 0, 1, 0)
    Overlay.Position = UDim2.new(0, 0, 0, 0)
    Overlay.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
    Overlay.BackgroundTransparency = 1
    Overlay.BorderSizePixel = 0
    Overlay.Parent = ScreenGui

    local PromptFrame = Instance.new("Frame")
    PromptFrame.Name = "PromptFrame"
    PromptFrame.Size = UDim2.new(0, 400, 0, 250)
    PromptFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    PromptFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    PromptFrame.BackgroundColor3 = COLORS.Background
    PromptFrame.BackgroundTransparency = 1
    PromptFrame.BorderSizePixel = 0
    PromptFrame.Parent = Overlay

    AddCorner(PromptFrame, 12)
    AddStroke(PromptFrame, COLORS.Accent, 1, 0.6)

    local Blur = Instance.new("ImageLabel")
    Blur.Name = "Blur"
    Blur.Size = UDim2.new(1, 0, 1, 0)
    Blur.BackgroundTransparency = 1
    Blur.Image = "rbxasset://textures/ui/GuiImagePlaceholder.png"
    Blur.ImageTransparency = 0.95
    Blur.ScaleType = Enum.ScaleType.Crop
    Blur.Parent = PromptFrame

    AddCorner(Blur, 12)

    local IconHolder = Instance.new("ImageLabel")
    IconHolder.Name = "Icon"
    IconHolder.Size = UDim2.new(0, 80, 0, 80)
    IconHolder.Position = UDim2.new(0.5, 0, 0, 30)
    IconHolder.AnchorPoint = Vector2.new(0.5, 0)
    IconHolder.BackgroundColor3 = COLORS.Sidebar
    IconHolder.BackgroundTransparency = 0.3
    IconHolder.BorderSizePixel = 0
    IconHolder.Image = self.IconAsset
    IconHolder.Parent = PromptFrame

    AddCorner(IconHolder, 40)
    AddStroke(IconHolder, COLORS.Accent, 2, 0.5)

    local TitleLabel = Instance.new("TextLabel")
    TitleLabel.Name = "Title"
    TitleLabel.Size = UDim2.new(0.9, 0, 0, 30)
    TitleLabel.Position = UDim2.new(0.5, 0, 0, 125)
    TitleLabel.AnchorPoint = Vector2.new(0.5, 0)
    TitleLabel.BackgroundTransparency = 1
    TitleLabel.Text = "Do you want to load Viper Hub for"
    TitleLabel.TextColor3 = COLORS.SubText
    TitleLabel.TextSize = 14
    TitleLabel.Font = Enum.Font.GothamMedium
    TitleLabel.Parent = PromptFrame

    local GameNameLabel = Instance.new("TextLabel")
    GameNameLabel.Name = "GameName"
    GameNameLabel.Size = UDim2.new(0.9, 0, 0, 25)
    GameNameLabel.Position = UDim2.new(0.5, 0, 0, 150)
    GameNameLabel.AnchorPoint = Vector2.new(0.5, 0)
    GameNameLabel.BackgroundTransparency = 1
    GameNameLabel.Text = self.GameInfo.Name
    GameNameLabel.TextColor3 = COLORS.Accent
    GameNameLabel.TextSize = 16
    GameNameLabel.Font = Enum.Font.GothamBold
    GameNameLabel.TextTruncate = Enum.TextTruncate.AtEnd
    GameNameLabel.Parent = PromptFrame

    local ButtonContainer = Instance.new("Frame")
    ButtonContainer.Name = "Buttons"
    ButtonContainer.Size = UDim2.new(0.8, 0, 0, 40)
    ButtonContainer.Position = UDim2.new(0.5, 0, 1, -50)
    ButtonContainer.AnchorPoint = Vector2.new(0.5, 0)
    ButtonContainer.BackgroundTransparency = 1
    ButtonContainer.Parent = PromptFrame

    local YesButton = Instance.new("TextButton")
    YesButton.Name = "Yes"
    YesButton.Size = UDim2.new(0.48, 0, 1, 0)
    YesButton.Position = UDim2.new(0, 0, 0, 0)
    YesButton.BackgroundColor3 = COLORS.Accent
    YesButton.BorderSizePixel = 0
    YesButton.Text = "Yes"
    YesButton.TextColor3 = Color3.fromRGB(255, 255, 255)
    YesButton.TextSize = 15
    YesButton.Font = Enum.Font.GothamBold
    YesButton.AutoButtonColor = false
    YesButton.Parent = ButtonContainer

    AddCorner(YesButton, 8)

    local NoButton = Instance.new("TextButton")
    NoButton.Name = "No"
    NoButton.Size = UDim2.new(0.48, 0, 1, 0)
    NoButton.Position = UDim2.new(0.52, 0, 0, 0)
    NoButton.BackgroundColor3 = COLORS.Button
    NoButton.BorderSizePixel = 0
    NoButton.Text = "No"
    NoButton.TextColor3 = COLORS.Text
    NoButton.TextSize = 15
    NoButton.Font = Enum.Font.GothamBold
    NoButton.AutoButtonColor = false
    NoButton.Parent = ButtonContainer

    AddCorner(NoButton, 8)
    AddStroke(NoButton, COLORS.Accent, 1, 0.7)

    YesButton.MouseEnter:Connect(function()
        CreateTween(YesButton, {BackgroundColor3 = COLORS.AccentHover}, 0.2):Play()
    end)

    YesButton.MouseLeave:Connect(function()
        CreateTween(YesButton, {BackgroundColor3 = COLORS.Accent}, 0.2):Play()
    end)

    NoButton.MouseEnter:Connect(function()
        CreateTween(NoButton, {BackgroundColor3 = COLORS.ButtonHover}, 0.2):Play()
    end)

    NoButton.MouseLeave:Connect(function()
        CreateTween(NoButton, {BackgroundColor3 = COLORS.Button}, 0.2):Play()
    end)

    CreateTween(Overlay, {BackgroundTransparency = 0.4}, 0.3):Play()
    CreateTween(PromptFrame, {BackgroundTransparency = 0.15}, 0.4):Play()

    wait(0.1)
    PromptFrame.Size = UDim2.new(0, 0, 0, 0)
    PromptFrame.BackgroundTransparency = 0.15
    CreateTween(PromptFrame, {Size = UDim2.new(0, 400, 0, 250)}, 0.5, Enum.EasingStyle.Back):Play()

    YesButton.MouseButton1Click:Connect(function()
        self:LoadMainUI(ScreenGui)
    end)

    NoButton.MouseButton1Click:Connect(function()
        CreateTween(PromptFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In):Play()
        CreateTween(Overlay, {BackgroundTransparency = 1}, 0.3):Play()
        wait(0.3)
        ScreenGui:Destroy()
    end)
end

function Viper:LoadMainUI(promptGui)
    local PromptFrame = promptGui.Overlay.PromptFrame

    CreateTween(PromptFrame, {Size = UDim2.new(0, 0, 0, 0)}, 0.3, Enum.EasingStyle.Back, Enum.EasingDirection.In):Play()
    CreateTween(promptGui.Overlay, {BackgroundTransparency = 1}, 0.3):Play()
    wait(0.35)
    promptGui:Destroy()

    local MainGui = Instance.new("ScreenGui")
    MainGui.Name = "ViperHub"
    MainGui.ZIndexBehavior = Enum.ZIndexBehavior.Sibling
    MainGui.Parent = CoreGui

    local MainFrame = Instance.new("Frame")
    MainFrame.Name = "MainFrame"
    MainFrame.Size = UDim2.new(0, 700, 0, 450)
    MainFrame.Position = UDim2.new(0.5, 0, 0.5, 0)
    MainFrame.AnchorPoint = Vector2.new(0.5, 0.5)
    MainFrame.BackgroundColor3 = COLORS.Background
    MainFrame.BackgroundTransparency = 0.1
    MainFrame.BorderSizePixel = 0
    MainFrame.ClipsDescendants = true
    MainFrame.Parent = MainGui

    AddCorner(MainFrame, 12)
    AddStroke(MainFrame, COLORS.Accent, 1, 0.6)

    local Sidebar = Instance.new("Frame")
    Sidebar.Name = "Sidebar"
    Sidebar.Size = UDim2.new(0, 180, 1, 0)
    Sidebar.Position = UDim2.new(0, 0, 0, 0)
    Sidebar.BackgroundColor3 = COLORS.Sidebar
    Sidebar.BackgroundTransparency = 0.2
    Sidebar.BorderSizePixel = 0
    Sidebar.Parent = MainFrame

    local SidebarCorner = AddCorner(Sidebar, 12)

    local Header = Instance.new("Frame")
    Header.Name = "Header"
    Header.Size = UDim2.new(1, 0, 0, 80)
    Header.Position = UDim2.new(0, 0, 0, 0)
    Header.BackgroundTransparency = 1
    Header.Parent = Sidebar

    local HeaderIcon = Instance.new("ImageLabel")
    HeaderIcon.Name = "Icon"
    HeaderIcon.Size = UDim2.new(0, 50, 0, 50)
    HeaderIcon.Position = UDim2.new(0.5, 0, 0, 15)
    HeaderIcon.AnchorPoint = Vector2.new(0.5, 0)
    HeaderIcon.BackgroundColor3 = COLORS.Background
    HeaderIcon.BackgroundTransparency = 0.3
    HeaderIcon.BorderSizePixel = 0
    HeaderIcon.Image = self.IconAsset
    HeaderIcon.Parent = Header

    AddCorner(HeaderIcon, 25)
    AddStroke(HeaderIcon, COLORS.Accent, 2, 0.5)

    local HeaderTitle = Instance.new("TextLabel")
    HeaderTitle.Name = "Title"
    HeaderTitle.Size = UDim2.new(0.9, 0, 0, 20)
    HeaderTitle.Position = UDim2.new(0.5, 0, 1, -25)
    HeaderTitle.AnchorPoint = Vector2.new(0.5, 0)
    HeaderTitle.BackgroundTransparency = 1
    HeaderTitle.Text = self.GameInfo.Name
    HeaderTitle.TextColor3 = COLORS.Text
    HeaderTitle.TextSize = 13
    HeaderTitle.Font = Enum.Font.GothamBold
    HeaderTitle.TextTruncate = Enum.TextTruncate.AtEnd
    HeaderTitle.Parent = Header

    local Divider = Instance.new("Frame")
    Divider.Name = "Divider"
    Divider.Size = UDim2.new(0.8, 0, 0, 1)
    Divider.Position = UDim2.new(0.5, 0, 0, 85)
    Divider.AnchorPoint = Vector2.new(0.5, 0)
    Divider.BackgroundColor3 = COLORS.Accent
    Divider.BackgroundTransparency = 0.7
    Divider.BorderSizePixel = 0
    Divider.Parent = Sidebar

    local ContentArea = Instance.new("Frame")
    ContentArea.Name = "Content"
    ContentArea.Size = UDim2.new(1, -180, 1, 0)
    ContentArea.Position = UDim2.new(0, 180, 0, 0)
    ContentArea.BackgroundTransparency = 1
    ContentArea.Parent = MainFrame

    MainFrame.Size = UDim2.new(0, 0, 0, 0)
    CreateTween(MainFrame, {Size = UDim2.new(0, 700, 0, 450)}, 0.5, Enum.EasingStyle.Back):Play()

    self.Loaded = true
    self.MainGui = MainGui
    self.MainFrame = MainFrame
    self.Sidebar = Sidebar
    self.ContentArea = ContentArea

    self:MakeDraggable(MainFrame)
end

function Viper:MakeDraggable(frame)
    local dragging = false
    local dragInput, mousePos, framePos

    frame.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 then
            dragging = true
            mousePos = input.Position
            framePos = frame.Position

            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    frame.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - mousePos
            CreateTween(frame, {
                Position = UDim2.new(
                    framePos.X.Scale,
                    framePos.X.Offset + delta.X,
                    framePos.Y.Scale,
                    framePos.Y.Offset + delta.Y
                )
            }, 0.1, Enum.EasingStyle.Linear):Play()
        end
    end)
end

return Viper
