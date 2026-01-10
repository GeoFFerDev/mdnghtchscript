-- [[ JOSEPEDOV11: TUNE INJECTOR ]] --
-- Features: Tune Event Injection (Native Speed), Traffic Jammer, Instant Start
-- Optimized for Delta

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- === CONFIGURATION ===
local Config = {
    TrafficBlocked = false,
}

-- === TRAFFIC JAMMER (The Working Hook) ===
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
ScreenGui.Name = "JOSEPEDOV11_UI"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 200) 
MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 20)
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
OpenBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 150)
OpenBtn.Text = "J11"
OpenBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
OpenBtn.Font = Enum.Font.GothamBlack
OpenBtn.TextSize = 18
OpenBtn.Visible = false 
OpenBtn.Parent = ScreenGui
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 12)

-- Title
local Title = Instance.new("TextLabel")
Title.Text = "JOSEPEDOV11"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(0, 255, 150) -- Spring Green
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 18
Title.Parent = MainFrame

-- [BUTTON] INJECT SUPER TUNE
local TuneBtn = Instance.new("TextButton")
TuneBtn.Size = UDim2.new(0.9, 0, 0, 40)
TuneBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
TuneBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 0) -- Orange
TuneBtn.Text = "🔥 Inject Super Tune"
TuneBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TuneBtn.Font = Enum.Font.GothamBold
TuneBtn.TextSize = 14
TuneBtn.Parent = MainFrame
Instance.new("UICorner", TuneBtn).CornerRadius = UDim.new(0, 6)

TuneBtn.MouseButton1Click:Connect(function()
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") and char.Humanoid.SeatPart then
        local car = char.Humanoid.SeatPart.Parent
        
        -- Locate the Car Value Object (Based on your decompiled script Line 6)
        local carValue = car:FindFirstChild("Car") and car.Car.Value or car
        
        -- 1. Find the Tune Module
        local tuneModule = carValue:FindFirstChild("A-Chassis Tune")
        -- 2. Find the Event (Line 21 of your script)
        local updateEvent = carValue:FindFirstChild("TuneUpdatedEvent")
        
        if tuneModule then
            local success, tune = pcall(require, tuneModule)
            if success and tune then
                -- === THE GOD MODE STATS ===
                tune.Horsepower = 50000    -- Massive Power
                tune.Torque = 20000        -- Instant Acceleration
                tune.MaxSpeed = 600        -- Speed Limit
                tune.PeakRPM = 12000       -- High Revs
                tune.Redline = 13000       -- Limit
                tune.Turbochargers = 3     -- Triple Turbo
                tune.T_Boost = 200         -- 200 PSI Boost
                tune.Superchargers = 2
                tune.S_Boost = 200
                
                -- Gear Ratio Fix (Longer gears for higher speed)
                tune.FinalDrive = 1.0 
                
                -- Force the Event to fire
                if updateEvent then
                    updateEvent:Fire(tune)
                    TuneBtn.Text = "✅ Tune Injected!"
                    TuneBtn.BackgroundColor3 = Color3.fromRGB(0, 200, 50)
                else
                    TuneBtn.Text = "⚠️ Event Not Found"
                end
                
                -- Also force attributes just in case
                carValue:SetAttribute("MaxBoost", 500)
                carValue:SetAttribute("CurrentBoost", 500)
                
            else
                TuneBtn.Text = "❌ Tune Require Failed"
            end
        else
            TuneBtn.Text = "❌ No Tune Module"
        end
        
        task.wait(2)
        TuneBtn.Text = "🔥 Inject Super Tune"
        TuneBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
    else
        TuneBtn.Text = "⚠️ Sit in Driver Seat"
        task.wait(1)
        TuneBtn.Text = "🔥 Inject Super Tune"
    end
end)

-- [BUTTON] FORCE START ENGINE
local StartBtn = Instance.new("TextButton")
StartBtn.Size = UDim2.new(0.9, 0, 0, 40)
StartBtn.Position = UDim2.new(0.05, 0, 0.50, 0)
StartBtn.BackgroundColor3 = Color3.fromRGB(0, 150, 255)
StartBtn.Text = "⚡ Force Start Engine"
StartBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
StartBtn.Font = Enum.Font.GothamBold
StartBtn.TextSize = 14
StartBtn.Parent = MainFrame
Instance.new("UICorner", StartBtn).CornerRadius = UDim.new(0, 6)

StartBtn.MouseButton1Click:Connect(function()
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") and char.Humanoid.SeatPart then
        local car = char.Humanoid.SeatPart.Parent
        local carValue = car:FindFirstChild("Car") and car.Car.Value or car
        local mainRep = carValue:FindFirstChild("MainReplication")
        
        -- Force the server to turn it on (Line 30 of your script)
        if mainRep then
            mainRep:FireServer("IsOn", true)
            StartBtn.Text = "✅ Signal Sent"
        else
            StartBtn.Text = "❌ Remote Not Found"
        end
    else
        StartBtn.Text = "⚠️ Sit in Seat"
    end
    task.wait(1)
    StartBtn.Text = "⚡ Force Start Engine"
end)

-- [TOGGLE] TRAFFIC JAMMER
local TrafficBtn = Instance.new("TextButton")
TrafficBtn.Size = UDim2.new(0.9, 0, 0, 40)
TrafficBtn.Position = UDim2.new(0.05, 0, 0.75, 0)
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
