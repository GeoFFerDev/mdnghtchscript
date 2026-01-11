-- [[ JOSEPEDOV31: MANUAL ROCKET ]] --
-- Features: Touch/Click Boost Button, Traffic Jammer, Direct Physics Force
-- Optimized for Delta | Fixes "Idle" bug by using a manual button

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- === CONFIGURATION ===
local Config = {
    TrafficBlocked = false,
    BoostPower = 80000, -- 80k Newtons (Very Strong)
    IsBoosting = false  -- Controlled by button
}

-- === 1. TRAFFIC JAMMER ===
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
ScreenGui.Name = "JOSEPEDOV31_UI"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 300) -- Taller for big button
MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0) -- Red
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Text = "JOSEPEDOV31"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 0, 0)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 18
Title.Parent = MainFrame

-- [STATUS LABEL]
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Text = "STATUS: READY"
StatusLabel.Size = UDim2.new(0.9, 0, 0, 20)
StatusLabel.Position = UDim2.new(0.05, 0, 0.12, 0)
StatusLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
StatusLabel.Font = Enum.Font.Code
StatusLabel.TextSize = 14
StatusLabel.Parent = MainFrame

-- [BUTTON] 1. KILL TRAFFIC
local TrafficBtn = Instance.new("TextButton")
TrafficBtn.Size = UDim2.new(0.9, 0, 0, 40)
TrafficBtn.Position = UDim2.new(0.05, 0, 0.22, 0)
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

-- [CONTROLS] POWER
local PowerLabel = Instance.new("TextLabel")
PowerLabel.Text = "Power: 80,000"
PowerLabel.Size = UDim2.new(0.9, 0, 0, 20)
PowerLabel.Position = UDim2.new(0.05, 0, 0.40, 0)
PowerLabel.BackgroundTransparency = 1
PowerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
PowerLabel.Font = Enum.Font.GothamBold
PowerLabel.TextSize = 12
PowerLabel.Parent = MainFrame

local MinusBtn = Instance.new("TextButton")
MinusBtn.Text = "-"
MinusBtn.Size = UDim2.new(0.4, 0, 0, 30)
MinusBtn.Position = UDim2.new(0.05, 0, 0.48, 0)
MinusBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MinusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinusBtn.Parent = MainFrame

local PlusBtn = Instance.new("TextButton")
PlusBtn.Text = "+"
PlusBtn.Size = UDim2.new(0.4, 0, 0, 30)
PlusBtn.Position = UDim2.new(0.55, 0, 0.48, 0)
PlusBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
PlusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PlusBtn.Parent = MainFrame

MinusBtn.MouseButton1Click:Connect(function()
    Config.BoostPower = math.max(10000, Config.BoostPower - 10000)
    PowerLabel.Text = "Power: " .. Config.BoostPower
end)

PlusBtn.MouseButton1Click:Connect(function()
    Config.BoostPower = Config.BoostPower + 10000
    PowerLabel.Text = "Power: " .. Config.BoostPower
end)

-- [BUTTON] 2. HOLD TO BOOST (The Main Feature)
local BoostBtn = Instance.new("TextButton")
BoostBtn.Size = UDim2.new(0.9, 0, 0, 80) -- Big Button
BoostBtn.Position = UDim2.new(0.05, 0, 0.65, 0)
BoostBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0) -- Dark Red
BoostBtn.Text = "🔥 HOLD TO BOOST 🔥"
BoostBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
BoostBtn.Font = Enum.Font.GothamBlack
BoostBtn.TextSize = 20
BoostBtn.Parent = MainFrame
Instance.new("UICorner", BoostBtn).CornerRadius = UDim.new(0, 12)

-- TOUCH LOGIC (Mobile Friendly)
BoostBtn.MouseButton1Down:Connect(function()
    Config.IsBoosting = true
    BoostBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0) -- Bright Red
    BoostBtn.Text = "🚀 BOOSTING! 🚀"
end)

BoostBtn.MouseButton1Up:Connect(function()
    Config.IsBoosting = false
    BoostBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    BoostBtn.Text = "🔥 HOLD TO BOOST 🔥"
end)

-- Also handle touch leave (finger slides off button)
BoostBtn.MouseLeave:Connect(function()
    Config.IsBoosting = false
    BoostBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
    BoostBtn.Text = "🔥 HOLD TO BOOST 🔥"
end)


-- === PHYSICS LOOP ===
RunService.Heartbeat:Connect(function()
    local char = player.Character
    if not char then return end
    
    -- Target the DriveSeat directly if possible, or Humanoid Seat
    local driveSeat = nil
    
    -- Priority 1: Direct find in Car Model (Lf20Besaya's Car)
    local carModel = Workspace:FindFirstChild("Lf20Besaya's Car")
    if carModel then
        driveSeat = carModel:FindFirstChild("DriveSeat")
    end
    
    -- Priority 2: Fallback to Humanoid Seat
    if not driveSeat then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid and humanoid.SeatPart then
            driveSeat = humanoid.SeatPart
        end
    end
    
    -- If we still don't have a seat, update status
    if not driveSeat then
        if Config.IsBoosting then
            StatusLabel.Text = "ERROR: NO CAR FOUND"
            StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0)
        end
        return
    end

    -- LOGIC
    if Config.IsBoosting then
        StatusLabel.Text = "STATUS: BOOSTING!"
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        
        -- Create/Get Attachment & Force
        local att = driveSeat:FindFirstChild("J31_Att")
        local thrust = driveSeat:FindFirstChild("J31_Thrust")
        
        if not att then
            att = Instance.new("Attachment", driveSeat)
            att.Name = "J31_Att"
        end
        
        if not thrust then
            thrust = Instance.new("VectorForce", driveSeat)
            thrust.Name = "J31_Thrust"
            thrust.Attachment0 = att
            thrust.RelativeTo = Enum.ActuatorRelativeTo.Attachment0 -- Local Space
        end
        
        -- Apply Force (Negative Z = Forward)
        thrust.Force = Vector3.new(0, 0, -Config.BoostPower)
        
    else
        StatusLabel.Text = "STATUS: IDLE"
        StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        
        -- Destroy Force immediately when released
        local thrust = driveSeat:FindFirstChild("J31_Thrust")
        if thrust then thrust:Destroy() end
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
