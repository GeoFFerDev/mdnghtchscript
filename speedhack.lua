-- [[ JOSEPEDOV43: NATIVE HOOK ]] --
-- Features: Reads A-Chassis Internal Values, 7000 Force, Traffic Jammer
-- Optimized for Delta | Fixes "Continuous Run" by ignoring Idle Throttle

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- === CONFIGURATION ===
local Config = {
    TrafficBlocked = false,
    BoostPower = 7000,   -- The Sweet Spot
    Enabled = false,     -- Master Toggle
    Deadzone = 0.1       -- 10% Deadzone (Ignores the 3% idle)
}

-- === DRAG FUNCTION ===
local function MakeDraggable(gui)
    local dragging, dragInput, dragStart, startPos

    local function update(input)
        local delta = input.Position - dragStart
        gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)

    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
    end)
end

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
ScreenGui.Name = "JOSEPEDOV43_UI"
ScreenGui.Parent = game.CoreGui

-- [1] THE ICON
local OpenIcon = Instance.new("TextButton")
OpenIcon.Name = "OpenIcon"
OpenIcon.Size = UDim2.new(0, 50, 0, 50)
OpenIcon.Position = UDim2.new(0.02, 0, 0.4, 0)
OpenIcon.BackgroundColor3 = Color3.fromRGB(255, 50, 0) -- Neon Red
OpenIcon.Text = "J43"
OpenIcon.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenIcon.Font = Enum.Font.GothamBlack
OpenIcon.TextSize = 18
OpenIcon.Visible = false 
OpenIcon.Parent = ScreenGui
Instance.new("UICorner", OpenIcon).CornerRadius = UDim.new(0, 25)
MakeDraggable(OpenIcon)

-- [2] MAIN PANEL
local ControlFrame = Instance.new("Frame")
ControlFrame.Name = "ControlFrame"
ControlFrame.Size = UDim2.new(0, 200, 0, 160)
ControlFrame.Position = UDim2.new(0.02, 0, 0.3, 0)
ControlFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
ControlFrame.BorderSizePixel = 2
ControlFrame.BorderColor3 = Color3.fromRGB(255, 50, 0)
ControlFrame.Active = true
ControlFrame.Parent = ScreenGui
MakeDraggable(ControlFrame)

local Title = Instance.new("TextLabel")
Title.Text = "J43: NATIVE HOOK"
Title.Size = UDim2.new(1, 0, 0, 20)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 50, 0)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 14
Title.Parent = ControlFrame

-- Traffic Button
local TrafficBtn = Instance.new("TextButton")
TrafficBtn.Size = UDim2.new(0.9, 0, 0, 35)
TrafficBtn.Position = UDim2.new(0.05, 0, 0.20, 0)
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

-- Speed Toggle
local SpeedBtn = Instance.new("TextButton")
SpeedBtn.Size = UDim2.new(0.9, 0, 0, 50)
SpeedBtn.Position = UDim2.new(0.05, 0, 0.50, 0)
SpeedBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SpeedBtn.Text = "⚡ SPEED HACK: OFF"
SpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBtn.Font = Enum.Font.GothamBold
SpeedBtn.TextSize = 14
SpeedBtn.Parent = ControlFrame
Instance.new("UICorner", SpeedBtn).CornerRadius = UDim.new(0, 6)

SpeedBtn.MouseButton1Click:Connect(function()
    Config.Enabled = not Config.Enabled
    if Config.Enabled then
        SpeedBtn.Text = "⚡ SPEED HACK: ON\n(Uses Game Throttle)"
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
        SpeedBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    else
        SpeedBtn.Text = "⚡ SPEED HACK: OFF"
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        SpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end)

-- Minimize Logic
local MinBtn = Instance.new("TextButton")
MinBtn.Text = "-"
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(0.70, 0, 0, 0)
MinBtn.BackgroundTransparency = 1
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 24
MinBtn.Parent = ControlFrame

MinBtn.MouseButton1Click:Connect(function()
    ControlFrame.Visible = false
    OpenIcon.Visible = true
end)

OpenIcon.MouseButton1Click:Connect(function()
    ControlFrame.Visible = true
    OpenIcon.Visible = false
end)

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(0.85, 0, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.Parent = ControlFrame
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- === PHYSICS LOOP (THE FIX) ===
RunService.Heartbeat:Connect(function()
    if not Config.Enabled then 
        -- Cleanup forces immediately if turned off
        local char = player.Character
        if char then
            local seat = char:FindFirstChild("Humanoid") and char.Humanoid.SeatPart
            if seat then
                local thrust = seat:FindFirstChild("J43_Thrust")
                if thrust then thrust:Destroy() end
            end
        end
        return 
    end
    
    -- 1. Get Car & Seat
    local driveSeat = nil
    local car = nil
    local char = player.Character
    
    if char and char:FindFirstChild("Humanoid") then
        driveSeat = char.Humanoid.SeatPart
        if driveSeat then car = driveSeat.Parent end
    end
    
    -- Fallback search if not seated "officially"
    if not driveSeat then
        local carModel = Workspace:FindFirstChild("Lf20Besaya's Car")
        if carModel then driveSeat = carModel:FindFirstChild("DriveSeat") end
    end
    
    if not driveSeat then return end
    
    -- 2. DETERMINE THROTTLE (The Native Hook)
    local throttleValue = 0
    
    -- Priority A: Check the A-Chassis Interface (Based on your logs)
    local interface = player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("A-Chassis Interface")
    if interface then
        local valFolder = interface:FindFirstChild("Values")
        if valFolder then
            local tObj = valFolder:FindFirstChild("Throttle")
            if tObj then throttleValue = tObj.Value end
        end
    end
    
    -- Priority B: Fallback to Seat Property if interface fails
    if throttleValue == 0 and driveSeat.Throttle > 0 then
        throttleValue = driveSeat.Throttle
    end
    
    -- 3. APPLY FORCE (Deadzone Check)
    local att = driveSeat:FindFirstChild("J43_Att")
    local thrust = driveSeat:FindFirstChild("J43_Thrust")
    
    if not att then
        att = Instance.new("Attachment", driveSeat)
        att.Name = "J43_Att"
    end
    
    -- **CRITICAL FIX**: Only boost if Throttle > 0.1 (Ignores 0.03 Idle)
    if throttleValue > Config.Deadzone then
        if not thrust then
            thrust = Instance.new("VectorForce", driveSeat)
            thrust.Name = "J43_Thrust"
            thrust.Attachment0 = att
            thrust.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
        end
        -- Apply the Sweet Spot Power
        thrust.Force = Vector3.new(0, 0, -Config.BoostPower)
    else
        -- If Throttle drops to idle (0.03), KILL the force immediately
        if thrust then 
            thrust:Destroy() 
        end
    end
end)
