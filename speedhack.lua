-- [[ ULTIMATE CAR MOD MENU V1 ]] --
-- Features: Speed Hack, Drag/Super Brakes, Traffic Deleter
-- Optimized for Delta/Mobile

local library = {} -- Simple Vanilla UI Library
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer
local mouse = player:GetMouse()

-- === SETTINGS ===
local Config = {
    SpeedEnabled = false,
    TrafficLoop = false,
    TargetSpeed = 400,    -- Max Speed (MPH)
    AccelPower = 2,       -- Acceleration
    BrakePower = 0.9,     -- Braking Strength
}

-- === UI CREATION ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "CarModMenu"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 250)
MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true -- Makes it movable on mobile
MainFrame.Parent = ScreenGui

-- Corner Radius
local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Title Bar
local Title = Instance.new("TextLabel")
Title.Text = "🏎️ Car Mods V1"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Title.Parent = MainFrame

-- [TOGGLE] SPEED HACK
local SpeedBtn = Instance.new("TextButton")
SpeedBtn.Size = UDim2.new(0.9, 0, 0, 40)
SpeedBtn.Position = UDim2.new(0.05, 0, 0.18, 0)
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
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50) -- Green
    else
        SpeedBtn.Text = "Speed Hack: OFF"
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Red
        -- Cleanup physics immediately
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") and char.Humanoid.SeatPart then
            local seat = char.Humanoid.SeatPart
            if seat:FindFirstChild("LimitBreaker") then
                seat.LimitBreaker:Destroy()
            end
        end
    end
end)

-- [BUTTON] NUKE TRAFFIC
local NukeBtn = Instance.new("TextButton")
NukeBtn.Size = UDim2.new(0.9, 0, 0, 40)
NukeBtn.Position = UDim2.new(0.05, 0, 0.40, 0)
NukeBtn.BackgroundColor3 = Color3.fromRGB(255, 150, 0) -- Orange
NukeBtn.Text = "🗑️ Force Delete Traffic"
NukeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
NukeBtn.Font = Enum.Font.GothamBold
NukeBtn.TextSize = 14
NukeBtn.Parent = MainFrame
Instance.new("UICorner", NukeBtn).CornerRadius = UDim.new(0, 6)

-- Traffic Logic
local function RemoveTraffic()
    -- Look for typical names. Adjust "NPC vehicles" if the name is different.
    local folders = {"NPC vehicles", "Traffic", "Vehicles", "NPCs"}
    local found = false
    
    for _, name in pairs(folders) do
        local folder = Workspace:FindFirstChild(name)
        if folder then
            folder:ClearAllChildren() -- Deletes all cars inside
            found = true
        end
    end
    
    if found then
        game.StarterGui:SetCore("SendNotification", {Title = "Traffic"; Text = "Deleted all NPC cars!"; Duration = 2;})
    else
        game.StarterGui:SetCore("SendNotification", {Title = "Error"; Text = "Traffic folder not found!"; Duration = 2;})
    end
end

NukeBtn.MouseButton1Click:Connect(RemoveTraffic)

-- [TOGGLE] AUTO DELETE TRAFFIC
local LoopTrafficBtn = Instance.new("TextButton")
LoopTrafficBtn.Size = UDim2.new(0.9, 0, 0, 40)
LoopTrafficBtn.Position = UDim2.new(0.05, 0, 0.62, 0)
LoopTrafficBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
LoopTrafficBtn.Text = "Loop Delete: OFF"
LoopTrafficBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
LoopTrafficBtn.Font = Enum.Font.GothamBold
LoopTrafficBtn.TextSize = 14
LoopTrafficBtn.Parent = MainFrame
Instance.new("UICorner", LoopTrafficBtn).CornerRadius = UDim.new(0, 6)

LoopTrafficBtn.MouseButton1Click:Connect(function()
    Config.TrafficLoop = not Config.TrafficLoop
    if Config.TrafficLoop then
        LoopTrafficBtn.Text = "Loop Delete: ON"
        LoopTrafficBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        LoopTrafficBtn.BackgroundColor3 = Color3.fromRGB(100, 50, 50) -- Dark Red
    else
        LoopTrafficBtn.Text = "Loop Delete: OFF"
        LoopTrafficBtn.TextColor3 = Color3.fromRGB(200, 200, 200)
        LoopTrafficBtn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    end
end)

-- [BUTTON] CLOSE UI
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

-- === MAIN LOOPS ===

-- 1. Speed Hack Loop
RunService.Heartbeat:Connect(function()
    if not Config.SpeedEnabled then return end

    local char = player.Character
    if not char then return end
    
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid or not humanoid.SeatPart then return end
    
    local seat = humanoid.SeatPart
    local existingVel = seat:FindFirstChild("LimitBreaker")
    local currentSpeed = seat.Velocity.Magnitude
    
    -- GAS
    if seat.Throttle > 0 then
        if not existingVel then
            local bv = Instance.new("BodyVelocity")
            bv.Name = "LimitBreaker"
            bv.MaxForce = Vector3.new(100000, 0, 100000) 
            bv.Parent = seat
            existingVel = bv
        end
        
        -- Logic: If under limit, accelerate. If over, maintain.
        if currentSpeed < (Config.TargetSpeed * 1.5) then 
            existingVel.Velocity = seat.CFrame.LookVector * (currentSpeed + Config.AccelPower)
        else
             existingVel.Velocity = seat.CFrame.LookVector * currentSpeed
        end
        
    -- BRAKE
    elseif seat.Throttle < 0 then
        if not existingVel then
            local bv = Instance.new("BodyVelocity")
            bv.Name = "LimitBreaker"
            bv.MaxForce = Vector3.new(100000, 0, 100000)
            bv.Parent = seat
            existingVel = bv
        end
        
        existingVel.Velocity = seat.Velocity * Config.BrakePower
        
        if seat.Velocity.Magnitude < 5 then
             existingVel:Destroy()
        end
        
    -- COAST
    else
        if existingVel then
            existingVel:Destroy()
        end
    end
end)

-- 2. Traffic Loop
spawn(function()
    while true do
        wait(1)
        if Config.TrafficLoop then
            RemoveTraffic()
        end
    end
end)
