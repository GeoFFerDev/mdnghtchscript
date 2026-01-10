-- [[ JOSEPEDOV8: LINEAR VELOCITY ]] --
-- Features: Traffic Jammer (Working), LinearVelocity Speed (New), Permanent UI
-- Optimized for Delta

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- === CONFIGURATION ===
local Config = {
    SpeedEnabled = false,
    TrafficBlocked = false,
    TargetSpeed = 450,      -- Speed Limit
    Power = 50000           -- Force Power
}

-- === TRAFFIC JAMMER (HOOK) ===
local function InstallTrafficHook()
    local event = ReplicatedStorage:FindFirstChild("CreateNPCVehicle")
    if event then
        for _, connection in pairs(getconnections(event.OnClientEvent)) do
            local oldFunction = connection.Function
            if oldFunction then
                hookfunction(connection.Function, function(...)
                    if Config.TrafficBlocked then return end -- BLOCK
                    return oldFunction(...) -- ALLOW
                end)
            end
        end
    end
end
InstallTrafficHook()

-- === UI CREATION ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JOSEPEDOV8_UI"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 180) 
MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15) -- Deep Blue Theme
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Open Button
local OpenBtn = Instance.new("TextButton")
OpenBtn.Name = "OpenBtn"
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0, 10, 0.4, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
OpenBtn.Text = "J8"
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.Font = Enum.Font.GothamBlack
OpenBtn.TextSize = 18
OpenBtn.Visible = false 
OpenBtn.Parent = ScreenGui
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 12)

-- Title
local Title = Instance.new("TextLabel")
Title.Text = "JOSEPEDOV8"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(0, 150, 255)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 18
Title.Parent = MainFrame

-- [TOGGLE] SPEED HACK (LinearVelocity)
local SpeedBtn = Instance.new("TextButton")
SpeedBtn.Size = UDim2.new(0.9, 0, 0, 40)
SpeedBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
SpeedBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
SpeedBtn.Text = "Speed Hack: OFF"
SpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBtn.Font = Enum.Font.GothamBold
SpeedBtn.TextSize = 14
SpeedBtn.Parent = MainFrame
Instance.new("UICorner", SpeedBtn).CornerRadius = UDim.new(0, 6)

SpeedBtn.MouseButton1Click:Connect(function()
    Config.SpeedEnabled = not Config.SpeedEnabled
    if Config.SpeedEnabled then
        SpeedBtn.Text = "Speed Hack: ON"
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50) 
    else
        SpeedBtn.Text = "Speed Hack: OFF"
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        -- Cleanup immediately
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") and char.Humanoid.SeatPart then
            local att = char.Humanoid.SeatPart:FindFirstChild("SpeedAtt")
            local lv = char.Humanoid.SeatPart:FindFirstChild("SpeedControl")
            if att then att:Destroy() end
            if lv then lv:Destroy() end
        end
    end
end)

-- [TOGGLE] TRAFFIC JAMMER
local TrafficBtn = Instance.new("TextButton")
TrafficBtn.Size = UDim2.new(0.9, 0, 0, 40)
TrafficBtn.Position = UDim2.new(0.05, 0, 0.55, 0)
TrafficBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
TrafficBtn.Text = "Traffic: ALLOWED"
TrafficBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TrafficBtn.Font = Enum.Font.GothamBold
TrafficBtn.TextSize = 14
TrafficBtn.Parent = MainFrame
Instance.new("UICorner", TrafficBtn).CornerRadius = UDim.new(0, 6)

TrafficBtn.MouseButton1Click:Connect(function()
    Config.TrafficBlocked = not Config.TrafficBlocked
    if Config.TrafficBlocked then
        TrafficBtn.Text = "Traffic: BLOCKED 🚫"
        TrafficBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        
        -- Instant Clear
        local npcFolder = Workspace:FindFirstChild("NPCVehicles") or Workspace:FindFirstChild("Traffic") or Workspace:FindFirstChild("NPC vehicles")
        if npcFolder then npcFolder:ClearAllChildren() end
    else
        TrafficBtn.Text = "Traffic: ALLOWED ✅"
        TrafficBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
    end
end)

-- Minimize
local MinBtn = Instance.new("TextButton")
MinBtn.Text = "-"
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(0.70, 0, 0, 0)
MinBtn.BackgroundTransparency = 1
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Font = Enum.Font.GothamBlack
MinBtn.TextSize = 24
MinBtn.Parent = MainFrame
MinBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false; OpenBtn.Visible = true end)
OpenBtn.MouseButton1Click:Connect(function() MainFrame.Visible = true; OpenBtn.Visible = false end)

-- Close
local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(0.85, 0, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.Font = Enum.Font.GothamBlack
CloseBtn.TextSize = 18
CloseBtn.Parent = MainFrame
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)

-- === NEW PHYSICS ENGINE (LINEAR VELOCITY) ===
RunService.Heartbeat:Connect(function()
    if not Config.SpeedEnabled then return end
    
    local char = player.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid or not humanoid.SeatPart then return end
    
    local seat = humanoid.SeatPart
    local currentSpeed = seat.Velocity.Magnitude
    
    -- Check for Attachment (Required for LinearVelocity)
    local att = seat:FindFirstChild("SpeedAtt")
    if not att then
        att = Instance.new("Attachment")
        att.Name = "SpeedAtt"
        att.Parent = seat
    end
    
    -- Check for LinearVelocity (The Upgrade)
    local lv = seat:FindFirstChild("SpeedControl")
    
    if seat.Throttle > 0 then
        if not lv then
            lv = Instance.new("LinearVelocity")
            lv.Name = "SpeedControl"
            lv.Attachment0 = att
            lv.MaxForce = Config.Power -- 50,000 Force
            lv.RelativeTo = Enum.ActuatorRelativeTo.Attachment0 -- Pushes relative to car direction
            lv.Parent = seat
        end
        
        -- PUSH FORWARD
        -- Vector3.new(0, 0, -1) is "Forward" for most Roblox cars
        if currentSpeed < Config.TargetSpeed then
            lv.VectorVelocity = Vector3.new(0, 0, -Config.TargetSpeed) 
        else
            -- If we hit max speed, just maintain it
            lv.VectorVelocity = Vector3.new(0, 0, -currentSpeed)
        end
        
    elseif seat.Throttle < 0 then
        -- BRAKING (Reverse Force)
        if not lv then
            lv = Instance.new("LinearVelocity")
            lv.Name = "SpeedControl"
            lv.Attachment0 = att
            lv.MaxForce = Config.Power
            lv.RelativeTo = Enum.ActuatorRelativeTo.World
            lv.Parent = seat
        end
        
        -- Use World Velocity to stop completely
        lv.VectorVelocity = Vector3.new(0, 0, 0) 
        
    else
        -- COASTING (Remove Force)
        if lv then lv:Destroy() end
    end
end)
