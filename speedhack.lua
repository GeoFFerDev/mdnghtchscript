-- [[ JOSEPEDOV51: REVERSE LOCKOUT ]] --
-- Features: Hard Gear Lockout, Traffic Jammer, Draggable UI
-- Optimized for Delta | Prevents Forward Boost while in Reverse Gear

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- === CONFIGURATION ===
local Config = {
    TrafficBlocked = false,
    BoostPower = 7000,   -- Forward Power
    Enabled = false,     -- Master Toggle
    Deadzone = 0.1       -- Gas Threshold
}

-- === STATE ===
local currentSeat = nil

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
ScreenGui.Name = "JOSEPEDOV51_UI"
ScreenGui.Parent = game.CoreGui

-- [1] THE ICON
local OpenIcon = Instance.new("TextButton")
OpenIcon.Name = "OpenIcon"
OpenIcon.Size = UDim2.new(0, 50, 0, 50)
OpenIcon.Position = UDim2.new(0.02, 0, 0.4, 0)
OpenIcon.BackgroundColor3 = Color3.fromRGB(255, 0, 255) -- Purple
OpenIcon.Text = "J51"
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
ControlFrame.BackgroundColor3 = Color3.fromRGB(15, 10, 20)
ControlFrame.BorderSizePixel = 2
ControlFrame.BorderColor3 = Color3.fromRGB(255, 0, 255)
ControlFrame.Active = true
ControlFrame.Parent = ScreenGui
MakeDraggable(ControlFrame)

local Title = Instance.new("TextLabel")
Title.Text = "J51: REV LOCKOUT"
Title.Size = UDim2.new(1, 0, 0, 20)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 0, 255)
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
        SpeedBtn.Text = "⚡ SPEED HACK: ON"
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 255)
        SpeedBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    else
        SpeedBtn.Text = "⚡ SPEED HACK: OFF"
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        SpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        currentSeat = nil
    end
end)

-- DEBUG LABEL
local DebugLabel = Instance.new("TextLabel")
DebugLabel.Text = "Status: IDLE"
DebugLabel.Size = UDim2.new(1, 0, 0, 20)
DebugLabel.Position = UDim2.new(0, 0, 0.85, 0)
DebugLabel.BackgroundTransparency = 1
DebugLabel.TextColor3 = Color3.fromRGB(150, 150, 150)
DebugLabel.Font = Enum.Font.Code
DebugLabel.TextSize = 12
DebugLabel.Parent = ControlFrame

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

-- === PHYSICS LOOP (REVERSE LOCKOUT) ===
RunService.Heartbeat:Connect(function()
    if not Config.Enabled then 
        if currentSeat then
            local thrust = currentSeat:FindFirstChild("J51_Thrust")
            if thrust then thrust:Destroy() end
            currentSeat = nil
        end
        return 
    end
    
    local char = player.Character
    if not char then return end
    
    -- 1. Refresh Car
    if currentSeat and (not currentSeat.Parent or not currentSeat:IsDescendantOf(Workspace)) then
        currentSeat = nil
    end
    
    if not currentSeat then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid and humanoid.SeatPart then
            currentSeat = humanoid.SeatPart
        else
            local carModel = Workspace:FindFirstChild("Lf20Besaya's Car")
            if carModel then currentSeat = carModel:FindFirstChild("DriveSeat") end
        end
    end
    
    if not currentSeat then 
        DebugLabel.Text = "Status: NO CAR"
        return 
    end
    
    -- 2. READ VALUES
    local gasVal = 0
    local brakeVal = 0
    local gearVal = 1 -- Default forward
    
    local interface = player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("A-Chassis Interface")
    if interface then
        local valFolder = interface:FindFirstChild("Values")
        if valFolder then
            local gObj = valFolder:FindFirstChild("Throttle")
            local bObj = valFolder:FindFirstChild("Brake")
            local rObj = valFolder:FindFirstChild("Gear")
            
            if gObj then gasVal = gObj.Value end
            if bObj then brakeVal = bObj.Value end
            if rObj then gearVal = rObj.Value end
        end
    end
    
    -- 3. THE HARD LOCKOUT
    local isReversing = false
    
    -- Check Gear (Primary Lock)
    if gearVal == -1 then isReversing = true end
    
    -- Check Brake (Secondary Lock)
    if brakeVal > 0.1 then isReversing = true end
    
    -- Check Motion (Tertiary Lock)
    local velocity = currentSeat.AssemblyLinearVelocity
    local forwardDir = currentSeat.CFrame.LookVector
    if velocity.Magnitude > 5 and velocity:Dot(forwardDir) < -1 then
        isReversing = true
    end
    
    -- 4. EXECUTE
    local thrust = currentSeat:FindFirstChild("J51_Thrust")
    local att = currentSeat:FindFirstChild("J51_Att")
    
    if not att then
        att = Instance.new("Attachment", currentSeat)
        att.Name = "J51_Att"
    end
    
    if isReversing then
        -- === LOCKOUT ENGAGED ===
        -- Destroy force immediately.
        -- Even if gasVal is 100, we DO NOT BOOST.
        if thrust then thrust:Destroy() end
        
        DebugLabel.Text = "Status: REVERSING (Locked)"
        DebugLabel.TextColor3 = Color3.fromRGB(255, 100, 100) -- Red
        
    elseif gasVal > Config.Deadzone then
        -- === SAFE TO BOOST ===
        if not thrust then
            thrust = Instance.new("VectorForce", currentSeat)
            thrust.Name = "J51_Thrust"
            thrust.Attachment0 = att
            thrust.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
        end
        thrust.Force = Vector3.new(0, 0, -Config.BoostPower) -- Forward
        
        DebugLabel.Text = "Status: BOOSTING"
        DebugLabel.TextColor3 = Color3.fromRGB(0, 255, 0) -- Green
        
    else
        -- === IDLE ===
        if thrust then thrust:Destroy() end
        DebugLabel.Text = "Status: IDLE"
        DebugLabel.TextColor3 = Color3.fromRGB(150, 150, 150) -- Grey
    end
end)
