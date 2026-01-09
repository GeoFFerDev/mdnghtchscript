-- [[ JOSEPEDOV4 CAR MENU ]] --
-- Features: Signal Blocker Traffic Control, Limit Breaker Speed, UI
-- Optimized for Delta (Requires 'getconnections')

local library = {} 
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- === CONFIGURATION ===
local Config = {
    SpeedEnabled = false,
    TargetSpeed = 400,    -- Max Speed (MPH)
    AccelPower = 2,       -- Acceleration
    BrakePower = 0.9,     -- Braking Strength
}

-- === UI CREATION ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JOSEPEDOV4_UI"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 230) -- Compact Size
MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20) -- Darker Theme
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

-- Rounded Corners
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- [TITLE] JOSEPEDOV4
local Title = Instance.new("TextLabel")
Title.Text = "JOSEPEDOV4"  -- <--- UPDATED TITLE HERE
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(0, 255, 255) -- Cyan Color for the Title
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 18
Title.Parent = MainFrame

-- [TOGGLE] SPEED HACK
local SpeedBtn = Instance.new("TextButton")
SpeedBtn.Size = UDim2.new(0.9, 0, 0, 40)
SpeedBtn.Position = UDim2.new(0.05, 0, 0.20, 0)
SpeedBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Red (Off)
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
        -- Cleanup
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") and char.Humanoid.SeatPart then
            if char.Humanoid.SeatPart:FindFirstChild("LimitBreaker") then
                char.Humanoid.SeatPart.LimitBreaker:Destroy()
            end
        end
    end
end)

-- [TOGGLE] BLOCK TRAFFIC SIGNAL (No Lag)
local TrafficBtn = Instance.new("TextButton")
TrafficBtn.Size = UDim2.new(0.9, 0, 0, 40)
TrafficBtn.Position = UDim2.new(0.05, 0, 0.45, 0)
TrafficBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50) -- Green (Traffic Allowed)
TrafficBtn.Text = "Traffic: ALLOWED"
TrafficBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TrafficBtn.Font = Enum.Font.GothamBold
TrafficBtn.TextSize = 14
TrafficBtn.Parent = MainFrame
Instance.new("UICorner", TrafficBtn).CornerRadius = UDim.new(0, 6)

local trafficBlocked = false

local function ToggleTrafficSignal(block)
    -- This uses the event you found in RemoteSpy
    local event = ReplicatedStorage:FindFirstChild("CreateNPCVehicle")
    
    if event then
        -- Find the "wire" (connection) and cut it
        for _, connection in pairs(getconnections(event.OnClientEvent)) do
            if block then
                connection:Disable() -- Turn OFF signal
            else
                connection:Enable()  -- Turn ON signal
            end
        end
    else
        warn("Could not find 'CreateNPCVehicle' event!")
    end
end

TrafficBtn.MouseButton1Click:Connect(function()
    trafficBlocked = not trafficBlocked
    
    if trafficBlocked then
        ToggleTrafficSignal(true) -- BLOCK IT
        TrafficBtn.Text = "Traffic: BLOCKED 🚫"
        TrafficBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Red
        
        -- Auto-clean existing cars when you block
        local npcFolder = Workspace:FindFirstChild("NPC vehicles") or Workspace:FindFirstChild("Traffic")
        if npcFolder then npcFolder:ClearAllChildren() end
        
    else
        ToggleTrafficSignal(false) -- ALLOW IT
        TrafficBtn.Text = "Traffic: ALLOWED ✅"
        TrafficBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50) -- Green
    end
end)

-- [BUTTON] CLOSE
local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(0.85, 0, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.Font = Enum.Font.GothamBlack
CloseBtn.TextSize = 18
CloseBtn.Parent = MainFrame

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- === SPEED LOOP LOGIC ===
RunService.Heartbeat:Connect(function()
    if not Config.SpeedEnabled then return end
    local char = player.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid or not humanoid.SeatPart then return end
    
    local seat = humanoid.SeatPart
    local existingVel = seat:FindFirstChild("LimitBreaker")
    local currentSpeed = seat.Velocity.Magnitude
    
    if seat.Throttle > 0 then
        if not existingVel then
            local bv = Instance.new("BodyVelocity")
            bv.Name = "LimitBreaker"
            bv.MaxForce = Vector3.new(100000, 0, 100000) 
            bv.Parent = seat
            existingVel = bv
        end
        -- Speed Cap Logic: Accelerate if under limit, maintain if over
        if currentSpeed < (Config.TargetSpeed * 1.5) then 
            existingVel.Velocity = seat.CFrame.LookVector * (currentSpeed + Config.AccelPower)
        else
             existingVel.Velocity = seat.CFrame.LookVector * currentSpeed
        end
    elseif seat.Throttle < 0 then
        -- Super Brakes
        if not existingVel then
            local bv = Instance.new("BodyVelocity")
            bv.Name = "LimitBreaker"
            bv.MaxForce = Vector3.new(100000, 0, 100000)
            bv.Parent = seat
            existingVel = bv
        end
        existingVel.Velocity = seat.Velocity * Config.BrakePower
        if seat.Velocity.Magnitude < 5 then existingVel:Destroy() end
    else
        -- Coasting
        if existingVel then existingVel:Destroy() end
    end
end)
