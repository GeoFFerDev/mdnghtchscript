-- [[ JOSEPEDOV29: VELOCITY AMPLIFIER ]] --
-- Features: Exponential Speed Boost, Traffic Jammer, Adjustable Power
-- Optimized for Delta | Bypasses "Cached Stats" by amplifying physics directly

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- === CONFIGURATION ===
local Config = {
    SpeedEnabled = false,
    TrafficBlocked = false,
    Multiplier = 1.02, -- 2% speed gain per frame (Exponential growth)
    MaxSpeed = 600,    -- Cap speed to prevent crashing game
}

-- === 1. TRAFFIC JAMMER (The Working Hook) ===
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
ScreenGui.Name = "JOSEPEDOV29_UI"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 260)
MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(255, 50, 150) -- Hot Pink
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Text = "JOSEPEDOV29"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 50, 150)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 18
Title.Parent = MainFrame

-- [BUTTON] 1. KILL TRAFFIC
local TrafficBtn = Instance.new("TextButton")
TrafficBtn.Size = UDim2.new(0.9, 0, 0, 40)
TrafficBtn.Position = UDim2.new(0.05, 0, 0.15, 0)
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

-- [CONTROLS] POWER ADJUSTMENT
local PowerLabel = Instance.new("TextLabel")
PowerLabel.Text = "Boost Power: 2%"
PowerLabel.Size = UDim2.new(0.9, 0, 0, 20)
PowerLabel.Position = UDim2.new(0.05, 0, 0.35, 0)
PowerLabel.BackgroundTransparency = 1
PowerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
PowerLabel.Font = Enum.Font.GothamBold
PowerLabel.TextSize = 14
PowerLabel.Parent = MainFrame

local MinusBtn = Instance.new("TextButton")
MinusBtn.Text = "-"
MinusBtn.Size = UDim2.new(0.4, 0, 0, 30)
MinusBtn.Position = UDim2.new(0.05, 0, 0.45, 0)
MinusBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MinusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinusBtn.Parent = MainFrame

local PlusBtn = Instance.new("TextButton")
PlusBtn.Text = "+"
PlusBtn.Size = UDim2.new(0.4, 0, 0, 30)
PlusBtn.Position = UDim2.new(0.55, 0, 0.45, 0)
PlusBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
PlusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PlusBtn.Parent = MainFrame

MinusBtn.MouseButton1Click:Connect(function()
    Config.Multiplier = math.max(1.005, Config.Multiplier - 0.005)
    local percent = math.floor((Config.Multiplier - 1) * 1000) / 10
    PowerLabel.Text = "Boost Power: " .. percent .. "%"
end)

PlusBtn.MouseButton1Click:Connect(function()
    Config.Multiplier = math.min(1.10, Config.Multiplier + 0.005)
    local percent = math.floor((Config.Multiplier - 1) * 1000) / 10
    PowerLabel.Text = "Boost Power: " .. percent .. "%"
end)

-- [BUTTON] 2. ACTIVATE AMPLIFIER
local AmpBtn = Instance.new("TextButton")
AmpBtn.Size = UDim2.new(0.9, 0, 0, 50)
AmpBtn.Position = UDim2.new(0.05, 0, 0.65, 0)
AmpBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
AmpBtn.Text = "🚀 LIMIT BREAKER: OFF"
AmpBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AmpBtn.Font = Enum.Font.GothamBold
AmpBtn.TextSize = 14
AmpBtn.Parent = MainFrame
Instance.new("UICorner", AmpBtn).CornerRadius = UDim.new(0, 6)

AmpBtn.MouseButton1Click:Connect(function()
    Config.SpeedEnabled = not Config.SpeedEnabled
    if Config.SpeedEnabled then
        AmpBtn.Text = "🚀 LIMIT BREAKER: ON"
        AmpBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 100)
    else
        AmpBtn.Text = "🚀 LIMIT BREAKER: OFF"
        AmpBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end
end)

-- === PHYSICS AMPLIFIER LOOP ===
-- This is the core logic. It runs every frame.
RunService.Heartbeat:Connect(function()
    if not Config.SpeedEnabled then return end
    
    local char = player.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid or not humanoid.SeatPart then return end
    
    local seat = humanoid.SeatPart
    local car = seat.Parent
    local root = car.PrimaryPart or seat 
    
    -- ONLY BOOST WHEN HOLDING GAS
    if seat.Throttle > 0 then
        -- 1. Get Current Velocity
        local currentVel = root.AssemblyLinearVelocity
        local speed = currentVel.Magnitude
        
        -- 2. Check if we are below MaxSpeed
        if speed < Config.MaxSpeed then
            -- 3. AMPLIFY
            -- We multiply X and Z (Movement) but keep Y (Gravity) safe
            -- This makes you accelerate 2% faster every single frame.
            -- 100 -> 102 -> 104 -> 106... it grows incredibly fast.
            
            root.AssemblyLinearVelocity = Vector3.new(
                currentVel.X * Config.Multiplier,
                currentVel.Y, -- Keep Gravity normal!
                currentVel.Z * Config.Multiplier
            )
        end
        
    elseif seat.Throttle < 0 then
        -- Optional: Improved Braking
        local currentVel = root.AssemblyLinearVelocity
        root.AssemblyLinearVelocity = Vector3.new(
            currentVel.X * 0.9,
            currentVel.Y, 
            currentVel.Z * 0.9
        )
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
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
