-- [[ JOSEPEDOV36: CLEAN SCREEN ]] --
-- Features: Minimizeable UI, Draggable Icon, Virtual Pedals, Natural Drive
-- Optimized for Delta | The Final "Sweet Spot" Version

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
    InputState = "IDLE", -- GAS, BRAKE, IDLE
    StopThreshold = 5,   -- Parking Brake Threshold
    UIHidden = false     -- Toggle State
}

-- === DRAG FUNCTION (Mobile & PC Friendly) ===
local function MakeDraggable(gui)
    local dragging
    local dragInput
    local dragStart
    local startPos

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
ScreenGui.Name = "JOSEPEDOV36_UI"
ScreenGui.Parent = game.CoreGui

-- [1] THE ICON (Visible when minimized)
local OpenIcon = Instance.new("TextButton")
OpenIcon.Name = "OpenIcon"
OpenIcon.Size = UDim2.new(0, 50, 0, 50)
OpenIcon.Position = UDim2.new(0.02, 0, 0.2, 0)
OpenIcon.BackgroundColor3 = Color3.fromRGB(0, 255, 255) -- Cyan
OpenIcon.Text = "J36"
OpenIcon.TextColor3 = Color3.fromRGB(0, 0, 0)
OpenIcon.Font = Enum.Font.GothamBlack
OpenIcon.TextSize = 18
OpenIcon.Visible = false -- Hidden by default
OpenIcon.Parent = ScreenGui
Instance.new("UICorner", OpenIcon).CornerRadius = UDim.new(0, 25) -- Circle
MakeDraggable(OpenIcon) -- MAKE IT DRAGGABLE!

-- [2] MAIN CONTROL PANEL
local ControlFrame = Instance.new("Frame")
ControlFrame.Name = "ControlFrame"
ControlFrame.Size = UDim2.new(0, 160, 0, 90)
ControlFrame.Position = UDim2.new(0.02, 0, 0.3, 0)
ControlFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
ControlFrame.BorderSizePixel = 2
ControlFrame.BorderColor3 = Color3.fromRGB(0, 255, 255)
ControlFrame.Active = true
ControlFrame.Parent = ScreenGui
MakeDraggable(ControlFrame) -- MAKE IT DRAGGABLE!

local Title = Instance.new("TextLabel")
Title.Text = "J36: CLEAN"
Title.Size = UDim2.new(1, 0, 0, 20)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(0, 255, 255)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 14
Title.Parent = ControlFrame

-- Traffic Button
local TrafficBtn = Instance.new("TextButton")
TrafficBtn.Size = UDim2.new(0.9, 0, 0, 40)
TrafficBtn.Position = UDim2.new(0.05, 0, 0.40, 0)
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
MakeDraggable(GasBtn) -- You can move the pedal if you want!

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
MakeDraggable(BrakeBtn) -- You can move the brake too!

-- === MINIMIZE/OPEN LOGIC ===
MinBtn.MouseButton1Click:Connect(function()
    -- Hide Everything
    ControlFrame.Visible = false
    GasBtn.Visible = false
    BrakeBtn.Visible = false
    -- Show Icon
    OpenIcon.Visible = true
end)

OpenIcon.MouseButton1Click:Connect(function()
    -- Show Everything
    ControlFrame.Visible = true
    GasBtn.Visible = true
    BrakeBtn.Visible = true
    -- Hide Icon
    OpenIcon.Visible = false
end)

-- === INPUT HANDLING ===
GasBtn.MouseButton1Down:Connect(function() Config.InputState = "GAS"; GasBtn.BackgroundTransparency = 0.2 end)
GasBtn.MouseButton1Up:Connect(function() Config.InputState = "IDLE"; GasBtn.BackgroundTransparency = 0.6 end)
GasBtn.MouseLeave:Connect(function() Config.InputState = "IDLE"; GasBtn.BackgroundTransparency = 0.6 end)

BrakeBtn.MouseButton1Down:Connect(function() Config.InputState = "BRAKE"; BrakeBtn.BackgroundTransparency = 0.2 end)
BrakeBtn.MouseButton1Up:Connect(function() Config.InputState = "IDLE"; BrakeBtn.BackgroundTransparency = 0.6 end)
BrakeBtn.MouseLeave:Connect(function() Config.InputState = "IDLE"; BrakeBtn.BackgroundTransparency = 0.6 end)

-- === PHYSICS LOOP (SMART COASTING) ===
RunService.Heartbeat:Connect(function()
    local char = player.Character
    if not char then return end
    
    local driveSeat = nil
    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid and humanoid.SeatPart then
        driveSeat = humanoid.SeatPart
    else
        local carModel = Workspace:FindFirstChild("Lf20Besaya's Car")
        if carModel then driveSeat = carModel:FindFirstChild("DriveSeat") end
    end
    
    if not driveSeat then return end
    
    local thrust = driveSeat:FindFirstChild("J36_Thrust")
    local anchor = driveSeat:FindFirstChild("J36_Anchor")
    local att = driveSeat:FindFirstChild("J36_Att")
    
    if not att then
        att = Instance.new("Attachment", driveSeat)
        att.Name = "J36_Att"
    end
    
    if Config.InputState == "GAS" then
        if anchor then anchor:Destroy() end
        if not thrust then
            thrust = Instance.new("VectorForce", driveSeat)
            thrust.Name = "J36_Thrust"
            thrust.Attachment0 = att
            thrust.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
        end
        thrust.Force = Vector3.new(0, 0, -Config.BoostPower) -- Forward
        
    elseif Config.InputState == "BRAKE" then
        if anchor then anchor:Destroy() end
        if not thrust then
            thrust = Instance.new("VectorForce", driveSeat)
            thrust.Name = "J36_Thrust"
            thrust.Attachment0 = att
            thrust.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
        end
        thrust.Force = Vector3.new(0, 0, Config.BoostPower) -- Reverse
        
    else -- IDLE
        if thrust then thrust:Destroy() end
        
        local speed = driveSeat.AssemblyLinearVelocity.Magnitude
        if speed > Config.StopThreshold then
            -- Coasting (Natural Slowdown)
            if anchor then anchor:Destroy() end
        else
            -- Parking Brake (Stop Creep)
            if not anchor then
                anchor = Instance.new("BodyVelocity", driveSeat)
                anchor.Name = "J36_Anchor"
                anchor.MaxForce = Vector3.new(100000, 0, 100000)
                anchor.Velocity = Vector3.new(0, 0, 0)
            end
        end
    end
end)
