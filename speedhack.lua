-- [[ JOSEPEDOV33: INTELLIGENT BOOSTER ]] --
-- Features: Gas Pedal Detection (Dual Check), 7000 Power, Traffic Jammer
-- Optimized for Delta | "Arm & Drive" System

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- === CONFIGURATION ===
local Config = {
    TrafficBlocked = false,
    BoostPower = 7000,  -- Sweet Spot
    IsArmed = false     -- Master Switch
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
ScreenGui.Name = "JOSEPEDOV33_UI"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 200, 0, 160)
MainFrame.Position = UDim2.new(0.05, 0, 0.3, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(255, 200, 0) -- Gold
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Text = "J33: SMART BOOST"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 200, 0)
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

-- [BUTTON 2] ARMING SWITCH
local BoostBtn = Instance.new("TextButton")
BoostBtn.Size = UDim2.new(0.9, 0, 0, 60)
BoostBtn.Position = UDim2.new(0.05, 0, 0.55, 0)
BoostBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
BoostBtn.Text = "SYSTEM: OFF\n(Tap to Arm)"
BoostBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
BoostBtn.Font = Enum.Font.GothamBold
BoostBtn.TextSize = 16
BoostBtn.Parent = MainFrame
Instance.new("UICorner", BoostBtn).CornerRadius = UDim.new(0, 6)

BoostBtn.MouseButton1Click:Connect(function()
    Config.IsArmed = not Config.IsArmed
    
    if Config.IsArmed then
        BoostBtn.Text = "⚠️ ARMED (7000)\n(Press Gas to Fire)"
        BoostBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0) -- Gold/Yellow
        BoostBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    else
        BoostBtn.Text = "SYSTEM: OFF\n(Tap to Arm)"
        BoostBtn.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
        BoostBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end)

-- === PHYSICS LOOP (Input Detection) ===
RunService.Heartbeat:Connect(function()
    local char = player.Character
    if not char then return end
    
    -- 1. Find Seat & Car
    local driveSeat = nil
    local car = nil
    
    -- Try Humanoid Seat
    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid and humanoid.SeatPart then
        driveSeat = humanoid.SeatPart
        car = driveSeat.Parent
    else
        -- Try Manual Search (Lf20Besaya's Car)
        car = Workspace:FindFirstChild("Lf20Besaya's Car")
        if car then driveSeat = car:FindFirstChild("DriveSeat") end
    end
    
    -- 2. Clean up if not seated or not armed
    if not driveSeat or not Config.IsArmed then
        if driveSeat then
             local thrust = driveSeat:FindFirstChild("J33_Thrust")
             if thrust then thrust:Destroy() end
        end
        return 
    end
    
    -- 3. DETECT GAS INPUT (The Dual Check)
    local isPressingGas = false
    
    -- Check A: Standard Roblox Input
    if driveSeat.Throttle > 0 then
        isPressingGas = true
    end
    
    -- Check B: A-Chassis Values (Fixes the V30 Bug)
    if not isPressingGas and car then
        local carVal = car:FindFirstChild("Car") and car.Car.Value or car
        local valFolder = carVal:FindFirstChild("Values") or car:FindFirstChild("Values")
        if valFolder then
            local throttleVal = valFolder:FindFirstChild("Throttle")
            if throttleVal and throttleVal.Value > 0 then
                isPressingGas = true
            end
        end
    end

    -- 4. FIRE ROCKET
    if isPressingGas then
        -- Visual Feedback (Optional)
        BoostBtn.Text = "🚀 FIRING! 🚀"
        BoostBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0) -- Green
        
        local att = driveSeat:FindFirstChild("J33_Att")
        local thrust = driveSeat:FindFirstChild("J33_Thrust")
        
        if not att then
            att = Instance.new("Attachment", driveSeat)
            att.Name = "J33_Att"
        end
        
        if not thrust then
            thrust = Instance.new("VectorForce", driveSeat)
            thrust.Name = "J33_Thrust"
            thrust.Attachment0 = att
            thrust.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
            thrust.Force = Vector3.new(0, 0, -Config.BoostPower)
        end
        
        thrust.Force = Vector3.new(0, 0, -Config.BoostPower)
        
    else
        -- IDLE (Armed but waiting)
        BoostBtn.Text = "⚠️ ARMED (7000)\n(Press Gas to Fire)"
        BoostBtn.BackgroundColor3 = Color3.fromRGB(255, 200, 0)
        
        local thrust = driveSeat:FindFirstChild("J33_Thrust")
        if thrust then thrust:Destroy() end
    end
end)

-- Close
local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(0.85, 0, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = Color3.fromRGB(150, 150, 150)
CloseBtn.Parent = MainFrame
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
