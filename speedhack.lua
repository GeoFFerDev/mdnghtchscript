-- [[ JOSEPEDOV32: THE CRUISER ]] --
-- Features: Fixed 7000 Power, One-Tap Toggle, Traffic Jammer
-- Optimized for Delta | "Sweet Spot" Edition

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- === CONFIGURATION ===
local Config = {
    TrafficBlocked = false,
    BoostPower = 7000,  -- The Sweet Spot
    IsActive = false    -- Toggle State
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
ScreenGui.Name = "JOSEPEDOV32_UI"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 200, 0, 160) -- Very Compact
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0) -- Left side, easy reach
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 100) -- Mint Green
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Text = "J32: CRUISER"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(0, 255, 100)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 16
Title.Parent = MainFrame

-- [BUTTON 1] TRAFFIC
local TrafficBtn = Instance.new("TextButton")
TrafficBtn.Size = UDim2.new(0.9, 0, 0, 40)
TrafficBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
TrafficBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TrafficBtn.Text = "🚫 Kill Traffic"
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

-- [BUTTON 2] ROCKET TOGGLE (The Main Control)
local BoostBtn = Instance.new("TextButton")
BoostBtn.Size = UDim2.new(0.9, 0, 0, 60) -- Big Target
BoostBtn.Position = UDim2.new(0.05, 0, 0.55, 0)
BoostBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
BoostBtn.Text = "ROCKET: OFF\n(Tap to Engage)"
BoostBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
BoostBtn.Font = Enum.Font.GothamBold
BoostBtn.TextSize = 16
BoostBtn.Parent = MainFrame
Instance.new("UICorner", BoostBtn).CornerRadius = UDim.new(0, 6)

BoostBtn.MouseButton1Click:Connect(function()
    Config.IsActive = not Config.IsActive
    
    if Config.IsActive then
        BoostBtn.Text = "🚀 MOVING! (7000)\n(Tap to Stop)"
        BoostBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 0) -- Green
        BoostBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    else
        BoostBtn.Text = "ROCKET: OFF\n(Tap to Engage)"
        BoostBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        BoostBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end)

-- === PHYSICS LOOP ===
RunService.Heartbeat:Connect(function()
    -- Only run if Toggled ON
    if not Config.IsActive then 
        -- Cleanup forces if we just turned it off
        local char = player.Character
        if char then
            local humanoid = char:FindFirstChild("Humanoid")
            if humanoid and humanoid.SeatPart then
                 local thrust = humanoid.SeatPart:FindFirstChild("J32_Thrust")
                 if thrust then thrust:Destroy() end
            end
        end
        return 
    end
    
    local char = player.Character
    if not char then return end
    
    -- Find Seat (Auto-detect)
    local driveSeat = nil
    
    -- Try Humanoid Seat first
    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid and humanoid.SeatPart then
        driveSeat = humanoid.SeatPart
    else
        -- Try finding car model manually if not sitting "officially"
        local carModel = Workspace:FindFirstChild("Lf20Besaya's Car")
        if carModel then driveSeat = carModel:FindFirstChild("DriveSeat") end
    end
    
    if driveSeat then
        -- CREATE FORCE
        local att = driveSeat:FindFirstChild("J32_Att")
        local thrust = driveSeat:FindFirstChild("J32_Thrust")
        
        if not att then
            att = Instance.new("Attachment", driveSeat)
            att.Name = "J32_Att"
        end
        
        if not thrust then
            thrust = Instance.new("VectorForce", driveSeat)
            thrust.Name = "J32_Thrust"
            thrust.Attachment0 = att
            thrust.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
            -- Negative Z is Forward for most cars
            thrust.Force = Vector3.new(0, 0, -Config.BoostPower)
        end
        
        -- Ensure force is set (in case something reset it)
        thrust.Force = Vector3.new(0, 0, -Config.BoostPower)
    end
end)

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(0.85, 0, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
CloseBtn.Parent = MainFrame
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
