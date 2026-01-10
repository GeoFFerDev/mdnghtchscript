-- [[ JOSEPEDOV16: ICE SKATER ]] --
-- Features: Zero Friction Speed, Anti-Fly Downforce, Traffic Jammer
-- Optimized for Delta | Solves the "Flying" glitch by keeping weight but removing drag

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- === CONFIGURATION ===
local Config = {
    SpeedEnabled = false,
    TrafficBlocked = false,
    PushPower = 8000,    -- Forward force (Adjust this for speed)
    Downforce = 4000,    -- Downward force to stop flying
    TireFriction = 0.01, -- "Ice" friction level
    OriginalFriction = 2 -- Default friction to restore later
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
ScreenGui.Name = "JOSEPEDOV16_UI"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 220)
MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 20, 25) -- Steel Blue
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 255) -- Cyan
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Text = "JOSEPEDOV16"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(0, 255, 255)
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
        TrafficBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        
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

-- [BUTTON] 2. ICE SKATE MODE (Speed)
local SpeedBtn = Instance.new("TextButton")
SpeedBtn.Size = UDim2.new(0.9, 0, 0, 40)
SpeedBtn.Position = UDim2.new(0.05, 0, 0.45, 0)
SpeedBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SpeedBtn.Text = "❄️ Ice Skate Mode: OFF"
SpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBtn.Font = Enum.Font.GothamBold
SpeedBtn.TextSize = 14
SpeedBtn.Parent = MainFrame
Instance.new("UICorner", SpeedBtn).CornerRadius = UDim.new(0, 6)

SpeedBtn.MouseButton1Click:Connect(function()
    Config.SpeedEnabled = not Config.SpeedEnabled
    if Config.SpeedEnabled then
        SpeedBtn.Text = "❄️ Ice Skate Mode: ON"
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 255)
        SpeedBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    else
        SpeedBtn.Text = "❄️ Ice Skate Mode: OFF"
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        SpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        
        -- Restore Friction
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") and char.Humanoid.SeatPart then
            local car = char.Humanoid.SeatPart.Parent
            for _, part in pairs(car:GetDescendants()) do
                if part:IsA("BasePart") and part.Name:match("Wheel") then
                    part.CustomPhysicalProperties = PhysicalProperties.new(part.CustomPhysicalProperties.Density, Config.OriginalFriction, part.CustomPhysicalProperties.Elasticity)
                end
            end
        end
    end
end)

-- [BUTTON] 3. PANIC RESET
local PanicBtn = Instance.new("TextButton")
PanicBtn.Size = UDim2.new(0.9, 0, 0, 40)
PanicBtn.Position = UDim2.new(0.05, 0, 0.70, 0)
PanicBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
PanicBtn.Text = "⚠️ PANIC RESET"
PanicBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PanicBtn.Font = Enum.Font.GothamBold
PanicBtn.TextSize = 14
PanicBtn.Parent = MainFrame
Instance.new("UICorner", PanicBtn).CornerRadius = UDim.new(0, 6)

PanicBtn.MouseButton1Click:Connect(function()
    -- Reset everything
    Config.SpeedEnabled = false
    SpeedBtn.Text = "❄️ Ice Skate Mode: OFF"
    SpeedBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") and char.Humanoid.SeatPart then
        local car = char.Humanoid.SeatPart.Parent
        -- Destroy Forces
        local seat = char.Humanoid.SeatPart
        if seat:FindFirstChild("J16_Push") then seat.J16_Push:Destroy() end
        if seat:FindFirstChild("J16_Down") then seat.J16_Down:Destroy() end
        if seat:FindFirstChild("J16_Att") then seat.J16_Att:Destroy() end
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
    
    -- 1. SETUP FORCES (If not exists)
    local att = seat:FindFirstChild("J16_Att")
    local pushForce = seat:FindFirstChild("J16_Push")
    local downForce = seat:FindFirstChild("J16_Down")
    
    if not att then
        att = Instance.new("Attachment", seat)
        att.Name = "J16_Att"
        
        -- Forward Pusher
        pushForce = Instance.new("VectorForce")
        pushForce.Name = "J16_Push"
        pushForce.Attachment0 = att
        pushForce.RelativeTo = Enum.ActuatorRelativeTo.Attachment0 -- Local space (Forward)
        pushForce.Parent = seat
        
        -- Downforce (Anti-Fly)
        downForce = Instance.new("VectorForce")
        downForce.Name = "J16_Down"
        downForce.Attachment0 = att
        downForce.RelativeTo = Enum.ActuatorRelativeTo.World -- World space (Always Down)
        downForce.Parent = seat
    end
    
    -- 2. APPLY "ICE" FRICTION TO WHEELS
    -- We do this constantly because the game might try to reset it
    for _, part in pairs(car:GetDescendants()) do
        if part:IsA("BasePart") then
            -- Find wheels by name (FL, FR, etc.) or by common name "Wheel"
            if part.Name == "FL" or part.Name == "FR" or part.Name == "RL" or part.Name == "RR" or part.Name:match("Wheel") then
                -- Density, Friction (0.01), Elasticity, FrictionWeight, ElasticityWeight
                part.CustomPhysicalProperties = PhysicalProperties.new(part.CustomPhysicalProperties.Density, Config.TireFriction, 0, 100, 100)
            end
        end
    end
    
    -- 3. APPLY FORCES
    -- Always apply Downforce to keep car glued to road
    downForce.Force = Vector3.new(0, -Config.Downforce, 0)
    
    -- Apply Push force based on throttle
    if seat.Throttle > 0 then
        pushForce.Force = Vector3.new(0, 0, -Config.PushPower) -- Forward
    elseif seat.Throttle < 0 then
        pushForce.Force = Vector3.new(0, 0, Config.PushPower) -- Backward/Brake
    else
        pushForce.Force = Vector3.new(0, 0, 0) -- Coasting
    end
end)

-- Close
local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(0.85, 0, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.Parent = MainFrame
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
