-- [[ JOSEPEDOV18: GRAVITY DRIVE ]] --
-- Features: Artificial Gravity Physics, Massless Acceleration, Traffic Jammer
-- Optimized for Delta | Fixes "Stuck in 1st Gear" by preserving Wheel Speed

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- === CONFIGURATION ===
local Config = {
    SpeedEnabled = false,
    TrafficBlocked = false,
    Downforce = 1000,   -- Artificial Gravity (Keeps car on road)
    ForwardForce = 5000, -- Extra Push (Adjust if too fast)
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
ScreenGui.Name = "JOSEPEDOV18_UI"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 220)
MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20) -- Dark Slate
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(255, 165, 0) -- Orange Theme
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Text = "JOSEPEDOV18"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 165, 0)
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
        TrafficBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        local event = ReplicatedStorage:FindFirstChild("CreateNPCVehicle")
        if event then
            for _, connection in pairs(getconnections(event.OnClientEvent)) do
                connection:Enable()
            end
        end
    end
end)

-- [BUTTON] 2. GRAVITY DRIVE (The Fix)
local SpeedBtn = Instance.new("TextButton")
SpeedBtn.Size = UDim2.new(0.9, 0, 0, 40)
SpeedBtn.Position = UDim2.new(0.05, 0, 0.45, 0)
SpeedBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SpeedBtn.Text = "🚀 Gravity Drive: OFF"
SpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBtn.Font = Enum.Font.GothamBold
SpeedBtn.TextSize = 14
SpeedBtn.Parent = MainFrame
Instance.new("UICorner", SpeedBtn).CornerRadius = UDim.new(0, 6)

SpeedBtn.MouseButton1Click:Connect(function()
    Config.SpeedEnabled = not Config.SpeedEnabled
    if Config.SpeedEnabled then
        SpeedBtn.Text = "🚀 Gravity Drive: ON"
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(255, 165, 0)
        SpeedBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    else
        SpeedBtn.Text = "🚀 Gravity Drive: OFF"
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        SpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        
        -- Restore Mass
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") and char.Humanoid.SeatPart then
            local car = char.Humanoid.SeatPart.Parent
            for _, part in pairs(car:GetDescendants()) do
                if part:IsA("BasePart") then part.Massless = false end
            end
        end
    end
end)

-- [BUTTON] 3. EMERGENCY RESET
local ResetBtn = Instance.new("TextButton")
ResetBtn.Size = UDim2.new(0.9, 0, 0, 40)
ResetBtn.Position = UDim2.new(0.05, 0, 0.70, 0)
ResetBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ResetBtn.Text = "⚠️ RESET PHYSICS"
ResetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ResetBtn.Font = Enum.Font.GothamBold
ResetBtn.TextSize = 14
ResetBtn.Parent = MainFrame
Instance.new("UICorner", ResetBtn).CornerRadius = UDim.new(0, 6)

ResetBtn.MouseButton1Click:Connect(function()
    Config.SpeedEnabled = false
    SpeedBtn.Text = "🚀 Gravity Drive: OFF"
    SpeedBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") and char.Humanoid.SeatPart then
        local seat = char.Humanoid.SeatPart
        -- Destroy Artificial Gravity Forces
        if seat:FindFirstChild("J18_Grav") then seat.J18_Grav:Destroy() end
        if seat:FindFirstChild("J18_Push") then seat.J18_Push:Destroy() end
        if seat:FindFirstChild("J18_Att") then seat.J18_Att:Destroy() end
        
        -- Restore Mass
        local car = seat.Parent
        for _, part in pairs(car:GetDescendants()) do
            if part:IsA("BasePart") then part.Massless = false end
        end
    end
end)

-- === PHYSICS LOOP ===
RunService.Heartbeat:Connect(function()
    if not Config.SpeedEnabled then return end
    
    local char = player.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid or not humanoid.SeatPart then return end
    
    local seat = humanoid.SeatPart
    local car = seat.Parent
    
    -- 1. MAKE CAR WEIGHTLESS (Every frame to fight resets)
    for _, part in pairs(car:GetDescendants()) do
        if part:IsA("BasePart") then
            part.Massless = true
        end
    end
    
    -- 2. SETUP ARTIFICIAL FORCES
    local att = seat:FindFirstChild("J18_Att")
    local gravForce = seat:FindFirstChild("J18_Grav")
    local pushForce = seat:FindFirstChild("J18_Push")
    
    if not att then
        att = Instance.new("Attachment", seat)
        att.Name = "J18_Att"
        
        -- Artificial Gravity (Always Down relative to World)
        gravForce = Instance.new("VectorForce")
        gravForce.Name = "J18_Grav"
        gravForce.Attachment0 = att
        gravForce.RelativeTo = Enum.ActuatorRelativeTo.World 
        gravForce.Parent = seat
        
        -- Artificial Engine (Always Forward relative to Car)
        pushForce = Instance.new("VectorForce")
        pushForce.Name = "J18_Push"
        pushForce.Attachment0 = att
        pushForce.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
        pushForce.Parent = seat
    end
    
    -- 3. APPLY FORCES
    -- Apply Downforce (Simulate Gravity so we don't fly)
    gravForce.Force = Vector3.new(0, -Config.Downforce, 0)
    
    -- Apply Push (Assisted Acceleration)
    if seat.Throttle > 0 then
        pushForce.Force = Vector3.new(0, 0, -Config.ForwardForce) -- Push Forward
    elseif seat.Throttle < 0 then
        pushForce.Force = Vector3.new(0, 0, Config.ForwardForce) -- Brake/Reverse
    else
        pushForce.Force = Vector3.new(0, 0, 0)
    end
end)

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(0.85, 0, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.Parent = MainFrame
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
