-- [[ JOSEPEDOV19: GEAR RATIO HACKER ]] --
-- Features: Transmission Tuning (Stable Speed), Traffic Jammer, Instant Torque
-- Optimized for Delta | Fixes "Glitching" by keeping physics normal

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- === CONFIGURATION ===
local Config = {
    SpeedEnabled = false,
    TrafficBlocked = false,
    -- Tuning Values
    HackedRatio = 0.2,      -- Lower = Higher Top Speed (0.2 is insane speed)
    HackedTorque = 15000,   -- Force to turn the taller gears
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
ScreenGui.Name = "JOSEPEDOV19_UI"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 220)
MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(255, 215, 0) -- Gold
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Text = "JOSEPEDOV19"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 215, 0)
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

-- [BUTTON] 2. TRANSMISSION HACK (The Stable Speed)
local TuneBtn = Instance.new("TextButton")
TuneBtn.Size = UDim2.new(0.9, 0, 0, 40)
TuneBtn.Position = UDim2.new(0.05, 0, 0.45, 0)
TuneBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TuneBtn.Text = "⚙️ Ratio Hack: OFF"
TuneBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TuneBtn.Font = Enum.Font.GothamBold
TuneBtn.TextSize = 14
TuneBtn.Parent = MainFrame
Instance.new("UICorner", TuneBtn).CornerRadius = UDim.new(0, 6)

TuneBtn.MouseButton1Click:Connect(function()
    Config.SpeedEnabled = not Config.SpeedEnabled
    if Config.SpeedEnabled then
        TuneBtn.Text = "⚙️ Ratio Hack: ACTIVE"
        TuneBtn.BackgroundColor3 = Color3.fromRGB(255, 215, 0) -- Gold
        TuneBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    else
        TuneBtn.Text = "⚙️ Ratio Hack: OFF"
        TuneBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        TuneBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end)

-- [BUTTON] 3. PANIC (Reset Stats)
local ResetBtn = Instance.new("TextButton")
ResetBtn.Size = UDim2.new(0.9, 0, 0, 40)
ResetBtn.Position = UDim2.new(0.05, 0, 0.70, 0)
ResetBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
ResetBtn.Text = "⚠️ RESET STATS"
ResetBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
ResetBtn.Font = Enum.Font.GothamBold
ResetBtn.TextSize = 14
ResetBtn.Parent = MainFrame
Instance.new("UICorner", ResetBtn).CornerRadius = UDim.new(0, 6)

ResetBtn.MouseButton1Click:Connect(function()
    Config.SpeedEnabled = false
    TuneBtn.Text = "⚙️ Ratio Hack: OFF"
    TuneBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
end)

-- === TUNING LOOP (Runs every frame to overwrite car settings) ===
RunService.RenderStepped:Connect(function()
    if not Config.SpeedEnabled then return end
    
    local char = player.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid or not humanoid.SeatPart then return end
    
    local car = humanoid.SeatPart.Parent
    -- Find the "Tune" Module in the car
    local tuneModule = car:FindFirstChild("A-Chassis Tune")
    
    if tuneModule then
        -- We try to update the values inside the module environment
        local success, tune = pcall(require, tuneModule)
        if success and tune then
            -- 1. HACK GEAR RATIOS (Speed Source)
            -- Normal FinalDrive is ~3.0. We set it to 0.2
            -- This makes wheels spin 15x faster for same RPM
            tune.FinalDrive = Config.HackedRatio
            
            -- 2. HACK TORQUE (Power Source)
            -- We need more power to turn these "heavy" gears
            tune.Horsepower = 10000 
            tune.Torque = Config.HackedTorque
            tune.PeakRPM = 9000
            tune.Redline = 10000
            
            -- 3. APPLY TO ATTRIBUTES (Just in case)
            -- The game script sometimes reads these instead of the module
            local carVal = car:FindFirstChild("Car") and car.Car.Value or car
            if carVal then
                carVal:SetAttribute("Torque", Config.HackedTorque)
                carVal:SetAttribute("Horsepower", 10000)
                carVal:SetAttribute("MaxSpeed", 999)
            end
        end
    end
end)

-- Close Button
local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(0.85, 0, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.Parent = MainFrame
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
