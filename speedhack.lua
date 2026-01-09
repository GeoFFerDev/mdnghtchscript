-- [[ ULTIMATE CAR MOD MENU V2 ]] --
-- Features: Remote Traffic Control, Limit Breaker Speed, UI
-- Updated with Remote Spy Data

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

-- === REMOTE EVENT SETUP (FROM YOUR SPY) ===
-- We try to find that specific Remote ID you gave me
local trafficRemote = nil
local success, err = pcall(function()
    trafficRemote = ReplicatedStorage.Modules.Modules.Network["21bb1ffe-8b9c-42bf-9ee0-905a7712ce59"]
end)

if not trafficRemote then
    warn("⚠️ Could not find the specific RemoteEvent ID! Traffic buttons might not work.")
    -- Fallback: Try to find ANY remote in that folder if the ID changed
    local netFolder = ReplicatedStorage:FindFirstChild("Modules") and ReplicatedStorage.Modules:FindFirstChild("Modules") and ReplicatedStorage.Modules.Modules:FindFirstChild("Network")
    if netFolder then
        trafficRemote = netFolder:GetChildren()[1] -- Grab the first remote found
        warn("⚠️ Trying alternative remote: " .. trafficRemote.Name)
    end
end

-- === UI CREATION ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CarModMenuV2"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 260) -- Slightly taller
MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Title
local Title = Instance.new("TextLabel")
Title.Text = "🏎️ Car Mods V2"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = MainFrame

-- [TOGGLE] SPEED HACK
local SpeedBtn = Instance.new("TextButton")
SpeedBtn.Size = UDim2.new(0.9, 0, 0, 40)
SpeedBtn.Position = UDim2.new(0.05, 0, 0.15, 0)
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

-- [TOGGLE] TRAFFIC SERVER (Remote)
local TrafficBtn = Instance.new("TextButton")
TrafficBtn.Size = UDim2.new(0.9, 0, 0, 40)
TrafficBtn.Position = UDim2.new(0.05, 0, 0.35, 0)
TrafficBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50) -- Green (Assume ON initially)
TrafficBtn.Text = "Traffic: ON"
TrafficBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TrafficBtn.Font = Enum.Font.GothamBold
TrafficBtn.TextSize = 14
TrafficBtn.Parent = MainFrame
Instance.new("UICorner", TrafficBtn).CornerRadius = UDim.new(0, 6)

local trafficState = true
TrafficBtn.MouseButton1Click:Connect(function()
    trafficState = not trafficState
    
    if trafficRemote then
        -- THIS IS THE MAGIC LINE FROM YOUR SPY
        -- We send 'false' to disable, 'true' to enable
        trafficRemote:FireServer("Traffic", trafficState)
        
        if trafficState then
            TrafficBtn.Text = "Traffic: ON"
            TrafficBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50)
        else
            TrafficBtn.Text = "Traffic: OFF"
            TrafficBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        end
    else
        TrafficBtn.Text = "Remote Not Found!"
    end
end)

-- [BUTTON] CLEAR EXISTING CARS (Cleanup)
local ClearBtn = Instance.new("TextButton")
ClearBtn.Size = UDim2.new(0.9, 0, 0, 40)
ClearBtn.Position = UDim2.new(0.05, 0, 0.55, 0)
ClearBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0) -- Orange
ClearBtn.Text = "🧹 Clear Existing Cars"
ClearBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ClearBtn.Font = Enum.Font.GothamBold
ClearBtn.TextSize = 14
ClearBtn.Parent = MainFrame
Instance.new("UICorner", ClearBtn).CornerRadius = UDim.new(0, 6)

ClearBtn.MouseButton1Click:Connect(function()
    -- Attempts to find typical traffic folders and clear them
    local folders = {"NPC vehicles", "Traffic", "Vehicles", "NPCs"}
    local count = 0
    for _, name in pairs(folders) do
        local folder = Workspace:FindFirstChild(name)
        if folder then
            for _, car in pairs(folder:GetChildren()) do
                car:Destroy()
                count = count + 1
            end
        end
    end
    game.StarterGui:SetCore("SendNotification", {Title = "Cleanup"; Text = "Removed " .. count .. " cars."; Duration = 2;})
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

-- === SPEED LOOP ===
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
        if currentSpeed < (Config.TargetSpeed * 1.5) then 
            existingVel.Velocity = seat.CFrame.LookVector * (currentSpeed + Config.AccelPower)
        else
             existingVel.Velocity = seat.CFrame.LookVector * currentSpeed
        end
    elseif seat.Throttle < 0 then
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
        if existingVel then existingVel:Destroy() end
    end
end)
