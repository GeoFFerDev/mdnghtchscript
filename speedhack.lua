-- [[ JOSEPEDOV14: REALISTIC TUNE ]] --
-- Features: Optimized "Dragster" Stats, Traffic Disconnector, Smooth Assist
-- Optimized for Delta | Values tuned for stability

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- === CONFIGURATION ===
local Config = {
    SpeedEnabled = false,
    TrafficBlocked = false,
    -- "Realistic" Cheat Values
    TargetHP = 3500,       -- High end dragster (Stable)
    TargetTorque = 2500,   -- Instant acceleration
    TargetBoost = 100,     -- 100 PSI (High but valid)
    AssistPower = 12000,   -- VectorForce (Smooth push)
}

-- === UI CREATION ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JOSEPEDOV14_UI"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 220)
MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 25, 30) -- Slate Blue
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(255, 255, 255)
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

-- Title
local Title = Instance.new("TextLabel")
Title.Text = "JOSEPEDOV14"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 18
Title.Parent = MainFrame

-- [BUTTON] 1. KILL TRAFFIC
local TrafficBtn = Instance.new("TextButton")
TrafficBtn.Size = UDim2.new(0.9, 0, 0, 40)
TrafficBtn.Position = UDim2.new(0.05, 0, 0.20, 0)
TrafficBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
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
        TrafficBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        
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
        TrafficBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
        local event = ReplicatedStorage:FindFirstChild("CreateNPCVehicle")
        if event then
            for _, connection in pairs(getconnections(event.OnClientEvent)) do
                connection:Enable()
            end
        end
    end
end)

-- [BUTTON] 2. SMART TUNER (Realistic)
local TuneBtn = Instance.new("TextButton")
TuneBtn.Size = UDim2.new(0.9, 0, 0, 40)
TuneBtn.Position = UDim2.new(0.05, 0, 0.45, 0)
TuneBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
TuneBtn.Text = "🔧 Apply Sport Tune: OFF"
TuneBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TuneBtn.Font = Enum.Font.GothamBold
TuneBtn.TextSize = 14
TuneBtn.Parent = MainFrame
Instance.new("UICorner", TuneBtn).CornerRadius = UDim.new(0, 6)

TuneBtn.MouseButton1Click:Connect(function()
    Config.SpeedEnabled = not Config.SpeedEnabled
    if Config.SpeedEnabled then
        TuneBtn.Text = "🔧 Apply Sport Tune: ON"
        TuneBtn.BackgroundColor3 = Color3.fromRGB(0, 180, 100)
    else
        TuneBtn.Text = "🔧 Apply Sport Tune: OFF"
        TuneBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end
end)

-- [BUTTON] 3. SMOOTH ASSIST (VectorForce)
local AssistBtn = Instance.new("TextButton")
AssistBtn.Size = UDim2.new(0.9, 0, 0, 40)
AssistBtn.Position = UDim2.new(0.05, 0, 0.70, 0)
AssistBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
AssistBtn.Text = "🚀 Smooth Assist: OFF"
AssistBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AssistBtn.Font = Enum.Font.GothamBold
AssistBtn.TextSize = 14
AssistBtn.Parent = MainFrame
Instance.new("UICorner", AssistBtn).CornerRadius = UDim.new(0, 6)

local assistEnabled = false
AssistBtn.MouseButton1Click:Connect(function()
    assistEnabled = not assistEnabled
    if assistEnabled then
        AssistBtn.Text = "🚀 Smooth Assist: ON"
        AssistBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
    else
        AssistBtn.Text = "🚀 Smooth Assist: OFF"
        AssistBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end
end)

-- === LOGIC LOOPS ===

-- 1. REALISTIC VALUES (Runs every frame to fight resets)
RunService.RenderStepped:Connect(function()
    if not Config.SpeedEnabled then return end
    
    local char = player.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid or not humanoid.SeatPart then return end
    
    local car = humanoid.SeatPart.Parent
    local carVal = car:FindFirstChild("Car") and car.Car.Value or car
    local valuesFolder = carVal:FindFirstChild("Values") or car:FindFirstChild("Values")
    
    -- Set Values to "High Performance" but not "Glitch" levels
    if valuesFolder then
        local torque = valuesFolder:FindFirstChild("Torque")
        local hp = valuesFolder:FindFirstChild("Horsepower")
        local boost = valuesFolder:FindFirstChild("BoostTurbo")
        local maxSpeed = valuesFolder:FindFirstChild("MaxSpeed")
        
        -- 3500 HP is enough to hit 300+ MPH smoothly
        if torque then torque.Value = Config.TargetTorque end
        if hp then hp.Value = Config.TargetHP end
        if boost then boost.Value = Config.TargetBoost end
        if maxSpeed then maxSpeed.Value = 450 end -- Cap at 450 MPH for stability
    end
    
    -- Sync Attributes
    carVal:SetAttribute("Torque", Config.TargetTorque)
    carVal:SetAttribute("Horsepower", Config.TargetHP)
    carVal:SetAttribute("MaxBoost", Config.TargetBoost)
end)

-- 2. SMOOTH VECTOR ASSIST
RunService.Heartbeat:Connect(function()
    if not assistEnabled then return end
    
    local char = player.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid or not humanoid.SeatPart then return end
    local seat = humanoid.SeatPart
    
    local vf = seat:FindFirstChild("J14_Assist")
    local att = seat:FindFirstChild("J14_Att")
    
    if not vf then
        att = Instance.new("Attachment", seat)
        att.Name = "J14_Att"
        
        vf = Instance.new("VectorForce")
        vf.Name = "J14_Assist"
        vf.Attachment0 = att
        vf.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
        vf.Parent = seat
    end
    
    -- Apply "Realistic" Force (12,000 is like a strong engine push)
    if seat.Throttle > 0 then
        vf.Force = Vector3.new(0, 0, -Config.AssistPower) 
    elseif seat.Throttle < 0 then
        vf.Force = Vector3.new(0, 0, Config.AssistPower)
    else
        vf.Force = Vector3.new(0, 0, 0)
    end
end)

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(0.85, 0, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Parent = MainFrame
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
