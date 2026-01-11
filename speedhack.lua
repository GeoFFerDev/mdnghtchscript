-- [[ JOSEPEDOV34: VIRTUAL PEDALS ]] --
-- Features: Custom Gas/Brake UI, Auto-Stop (Anti-Creep), Traffic Jammer
-- Optimized for Delta | Fixes "Continuous Running" by actively holding the car

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- === CONFIGURATION ===
local Config = {
    TrafficBlocked = false,
    BoostPower = 7000, -- The Sweet Spot
    InputState = "IDLE", -- Can be "GAS", "BRAKE", or "IDLE"
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
ScreenGui.Name = "JOSEPEDOV34_UI"
ScreenGui.Parent = game.CoreGui

-- MAIN CONTROL PANEL (Left Side - Traffic & Minimized)
local ControlFrame = Instance.new("Frame")
ControlFrame.Name = "ControlFrame"
ControlFrame.Size = UDim2.new(0, 150, 0, 80)
ControlFrame.Position = UDim2.new(0.02, 0, 0.3, 0)
ControlFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
ControlFrame.BorderSizePixel = 2
ControlFrame.BorderColor3 = Color3.fromRGB(0, 255, 255)
ControlFrame.Active = true
ControlFrame.Draggable = true 
ControlFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Text = "J34: VIRTUAL"
Title.Size = UDim2.new(1, 0, 0, 20)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(0, 255, 255)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 14
Title.Parent = ControlFrame

local TrafficBtn = Instance.new("TextButton")
TrafficBtn.Size = UDim2.new(0.9, 0, 0, 40)
TrafficBtn.Position = UDim2.new(0.05, 0, 0.35, 0)
TrafficBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TrafficBtn.Text = "🚫 Kill Traffic"
TrafficBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TrafficBtn.Font = Enum.Font.GothamBold
TrafficBtn.TextSize = 14
TrafficBtn.Parent = ControlFrame
Instance.new("UICorner", TrafficBtn).CornerRadius = UDim.new(0, 6)

TrafficBtn.MouseButton1Click:Connect(function()
    Config.TrafficBlocked = not Config.TrafficBlocked
    if Config.TrafficBlocked then
        TrafficBtn.Text = "Traffic: DEAD 💀"
        TrafficBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        local event = ReplicatedStorage:FindFirstChild("CreateNPCVehicle")
        if event then for _, c in pairs(getconnections(event.OnClientEvent)) do c:Disable() end end
        local npc = Workspace:FindFirstChild("NPCVehicles") or Workspace:FindFirstChild("Traffic")
        if npc then npc:ClearAllChildren() end
    else
        TrafficBtn.Text = "Traffic: ALLOWED"
        TrafficBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        local event = ReplicatedStorage:FindFirstChild("CreateNPCVehicle")
        if event then for _, c in pairs(getconnections(event.OnClientEvent)) do c:Enable() end end
    end
end)

-- === VIRTUAL PEDALS (Right Side - Ergonomic) ===

-- GAS PEDAL (Big Green)
local GasBtn = Instance.new("TextButton")
GasBtn.Name = "GasPedal"
GasBtn.Size = UDim2.new(0, 120, 0, 150) -- Big hit area
GasBtn.Position = UDim2.new(0.85, 0, 0.5, 0) -- Right thumb area
GasBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
GasBtn.BackgroundTransparency = 0.6 -- See-through
GasBtn.Text = "GAS\n(7000)"
GasBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GasBtn.Font = Enum.Font.GothamBlack
GasBtn.TextSize = 24
GasBtn.Parent = ScreenGui
Instance.new("UICorner", GasBtn).CornerRadius = UDim.new(0, 20)

-- BRAKE PEDAL (Smaller Red)
local BrakeBtn = Instance.new("TextButton")
BrakeBtn.Name = "BrakePedal"
BrakeBtn.Size = UDim2.new(0, 80, 0, 80)
BrakeBtn.Position = UDim2.new(0.75, 0, 0.65, 0) -- Slightly left of gas
BrakeBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 0)
BrakeBtn.BackgroundTransparency = 0.6
BrakeBtn.Text = "STOP\nREV"
BrakeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
BrakeBtn.Font = Enum.Font.GothamBlack
BrakeBtn.TextSize = 16
BrakeBtn.Parent = ScreenGui
Instance.new("UICorner", BrakeBtn).CornerRadius = UDim.new(0, 20)

-- INPUT HANDLING
GasBtn.MouseButton1Down:Connect(function() Config.InputState = "GAS"; GasBtn.BackgroundTransparency = 0.2 end)
GasBtn.MouseButton1Up:Connect(function() Config.InputState = "IDLE"; GasBtn.BackgroundTransparency = 0.6 end)
GasBtn.MouseLeave:Connect(function() Config.InputState = "IDLE"; GasBtn.BackgroundTransparency = 0.6 end)

BrakeBtn.MouseButton1Down:Connect(function() Config.InputState = "BRAKE"; BrakeBtn.BackgroundTransparency = 0.2 end)
BrakeBtn.MouseButton1Up:Connect(function() Config.InputState = "IDLE"; BrakeBtn.BackgroundTransparency = 0.6 end)
BrakeBtn.MouseLeave:Connect(function() Config.InputState = "IDLE"; BrakeBtn.BackgroundTransparency = 0.6 end)

-- === PHYSICS LOOP ===
RunService.Heartbeat:Connect(function()
    local char = player.Character
    if not char then return end
    
    -- Find Seat (Auto-detect)
    local driveSeat = nil
    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid and humanoid.SeatPart then
        driveSeat = humanoid.SeatPart
    else
        local carModel = Workspace:FindFirstChild("Lf20Besaya's Car")
        if carModel then driveSeat = carModel:FindFirstChild("DriveSeat") end
    end
    
    if not driveSeat then return end
    
    -- MANAGING FORCES
    local thrust = driveSeat:FindFirstChild("J34_Thrust")
    local anchor = driveSeat:FindFirstChild("J34_Anchor")
    local att = driveSeat:FindFirstChild("J34_Att")
    
    if not att then
        att = Instance.new("Attachment", driveSeat)
        att.Name = "J34_Att"
    end
    
    if Config.InputState == "GAS" then
        -- 1. APPLY FORWARD FORCE
        if anchor then anchor:Destroy() end -- Release Brake
        
        if not thrust then
            thrust = Instance.new("VectorForce", driveSeat)
            thrust.Name = "J34_Thrust"
            thrust.Attachment0 = att
            thrust.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
        end
        thrust.Force = Vector3.new(0, 0, -Config.BoostPower) -- Forward
        
    elseif Config.InputState == "BRAKE" then
        -- 2. APPLY REVERSE FORCE
        if anchor then anchor:Destroy() end -- Release Brake
        
        if not thrust then
            thrust = Instance.new("VectorForce", driveSeat)
            thrust.Name = "J34_Thrust"
            thrust.Attachment0 = att
            thrust.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
        end
        thrust.Force = Vector3.new(0, 0, Config.BoostPower) -- Backward
        
    else -- IDLE
        -- 3. AUTO-STOP (The Anti-Creep Fix)
        if thrust then thrust:Destroy() end -- Stop Pushing
        
        -- Create "Anchor" (BodyVelocity 0) to hold car in place
        if not anchor then
            anchor = Instance.new("BodyVelocity", driveSeat)
            anchor.Name = "J34_Anchor"
            anchor.MaxForce = Vector3.new(100000, 0, 100000) -- Only stop X/Z (Movement), let Y (Gravity) work
            anchor.Velocity = Vector3.new(0, 0, 0) -- FREEZE
        end
    end
end)

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 20, 0, 20)
CloseBtn.Position = UDim2.new(1, -20, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.Parent = ControlFrame
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
