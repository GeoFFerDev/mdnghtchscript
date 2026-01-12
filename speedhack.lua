-- [[ JOSEPEDOV38: LOCKED & LOADED ]] --
-- Features: Hybrid Input (Virtual + Native), Drag Lock, Power Adjust
-- Optimized for Delta | The Ultimate Driving Script

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- === CONFIGURATION ===
local Config = {
    TrafficBlocked = false,
    BoostPower = 7000,   -- Default Sweet Spot
    InputState = "IDLE", -- GAS, BRAKE, IDLE
    StopThreshold = 5,   
    PedalsVisible = true,
    UILocked = false,    -- Lock Dragging
    NativeGas = false,   -- Detected from Game
    NativeBrake = false
}

-- === DRAG FUNCTION (With Lock Check) ===
local function MakeDraggable(gui)
    local dragging
    local dragInput
    local dragStart
    local startPos

    local function update(input)
        if Config.UILocked then return end -- STOP if locked
        local delta = input.Position - dragStart
        gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end

    gui.InputBegan:Connect(function(input)
        if Config.UILocked then return end -- STOP if locked
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
            
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then
                    dragging = false
                end
            end)
        end
    end)

    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)

    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            update(input)
        end
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
ScreenGui.Name = "JOSEPEDOV38_UI"
ScreenGui.Parent = game.CoreGui

-- [1] THE ICON (Visible when minimized)
local OpenIcon = Instance.new("TextButton")
OpenIcon.Name = "OpenIcon"
OpenIcon.Size = UDim2.new(0, 50, 0, 50)
OpenIcon.Position = UDim2.new(0.02, 0, 0.2, 0)
OpenIcon.BackgroundColor3 = Color3.fromRGB(255, 165, 0) -- Orange
OpenIcon.Text = "J38"
OpenIcon.TextColor3 = Color3.fromRGB(0, 0, 0)
OpenIcon.Font = Enum.Font.GothamBlack
OpenIcon.TextSize = 18
OpenIcon.Visible = false 
OpenIcon.Parent = ScreenGui
Instance.new("UICorner", OpenIcon).CornerRadius = UDim.new(0, 25)
MakeDraggable(OpenIcon)

-- [2] MAIN CONTROL PANEL
local ControlFrame = Instance.new("Frame")
ControlFrame.Name = "ControlFrame"
ControlFrame.Size = UDim2.new(0, 200, 0, 220) -- Taller for extra buttons
ControlFrame.Position = UDim2.new(0.02, 0, 0.3, 0)
ControlFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
ControlFrame.BorderSizePixel = 2
ControlFrame.BorderColor3 = Color3.fromRGB(255, 165, 0)
ControlFrame.Active = true
ControlFrame.Parent = ScreenGui
MakeDraggable(ControlFrame)

local Title = Instance.new("TextLabel")
Title.Text = "J38: ULTIMATE"
Title.Size = UDim2.new(1, 0, 0, 20)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 165, 0)
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

-- Lock/Unlock Button
local LockBtn = Instance.new("TextButton")
LockBtn.Size = UDim2.new(0.9, 0, 0, 30)
LockBtn.Position = UDim2.new(0.05, 0, 0.32, 0)
LockBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
LockBtn.Text = "🔓 Position: Unlocked"
LockBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
LockBtn.Font = Enum.Font.GothamBold
LockBtn.TextSize = 14
LockBtn.Parent = ControlFrame
Instance.new("UICorner", LockBtn).CornerRadius = UDim.new(0, 6)

LockBtn.MouseButton1Click:Connect(function()
    Config.UILocked = not Config.UILocked
    if Config.UILocked then
        LockBtn.Text = "🔒 Position: LOCKED"
        LockBtn.BackgroundColor3 = Color3.fromRGB(255, 100, 0) -- Orange
    else
        LockBtn.Text = "🔓 Position: Unlocked"
        LockBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end
end)

-- Power Adjustment
local PowerLabel = Instance.new("TextLabel")
PowerLabel.Text = "Power: 7000"
PowerLabel.Size = UDim2.new(1, 0, 0, 20)
PowerLabel.Position = UDim2.new(0, 0, 0.48, 0)
PowerLabel.BackgroundTransparency = 1
PowerLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
PowerLabel.Font = Enum.Font.GothamBold
PowerLabel.TextSize = 12
PowerLabel.Parent = ControlFrame

local MinusBtn = Instance.new("TextButton")
MinusBtn.Text = "-"
MinusBtn.Size = UDim2.new(0.4, 0, 0, 30)
MinusBtn.Position = UDim2.new(0.05, 0, 0.58, 0)
MinusBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
MinusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinusBtn.Parent = ControlFrame
Instance.new("UICorner", MinusBtn).CornerRadius = UDim.new(0, 6)

local PlusBtn = Instance.new("TextButton")
PlusBtn.Text = "+"
PlusBtn.Size = UDim2.new(0.4, 0, 0, 30)
PlusBtn.Position = UDim2.new(0.55, 0, 0.58, 0)
PlusBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
PlusBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PlusBtn.Parent = ControlFrame
Instance.new("UICorner", PlusBtn).CornerRadius = UDim.new(0, 6)

MinusBtn.MouseButton1Click:Connect(function()
    Config.BoostPower = math.max(1000, Config.BoostPower - 1000)
    PowerLabel.Text = "Power: " .. Config.BoostPower
end)

PlusBtn.MouseButton1Click:Connect(function()
    Config.BoostPower = Config.BoostPower + 1000
    PowerLabel.Text = "Power: " .. Config.BoostPower
end)

-- Hide/Show Pedals
local TogglePedalsBtn = Instance.new("TextButton")
TogglePedalsBtn.Size = UDim2.new(0.9, 0, 0, 30)
TogglePedalsBtn.Position = UDim2.new(0.05, 0, 0.78, 0)
TogglePedalsBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TogglePedalsBtn.Text = "👁️ Hide Pedals"
TogglePedalsBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TogglePedalsBtn.Font = Enum.Font.GothamBold
TogglePedalsBtn.TextSize = 14
TogglePedalsBtn.Parent = ControlFrame
Instance.new("UICorner", TogglePedalsBtn).CornerRadius = UDim.new(0, 6)

-- Minimize Button (-)
local MinBtn = Instance.new("TextButton")
MinBtn.Text = "-"
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(0.70, 0, 0, 0)
MinBtn.BackgroundTransparency = 1
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Font = Enum.Font.GothamBold
MinBtn.TextSize = 24
MinBtn.Parent = ControlFrame

-- Close Button (X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(0.85, 0, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.Parent = ControlFrame
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- [3] VIRTUAL PEDALS
local GasBtn = Instance.new("TextButton")
GasBtn.Name = "GasPedal"
GasBtn.Size = UDim2.new(0, 120, 0, 150) 
GasBtn.Position = UDim2.new(0.85, 0, 0.5, 0) 
GasBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 100)
GasBtn.BackgroundTransparency = 0.6
GasBtn.Text = "GAS"
GasBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GasBtn.Font = Enum.Font.GothamBlack
GasBtn.TextSize = 24
GasBtn.Parent = ScreenGui
Instance.new("UICorner", GasBtn).CornerRadius = UDim.new(0, 20)
MakeDraggable(GasBtn)

local BrakeBtn = Instance.new("TextButton")
BrakeBtn.Name = "BrakePedal"
BrakeBtn.Size = UDim2.new(0, 80, 0, 80)
BrakeBtn.Position = UDim2.new(0.75, 0, 0.65, 0) 
BrakeBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50)
BrakeBtn.BackgroundTransparency = 0.6
BrakeBtn.Text = "REV"
BrakeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
BrakeBtn.Font = Enum.Font.GothamBlack
BrakeBtn.TextSize = 16
BrakeBtn.Parent = ScreenGui
Instance.new("UICorner", BrakeBtn).CornerRadius = UDim.new(0, 20)
MakeDraggable(BrakeBtn)

-- === LOGIC ===
MinBtn.MouseButton1Click:Connect(function()
    ControlFrame.Visible = false
    OpenIcon.Visible = true
end)

OpenIcon.MouseButton1Click:Connect(function()
    ControlFrame.Visible = true
    OpenIcon.Visible = false
end)

TogglePedalsBtn.MouseButton1Click:Connect(function()
    Config.PedalsVisible = not Config.PedalsVisible
    GasBtn.Visible = Config.PedalsVisible
    BrakeBtn.Visible = Config.PedalsVisible
    
    if Config.PedalsVisible then
        TogglePedalsBtn.Text = "👁️ Hide Pedals"
        TogglePedalsBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    else
        TogglePedalsBtn.Text = "👁️ Show Pedals"
        TogglePedalsBtn.BackgroundColor3 = Color3.fromRGB(150, 50, 50)
    end
end)

-- VIRTUAL INPUT
GasBtn.MouseButton1Down:Connect(function() Config.InputState = "GAS"; GasBtn.BackgroundTransparency = 0.2 end)
GasBtn.MouseButton1Up:Connect(function() Config.InputState = "IDLE"; GasBtn.BackgroundTransparency = 0.6 end)
GasBtn.MouseLeave:Connect(function() Config.InputState = "IDLE"; GasBtn.BackgroundTransparency = 0.6 end)

BrakeBtn.MouseButton1Down:Connect(function() Config.InputState = "BRAKE"; BrakeBtn.BackgroundTransparency = 0.2 end)
BrakeBtn.MouseButton1Up:Connect(function() Config.InputState = "IDLE"; BrakeBtn.BackgroundTransparency = 0.6 end)
BrakeBtn.MouseLeave:Connect(function() Config.InputState = "IDLE"; BrakeBtn.BackgroundTransparency = 0.6 end)

-- === PHYSICS LOOP (HYBRID INPUT) ===
RunService.Heartbeat:Connect(function()
    local char = player.Character
    if not char then return end
    
    local driveSeat = nil
    local car = nil
    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid and humanoid.SeatPart then
        driveSeat = humanoid.SeatPart
        car = driveSeat.Parent
    else
        local carModel = Workspace:FindFirstChild("Lf20Besaya's Car")
        if carModel then 
            driveSeat = carModel:FindFirstChild("DriveSeat") 
            car = carModel
        end
    end
    
    if not driveSeat then return end
    
    -- === NATIVE INPUT DETECTION (BACKUP) ===
    -- This runs if you are using game controls (W/S/Touch) instead of Virtual Pedals
    Config.NativeGas = false
    Config.NativeBrake = false
    
    -- Check 1: Seat Throttle
    if driveSeat.Throttle > 0 then Config.NativeGas = true end
    if driveSeat.Throttle < 0 then Config.NativeBrake = true end
    
    -- Check 2: Values Folder (Robust Check)
    if car then
        -- Search recursively for "Throttle" value
        for _, v in pairs(car:GetDescendants()) do
            if v.Name == "Throttle" and v:IsA("NumberValue") or v:IsA("IntValue") then
                if v.Value > 0 then Config.NativeGas = true end
                if v.Value < 0 then Config.NativeBrake = true end
                break -- Found it
            end
        end
    end
    
    -- === FORCE APPLICATION ===
    local thrust = driveSeat:FindFirstChild("J38_Thrust")
    local anchor = driveSeat:FindFirstChild("J38_Anchor")
    local att = driveSeat:FindFirstChild("J38_Att")
    
    if not att then
        att = Instance.new("Attachment", driveSeat)
        att.Name = "J38_Att"
    end
    
    -- GAS: Virtual OR Native
    if Config.InputState == "GAS" or Config.NativeGas then
        if anchor then anchor:Destroy() end
        if not thrust then
            thrust = Instance.new("VectorForce", driveSeat)
            thrust.Name = "J38_Thrust"
            thrust.Attachment0 = att
            thrust.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
        end
        thrust.Force = Vector3.new(0, 0, -Config.BoostPower) -- Forward
        
    -- BRAKE: Virtual OR Native
    elseif Config.InputState == "BRAKE" or Config.NativeBrake then
        if anchor then anchor:Destroy() end
        if not thrust then
            thrust = Instance.new("VectorForce", driveSeat)
            thrust.Name = "J38_Thrust"
            thrust.Attachment0 = att
            thrust.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
        end
        thrust.Force = Vector3.new(0, 0, Config.BoostPower) -- Reverse
        
    else -- IDLE
        if thrust then thrust:Destroy() end
        
        local speed = driveSeat.AssemblyLinearVelocity.Magnitude
        if speed > Config.StopThreshold then
            -- Coast
            if anchor then anchor:Destroy() end
        else
            -- Park
            if not anchor then
                anchor = Instance.new("BodyVelocity", driveSeat)
                anchor.Name = "J38_Anchor"
                anchor.MaxForce = Vector3.new(100000, 0, 100000)
                anchor.Velocity = Vector3.new(0, 0, 0)
            end
        end
    end
end)
