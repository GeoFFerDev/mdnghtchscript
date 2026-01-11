-- [[ JOSEPEDOV30: THE ROCKET THRUSTER ]] --
-- Features: VectorForce Propulsion, Visual Status Debug, Traffic Jammer
-- Optimized for Delta | Bypasses Engine by pushing the physical model

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- === CONFIGURATION ===
local Config = {
    SpeedEnabled = false,
    TrafficBlocked = false,
    BoostPower = 50000, -- Starting Power (Adjustable)
}

-- === 1. TRAFFIC JAMMER (Working) ===
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
ScreenGui.Name = "JOSEPEDOV30_UI"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 280)
MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 25)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(255, 100, 0) -- Orange
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Text = "JOSEPEDOV30"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 100, 0)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 18
Title.Parent = MainFrame

-- [STATUS LABEL] (Debug)
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Text = "STATUS: WAITING..."
StatusLabel.Size = UDim2.new(0.9, 0, 0, 30)
StatusLabel.Position = UDim2.new(0.05, 0, 0.15, 0)
StatusLabel.BackgroundColor3 = Color3.fromRGB(0, 0, 0)
StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
StatusLabel.Font = Enum.Font.Code
StatusLabel.TextSize = 14
StatusLabel.Parent = MainFrame

-- [BUTTON] 1. KILL TRAFFIC
local TrafficBtn = Instance.new("TextButton")
TrafficBtn.Size = UDim2.new(0.9, 0, 0, 40)
TrafficBtn.Position = UDim2.new(0.05, 0, 0.30, 0)
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

-- [CONTROLS] POWER ADJUSTER
local PowerLabel = Instance.new("TextLabel")
PowerLabel.Text = "Thruster Power: 50,000"
PowerLabel.Size = UDim2.new(0.9, 0, 0, 20)
PowerLabel.Position = UDim2.new(0.05, 0, 0.50, 0)
PowerLabel.BackgroundTransparency = 1
PowerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
PowerLabel.Font = Enum.Font.GothamBold
PowerLabel.TextSize = 12
PowerLabel.Parent = MainFrame

local MinusBtn = Instance.new("TextButton")
MinusBtn.Text = "-"
MinusBtn.Size = UDim2.new(0.4, 0, 0, 30)
MinusBtn.Position = UDim2.new(0.05, 0, 0.60, 0)
MinusBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MinusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinusBtn.Parent = MainFrame

local PlusBtn = Instance.new("TextButton")
PlusBtn.Text = "+"
PlusBtn.Size = UDim2.new(0.4, 0, 0, 30)
PlusBtn.Position = UDim2.new(0.55, 0, 0.60, 0)
PlusBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
PlusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PlusBtn.Parent = MainFrame

MinusBtn.MouseButton1Click:Connect(function()
    Config.BoostPower = math.max(10000, Config.BoostPower - 10000)
    PowerLabel.Text = "Thruster Power: " .. Config.BoostPower
end)

PlusBtn.MouseButton1Click:Connect(function()
    Config.BoostPower = Config.BoostPower + 10000
    PowerLabel.Text = "Thruster Power: " .. Config.BoostPower
end)

-- [BUTTON] 2. ACTIVATE ROCKET
local BoostBtn = Instance.new("TextButton")
BoostBtn.Size = UDim2.new(0.9, 0, 0, 50)
BoostBtn.Position = UDim2.new(0.05, 0, 0.75, 0)
BoostBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
BoostBtn.Text = "🚀 ROCKET BOOST: OFF"
BoostBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
BoostBtn.Font = Enum.Font.GothamBold
BoostBtn.TextSize = 14
BoostBtn.Parent = MainFrame
Instance.new("UICorner", BoostBtn).CornerRadius = UDim.new(0, 6)

BoostBtn.MouseButton1Click:Connect(function()
    Config.SpeedEnabled = not Config.SpeedEnabled
    if Config.SpeedEnabled then
        BoostBtn.Text = "🚀 ROCKET BOOST: ON"
        BoostBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0)
    else
        BoostBtn.Text = "🚀 ROCKET BOOST: OFF"
        BoostBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        StatusLabel.Text = "STATUS: OFF"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end)

-- === PHYSICS LOOP (Heartbeat) ===
RunService.Heartbeat:Connect(function()
    if not Config.SpeedEnabled then return end
    
    local char = player.Character
    if not char then 
        StatusLabel.Text = "STATUS: NO CHAR"
        StatusLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
        return 
    end
    
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid or not humanoid.SeatPart then 
        StatusLabel.Text = "STATUS: SIT IN CAR"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 255, 0) -- Yellow
        return 
    end
    
    local seat = humanoid.SeatPart
    
    -- CHECK INPUT (Gas Pedal)
    if seat.Throttle > 0 then
        StatusLabel.Text = "STATUS: BOOSTING!"
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0) -- Green
        
        -- APPLY VECTOR FORCE
        -- 1. Create Attachment/Force if missing
        local att = seat:FindFirstChild("J30_Att")
        local thrust = seat:FindFirstChild("J30_Thrust")
        
        if not att then
            att = Instance.new("Attachment", seat)
            att.Name = "J30_Att"
        end
        
        if not thrust then
            thrust = Instance.new("VectorForce", seat)
            thrust.Name = "J30_Thrust"
            thrust.Attachment0 = att
            thrust.RelativeTo = Enum.ActuatorRelativeTo.Attachment0 -- Push relative to car
        end
        
        -- 2. PUSH FORWARD
        -- Z-Axis is usually forward/backward. 
        -- Negative Z (-Config.BoostPower) is usually FORWARD for cars.
        thrust.Force = Vector3.new(0, 0, -Config.BoostPower) 
        
    elseif seat.Throttle < 0 then
        StatusLabel.Text = "STATUS: BRAKING"
        StatusLabel.TextColor3 = Color3.fromRGB(255, 0, 0) -- Red
        
        -- Reverse/Brake Force
        local att = seat:FindFirstChild("J30_Att")
        local thrust = seat:FindFirstChild("J30_Thrust")
        if thrust then thrust.Force = Vector3.new(0, 0, Config.BoostPower) end
        
    else
        StatusLabel.Text = "STATUS: IDLE"
        StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200) -- Grey
        
        -- Remove Force when not pressing keys
        local thrust = seat:FindFirstChild("J30_Thrust")
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
