-- [[ JOSEPEDOV23: LOCAL OVERRIDE ]] --
-- Features: Local Tune Injection (Bypasses Server), Traffic Jammer
-- Optimized for Delta | Based on "Aspiration.txt" Local Event

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- === CONFIGURATION ===
local Config = {
    TrafficBlocked = false,
    -- The God Stats
    GodHP = 50000,
    GodTorque = 20000,
    GodRedline = 15000,
    GodBoost = 5000,
    GodRatio = 0.5 -- Lower = Higher Top Speed
}

-- === 1. TRAFFIC JAMMER (Working) ===
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
ScreenGui.Name = "JOSEPEDOV23_UI"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 220)
MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 0, 0) -- Dark Red
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Text = "JOSEPEDOV23"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 0, 0)
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

-- [BUTTON] 2. OVERRIDE ENGINE (Local)
local InjectBtn = Instance.new("TextButton")
InjectBtn.Size = UDim2.new(0.9, 0, 0, 50)
InjectBtn.Position = UDim2.new(0.05, 0, 0.45, 0)
InjectBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
InjectBtn.Text = "⚡ OVERRIDE ENGINE\n(Local Event Inject)"
InjectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
InjectBtn.Font = Enum.Font.GothamBold
InjectBtn.TextSize = 14
InjectBtn.Parent = MainFrame
Instance.new("UICorner", InjectBtn).CornerRadius = UDim.new(0, 6)

InjectBtn.MouseButton1Click:Connect(function()
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") and char.Humanoid.SeatPart then
        local car = char.Humanoid.SeatPart.Parent
        local carVal = car:FindFirstChild("Car") and car.Car.Value or car
        
        -- SEARCH FOR THE LOCAL EVENT
        -- It's inside the Car Model (usually named "TuneUpdatedEvent" or similar)
        local tuneEvent = carVal:FindFirstChild("TuneUpdatedEvent") or car:FindFirstChild("TuneUpdatedEvent")
        
        -- Debug Print
        print("Searching for Event in:", car.Name)
        if tuneEvent then
            print("FOUND EVENT:", tuneEvent:GetFullName())
            
            -- CONSTRUCT THE GOD TABLE
            -- We send ONLY what we want to change. A-Chassis merges it.
            local godStats = {
                ["Horsepower"] = Config.GodHP,
                ["Torque"] = Config.GodTorque,
                ["MaxTorque"] = Config.GodTorque, -- Sometimes named this
                ["PeakRPM"] = 12000,
                ["Redline"] = Config.GodRedline,
                ["E_Redline"] = Config.GodRedline, -- Seen in your log
                ["Turbochargers"] = 4,
                ["T_Boost"] = Config.GodBoost,
                ["FinalDrive"] = Config.GodRatio, -- Speed Hack
                ["SteerMaxTorque"] = 100000,      -- Grip
                ["RSteerMaxTorque"] = 100000
            }
            
            -- FIRE LOCAL
            tuneEvent:Fire(godStats)
            
            InjectBtn.Text = "✅ ENGINE OVERRIDDEN"
            InjectBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            
            -- VISUAL UPDATE (Optional)
            -- If the car has a "Values" folder, we update that too for the GUI
            local values = carVal:FindFirstChild("Values") or car:FindFirstChild("Values")
            if values then
                if values:FindFirstChild("Horsepower") then values.Horsepower.Value = Config.GodHP end
                if values:FindFirstChild("Torque") then values.Torque.Value = Config.GodTorque end
                if values:FindFirstChild("BoostTurbo") then values.BoostTurbo.Value = Config.GodBoost end
            end
            
        else
            InjectBtn.Text = "❌ Event Not Found"
            warn("Could not find 'TuneUpdatedEvent' in car!")
            -- Print children to console to help debug
            for _, v in pairs(car:GetChildren()) do print("Car Child:", v.Name, v.ClassName) end
        end
    else
        InjectBtn.Text = "⚠️ Sit in Driver Seat"
    end
    
    task.wait(2)
    InjectBtn.Text = "⚡ OVERRIDE ENGINE\n(Local Event Inject)"
    InjectBtn.BackgroundColor3 = Color3.fromRGB(150, 0, 0)
end)

-- Minimize Logic
local MinBtn = Instance.new("TextButton")
MinBtn.Text = "-"
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(0.70, 0, 0, 0)
MinBtn.BackgroundTransparency = 1
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Parent = MainFrame
MinBtn.MouseButton1Click:Connect(function() MainFrame.Visible = false end)

-- Close
local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(0.85, 0, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.Parent = MainFrame
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
