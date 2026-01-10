-- [[ JOSEPEDOV15: WEIGHTLESS SPEED ]] --
-- Features: Massless Body, Super Grip Tires, Traffic Jammer
-- Optimized for Delta | Bypass by modifying Physics instead of Values

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- === CONFIGURATION ===
local Config = {
    SpeedEnabled = false,
    TrafficBlocked = false,
    GravityHack = false,
    OriginalGravity = Workspace.Gravity
}

-- === TRAFFIC JAMMER (KEEPING THIS!) ===
local function InstallTrafficHook()
    local event = ReplicatedStorage:FindFirstChild("CreateNPCVehicle")
    if event then
        for _, connection in pairs(getconnections(event.OnClientEvent)) do
            local oldFunction = connection.Function
            if oldFunction then
                hookfunction(connection.Function, function(...)
                    if Config.TrafficBlocked then return end
                    return oldFunction(...)
                end)
            end
        end
    end
end
InstallTrafficHook()

-- === UI CREATION ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JOSEPEDOV15_UI"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 220)
MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 0) -- Matrix Green
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Text = "JOSEPEDOV15"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(0, 255, 0)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 18
Title.Parent = MainFrame

-- [BUTTON] 1. KILL TRAFFIC
local TrafficBtn = Instance.new("TextButton")
TrafficBtn.Size = UDim2.new(0.9, 0, 0, 40)
TrafficBtn.Position = UDim2.new(0.05, 0, 0.20, 0)
TrafficBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TrafficBtn.Text = "🚫 Kill Traffic Signal"
TrafficBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TrafficBtn.Font = Enum.Font.GothamBold
TrafficBtn.TextSize = 14
TrafficBtn.Parent = MainFrame
Instance.new("UICorner", TrafficBtn).CornerRadius = UDim.new(0, 6)

TrafficBtn.MouseButton1Click:Connect(function()
    Config.TrafficBlocked = not Config.TrafficBlocked
    if Config.TrafficBlocked then
        TrafficBtn.Text = "Traffic: DEAD 💀"
        TrafficBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        local event = ReplicatedStorage:FindFirstChild("CreateNPCVehicle")
        if event then
            for _, connection in pairs(getconnections(event.OnClientEvent)) do
                connection:Disable()
            end
        end
        local npcFolder = Workspace:FindFirstChild("NPCVehicles") or Workspace:FindFirstChild("Traffic")
        if npcFolder then npcFolder:ClearAllChildren() end
    else
        TrafficBtn.Text = "Traffic: ALLOWED"
        TrafficBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        local event = ReplicatedStorage:FindFirstChild("CreateNPCVehicle")
        if event then
            for _, connection in pairs(getconnections(event.OnClientEvent)) do
                connection:Enable()
            end
        end
    end
end)

-- [BUTTON] 2. WEIGHT REDUCTION (Massless Mode)
local WeightBtn = Instance.new("TextButton")
WeightBtn.Size = UDim2.new(0.9, 0, 0, 40)
WeightBtn.Position = UDim2.new(0.05, 0, 0.45, 0)
WeightBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
WeightBtn.Text = "🪶 Massless Mode: OFF"
WeightBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
WeightBtn.Font = Enum.Font.GothamBold
WeightBtn.TextSize = 14
WeightBtn.Parent = MainFrame
Instance.new("UICorner", WeightBtn).CornerRadius = UDim.new(0, 6)

WeightBtn.MouseButton1Click:Connect(function()
    Config.SpeedEnabled = not Config.SpeedEnabled
    if Config.SpeedEnabled then
        WeightBtn.Text = "🪶 Massless Mode: ON"
        WeightBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 255)
    else
        WeightBtn.Text = "🪶 Massless Mode: OFF"
        WeightBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        -- Reset Gravity
        Workspace.Gravity = Config.OriginalGravity
    end
end)

-- [BUTTON] 3. SUPER GRIP (Tire Hack)
local GripBtn = Instance.new("TextButton")
GripBtn.Size = UDim2.new(0.9, 0, 0, 40)
GripBtn.Position = UDim2.new(0.05, 0, 0.70, 0)
GripBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
GripBtn.Text = "🍩 Super Grip: OFF"
GripBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GripBtn.Font = Enum.Font.GothamBold
GripBtn.TextSize = 14
GripBtn.Parent = MainFrame
Instance.new("UICorner", GripBtn).CornerRadius = UDim.new(0, 6)

GripBtn.MouseButton1Click:Connect(function()
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") and char.Humanoid.SeatPart then
        local car = char.Humanoid.SeatPart.Parent
        
        -- Find Wheels and set friction to MAX
        for _, part in pairs(car:GetDescendants()) do
            if part:IsA("BasePart") then
                -- Check if it's a wheel
                if part.Name == "FL" or part.Name == "FR" or part.Name == "RL" or part.Name == "RR" or part.Name:lower():match("wheel") then
                    part.CustomPhysicalProperties = PhysicalProperties.new(10, 5, 0, 100, 100) -- Density, Friction, Elasticity...
                end
            end
        end
        GripBtn.Text = "🍩 Grip Applied!"
        task.wait(1)
        GripBtn.Text = "🍩 Super Grip: OFF"
    else
        GripBtn.Text = "⚠️ Sit in Seat"
    end
end)


-- === PHYSICS LOOP ===
-- This forces the car to be weightless constantly
RunService.Stepped:Connect(function()
    if not Config.SpeedEnabled then return end
    
    local char = player.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid or not humanoid.SeatPart then return end
    
    local car = humanoid.SeatPart.Parent
    
    -- 1. Lower Gravity (Makes engine work less hard)
    Workspace.Gravity = 50 -- Normal is 196.2
    
    -- 2. Massless Body
    for _, part in pairs(car:GetDescendants()) do
        if part:IsA("BasePart") then
            -- We keep wheels heavy so they touch the ground, make body light
            if not (part.Name == "FL" or part.Name == "FR" or part.Name == "RL" or part.Name == "RR") then
                part.Massless = true
            end
        end
    end
end)

-- Minimize Logic
local MinBtn = Instance.new("TextButton")
MinBtn.Text = "-"
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(0.70, 0, 0, 0)
MinBtn.BackgroundTransparency = 1
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Parent = MainFrame
MinBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

-- Close
local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(0.85, 0, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.Parent = MainFrame
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy(); Workspace.Gravity = Config.OriginalGravity end)
