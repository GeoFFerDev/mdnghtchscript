-- [[ JOSEPEDOV53: HANDLING ASSIST ]] --
-- Features: Active Steering Assist, Cornering Grip, Adaptive Power
-- Optimized for Delta | Fixes "Understeer" (Car going straight while turning)

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- === CONFIGURATION ===
local Config = {
    TrafficBlocked = false,
    BoostPower = 7000,    -- Forward Power Base
    PowerMultiplier = 3,  -- Mass Multiplier
    TurnStrength = 2.5,   -- How hard to "Help" turn (Adjustable)
    Enabled = false,      -- Master Toggle
    Deadzone = 0.1        -- Gas Threshold
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
ScreenGui.Name = "JOSEPEDOV53_UI"
ScreenGui.Parent = game.CoreGui

-- [1] THE ICON
local OpenIcon = Instance.new("TextButton")
OpenIcon.Name = "OpenIcon"
OpenIcon.Size = UDim2.new(0, 50, 0, 50)
OpenIcon.Position = UDim2.new(0.02, 0, 0.4, 0)
OpenIcon.BackgroundColor3 = Color3.fromRGB(0, 255, 150) -- Teal
OpenIcon.Text = "J53"
OpenIcon.TextColor3 = Color3.fromRGB(0, 0, 0)
OpenIcon.Font = Enum.Font.GothamBlack
OpenIcon.TextSize = 18
OpenIcon.Visible = false 
OpenIcon.Parent = ScreenGui
Instance.new("UICorner", OpenIcon).CornerRadius = UDim.new(0, 25)
MakeDraggable(OpenIcon)

-- [2] MAIN PANEL
local ControlFrame = Instance.new("Frame")
ControlFrame.Name = "ControlFrame"
ControlFrame.Size = UDim2.new(0, 200, 0, 220) -- Taller for Turn Control
ControlFrame.Position = UDim2.new(0.02, 0, 0.3, 0)
ControlFrame.BackgroundColor3 = Color3.fromRGB(10, 20, 20)
ControlFrame.BorderSizePixel = 2
ControlFrame.BorderColor3 = Color3.fromRGB(0, 255, 150)
ControlFrame.Active = true
ControlFrame.Parent = ScreenGui
MakeDraggable(ControlFrame)

local Title = Instance.new("TextLabel")
Title.Text = "J53: HANDLING"
Title.Size = UDim2.new(1, 0, 0, 20)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(0, 255, 150)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 14
Title.Parent = ControlFrame

-- Traffic Button
local TrafficBtn = Instance.new("TextButton")
TrafficBtn.Size = UDim2.new(0.9, 0, 0, 30)
TrafficBtn.Position = UDim2.new(0.05, 0, 0.15, 0)
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

-- Power Control
local PowerLabel = Instance.new("TextLabel")
PowerLabel.Text = "Power: 3x"
PowerLabel.Size = UDim2.new(1, 0, 0, 20)
PowerLabel.Position = UDim2.new(0, 0, 0.32, 0)
PowerLabel.BackgroundTransparency = 1
PowerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
PowerLabel.Font = Enum.Font.GothamBold
PowerLabel.TextSize = 12
PowerLabel.Parent = ControlFrame

local MinusBtn = Instance.new("TextButton")
MinusBtn.Text = "-"
MinusBtn.Size = UDim2.new(0.4, 0, 0, 25)
MinusBtn.Position = UDim2.new(0.05, 0, 0.42, 0)
MinusBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MinusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinusBtn.Parent = ControlFrame
Instance.new("UICorner", MinusBtn).CornerRadius = UDim.new(0, 6)

local PlusBtn = Instance.new("TextButton")
PlusBtn.Text = "+"
PlusBtn.Size = UDim2.new(0.4, 0, 0, 25)
PlusBtn.Position = UDim2.new(0.55, 0, 0.42, 0)
PlusBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
PlusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PlusBtn.Parent = ControlFrame
Instance.new("UICorner", PlusBtn).CornerRadius = UDim.new(0, 6)

MinusBtn.MouseButton1Click:Connect(function()
    Config.PowerMultiplier = math.max(0.5, Config.PowerMultiplier - 0.5)
    PowerLabel.Text = "Power: " .. Config.PowerMultiplier .. "x"
end)

PlusBtn.MouseButton1Click:Connect(function()
    Config.PowerMultiplier = Config.PowerMultiplier + 0.5
    PowerLabel.Text = "Power: " .. Config.PowerMultiplier .. "x"
end)

-- Turn Assist Control
local TurnLabel = Instance.new("TextLabel")
TurnLabel.Text = "Turn Assist: 2.5"
TurnLabel.Size = UDim2.new(1, 0, 0, 20)
TurnLabel.Position = UDim2.new(0, 0, 0.55, 0)
TurnLabel.BackgroundTransparency = 1
TurnLabel.TextColor3 = Color3.fromRGB(0, 255, 150)
TurnLabel.Font = Enum.Font.GothamBold
TurnLabel.TextSize = 12
TurnLabel.Parent = ControlFrame

local TurnMinusBtn = Instance.new("TextButton")
TurnMinusBtn.Text = "<"
TurnMinusBtn.Size = UDim2.new(0.4, 0, 0, 25)
TurnMinusBtn.Position = UDim2.new(0.05, 0, 0.65, 0)
TurnMinusBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TurnMinusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TurnMinusBtn.Parent = ControlFrame
Instance.new("UICorner", TurnMinusBtn).CornerRadius = UDim.new(0, 6)

local TurnPlusBtn = Instance.new("TextButton")
TurnPlusBtn.Text = ">"
TurnPlusBtn.Size = UDim2.new(0.4, 0, 0, 25)
TurnPlusBtn.Position = UDim2.new(0.55, 0, 0.65, 0)
TurnPlusBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TurnPlusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TurnPlusBtn.Parent = ControlFrame
Instance.new("UICorner", TurnPlusBtn).CornerRadius = UDim.new(0, 6)

TurnMinusBtn.MouseButton1Click:Connect(function()
    Config.TurnStrength = math.max(0, Config.TurnStrength - 0.5)
    TurnLabel.Text = "Turn Assist: " .. Config.TurnStrength
end)

TurnPlusBtn.MouseButton1Click:Connect(function()
    Config.TurnStrength = Config.TurnStrength + 0.5
    TurnLabel.Text = "Turn Assist: " .. Config.TurnStrength
end)

-- Speed Toggle
local SpeedBtn = Instance.new("TextButton")
SpeedBtn.Size = UDim2.new(0.9, 0, 0, 35)
SpeedBtn.Position = UDim2.new(0.05, 0, 0.80, 0)
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
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
        SpeedBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    else
        SpeedBtn.Text = "⚡ SPEED HACK: OFF"
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        SpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        currentSeat = nil
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

-- === PHYSICS LOOP (HANDLING FIX) ===
RunService.Heartbeat:Connect(function()
    if not Config.Enabled then 
        if currentSeat then
            local thrust = currentSeat:FindFirstChild("J53_Thrust")
            local turn = currentSeat:FindFirstChild("J53_Turn")
            if thrust then thrust:Destroy() end
            if turn then turn:Destroy() end
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
    
    if not currentSeat then return end
    
    -- 2. READ VALUES (Throttle, Brake, Gear, STEER)
    local gasVal = 0
    local brakeVal = 0
    local gearVal = 1
    local steerVal = 0 -- -1 (Left) to 1 (Right)
    
    local interface = player:FindFirstChild("PlayerGui") and player.PlayerGui:FindFirstChild("A-Chassis Interface")
    if interface then
        local valFolder = interface:FindFirstChild("Values")
        if valFolder then
            local gObj = valFolder:FindFirstChild("Throttle")
            local bObj = valFolder:FindFirstChild("Brake")
            local rObj = valFolder:FindFirstChild("Gear")
            local sObj = valFolder:FindFirstChild("SteerT") -- Target Steer
            
            if gObj then gasVal = gObj.Value end
            if bObj then brakeVal = bObj.Value end
            if rObj then gearVal = rObj.Value end
            if sObj then steerVal = sObj.Value end
        end
    end
    
    -- Fallback for Steer if GUI is missing (Mouse Steer)
    if steerVal == 0 then steerVal = currentSeat.Steer end
    
    -- 3. LOGIC & PHYSICS
    
    local att = currentSeat:FindFirstChild("J53_Att")
    local thrust = currentSeat:FindFirstChild("J53_Thrust")
    local turn = currentSeat:FindFirstChild("J53_Turn") -- Handling Assist
    
    if not att then
        att = Instance.new("Attachment", currentSeat)
        att.Name = "J53_Att"
    end
    
    -- Check for Reverse (Lockout)
    local isReversing = (gearVal == -1) or (brakeVal > 0.1)
    
    if isReversing then
        -- DISABLE ALL ASSISTS IN REVERSE
        if thrust then thrust:Destroy() end
        if turn then turn:Destroy() end
        
    elseif gasVal > Config.Deadzone then
        -- === BOOSTING FORWARD ===
        
        -- A. Forward Force
        if not thrust then
            thrust = Instance.new("VectorForce", currentSeat)
            thrust.Name = "J53_Thrust"
            thrust.Attachment0 = att
            thrust.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
        end
        
        local mass = currentSeat.AssemblyMass
        
        -- HANDLING LOGIC: Reduce speed if turning heavily to allow grip
        local gripFactor = 1.0
        if math.abs(steerVal) > 0.1 then
            gripFactor = 0.7 -- Reduce power to 70% when turning
        end
        
        local targetForce = mass * Config.PowerMultiplier * 50 * gripFactor
        thrust.Force = Vector3.new(0, 0, -targetForce)
        
        -- B. Turn Assist (The Fix for Hard Steering)
        if math.abs(steerVal) > 0.1 then
            if not turn then
                turn = Instance.new("BodyAngularVelocity", currentSeat)
                turn.Name = "J53_Turn"
                -- MaxTorque: Only apply to Y axis (Turning), prevent flipping (X/Z = 0)
                turn.MaxTorque = Vector3.new(0, mass * 1000, 0) 
            end
            
            -- Rotate based on steer direction
            -- Positive Y is Left, Negative Y is Right usually.
            -- We multiply by TurnStrength to control sharpness.
            turn.AngularVelocity = Vector3.new(0, -steerVal * Config.TurnStrength, 0)
        else
            if turn then turn:Destroy() end
        end
        
    else
        -- IDLE
        if thrust then thrust:Destroy() end
        if turn then turn:Destroy() end
    end
end)
