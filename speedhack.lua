-- [[ JOSEPEDOV40: BACK TO BASICS ]] --
-- Features: Velocity Multiplication, Natural Deceleration, Simple UI
-- Optimized for Delta | No stuck throttle, No complex buttons

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- === CONFIGURATION ===
local Config = {
    Enabled = false,
    Multiplier = 1.05, -- 5% Boost per frame (Adjustable)
    MaxSpeed = 800     -- Cap to prevent crashing
}

-- === UI CREATION ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JOSEPEDOV40_UI"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 200, 0, 140)
MainFrame.Position = UDim2.new(0.1, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 0) -- Green
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Text = "J40: SIMPLE SPEED"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(0, 255, 0)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 16
Title.Parent = MainFrame

-- [BUTTON] TOGGLE
local ToggleBtn = Instance.new("TextButton")
ToggleBtn.Size = UDim2.new(0.9, 0, 0, 40)
ToggleBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ToggleBtn.Text = "SPEED HACK: OFF"
ToggleBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ToggleBtn.Font = Enum.Font.GothamBold
ToggleBtn.TextSize = 14
ToggleBtn.Parent = MainFrame
Instance.new("UICorner", ToggleBtn).CornerRadius = UDim.new(0, 6)

ToggleBtn.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    if Config.Enabled then
        ToggleBtn.Text = "SPEED HACK: ON"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0)
    else
        ToggleBtn.Text = "SPEED HACK: OFF"
        ToggleBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end
end)

-- [CONTROLS] INTENSITY
local PowerLabel = Instance.new("TextLabel")
PowerLabel.Text = "Intensity: 5%"
PowerLabel.Size = UDim2.new(1, 0, 0, 20)
PowerLabel.Position = UDim2.new(0, 0, 0.55, 0)
PowerLabel.BackgroundTransparency = 1
PowerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
PowerLabel.Font = Enum.Font.GothamBold
PowerLabel.TextSize = 12
PowerLabel.Parent = MainFrame

local MinusBtn = Instance.new("TextButton")
MinusBtn.Text = "-"
MinusBtn.Size = UDim2.new(0.4, 0, 0, 30)
MinusBtn.Position = UDim2.new(0.05, 0, 0.70, 0)
MinusBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MinusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinusBtn.Parent = MainFrame
Instance.new("UICorner", MinusBtn).CornerRadius = UDim.new(0, 6)

local PlusBtn = Instance.new("TextButton")
PlusBtn.Text = "+"
PlusBtn.Size = UDim2.new(0.4, 0, 0, 30)
PlusBtn.Position = UDim2.new(0.55, 0, 0.70, 0)
PlusBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
PlusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PlusBtn.Parent = MainFrame
Instance.new("UICorner", PlusBtn).CornerRadius = UDim.new(0, 6)

MinusBtn.MouseButton1Click:Connect(function()
    Config.Multiplier = math.max(1.01, Config.Multiplier - 0.01)
    PowerLabel.Text = "Intensity: " .. math.floor((Config.Multiplier - 1)*100) .. "%"
end)

PlusBtn.MouseButton1Click:Connect(function()
    Config.Multiplier = math.min(1.50, Config.Multiplier + 0.01)
    PowerLabel.Text = "Intensity: " .. math.floor((Config.Multiplier - 1)*100) .. "%"
end)

-- Minimize Button
local MinBtn = Instance.new("TextButton")
MinBtn.Text = "-"
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(0.70, 0, 0, 0)
MinBtn.BackgroundTransparency = 1
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 24
MinBtn.Parent = MainFrame
MinBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(0.85, 0, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.Parent = MainFrame
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- === PHYSICS LOOP ===
RunService.Heartbeat:Connect(function()
    if not Config.Enabled then return end
    
    local char = player.Character
    if not char then return end
    
    -- Auto-Find Car
    local driveSeat = nil
    local humanoid = char:FindFirstChild("Humanoid")
    
    if humanoid and humanoid.SeatPart then
        driveSeat = humanoid.SeatPart
    else
        local carModel = Workspace:FindFirstChild("Lf20Besaya's Car")
        if carModel then driveSeat = carModel:FindFirstChild("DriveSeat") end
    end
    
    if not driveSeat then return end
    
    -- === THE SIMPLE LOGIC ===
    -- 1. Get Current Speed
    local currentVel = driveSeat.AssemblyLinearVelocity
    local speed = currentVel.Magnitude
    
    -- 2. Only boost if moving (Prevents stuck throttle)
    -- If speed is less than 5, we assume you are trying to stop, so we do nothing.
    if speed > 5 and speed < Config.MaxSpeed then
        
        -- 3. Multiply Speed (X and Z only, leave Gravity Y alone)
        driveSeat.AssemblyLinearVelocity = Vector3.new(
            currentVel.X * Config.Multiplier,
            currentVel.Y, 
            currentVel.Z * Config.Multiplier
        )
    end
end)
