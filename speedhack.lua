-- [[ JOSEPEDOV28: DIRECT CAR INJECTOR ]] --
-- Features: Direct Model Injection, Full Table Merge, Traffic Jammer
-- Optimized for Delta | Target: "Lf20Besaya's Car" Root

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- === CONFIGURATION ===
local Config = {
    TrafficBlocked = false,
    -- God Mode Stats
    Horsepower = 60000,
    Torque = 25000,
    Redline = 13000,
    MaxSpeed = 999,
    Turbochargers = 4,
    T_Boost = 5000,
    FinalDrive = 0.3
}

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
ScreenGui.Name = "JOSEPEDOV28_UI"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 220)
MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 25, 15) -- Forest Green
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(50, 255, 50) -- Neon Green
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Text = "JOSEPEDOV28"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(50, 255, 50)
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

-- [BUTTON] 2. INJECT DIRECT TUNE
local InjectBtn = Instance.new("TextButton")
InjectBtn.Size = UDim2.new(0.9, 0, 0, 50)
InjectBtn.Position = UDim2.new(0.05, 0, 0.45, 0)
InjectBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
InjectBtn.Text = "💉 INJECT DIRECT TUNE\n(Target: Car Model)"
InjectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
InjectBtn.Font = Enum.Font.GothamBold
InjectBtn.TextSize = 14
InjectBtn.Parent = MainFrame
Instance.new("UICorner", InjectBtn).CornerRadius = UDim.new(0, 6)

InjectBtn.MouseButton1Click:Connect(function()
    print("=== JOSEPEDOV28 DEBUG ===")
    
    local char = player.Character
    if not char then warn("No Character"); return end
    
    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid and humanoid.SeatPart then
        local driveSeat = humanoid.SeatPart
        local car = driveSeat.Parent -- THIS IS "Lf20Besaya's Car"
        
        print("Target Car:", car.Name)
        
        -- 1. FIND COMPONENTS DIRECTLY IN CAR MODEL
        -- Based on your correction: "It's all under Lf20besaya's Car"
        local tuneModule = car:FindFirstChild("A-Chassis Tune")
        local tuneEvent = car:FindFirstChild("TuneUpdatedEvent")
        
        if tuneModule and tuneEvent then
            print("✅ Found Module & Event in Car Root!")
            
            -- 2. REQUIRE & CLONE
            local success, original = pcall(require, tuneModule)
            if success then
                print("✅ Module Loaded. Merging Stats...")
                
                local finalTune = {}
                for k, v in pairs(original) do
                    finalTune[k] = v
                end
                
                -- 3. OVERWRITE GOD STATS
                finalTune.Horsepower = Config.Horsepower
                finalTune.Torque = Config.Torque
                finalTune.MaxTorque = Config.Torque
                finalTune.PeakRPM = Config.Redline
                finalTune.Redline = Config.Redline
                finalTune.FinalDrive = Config.FinalDrive
                finalTune.Turbochargers = Config.Turbochargers
                finalTune.T_Boost = Config.T_Boost
                finalTune.MaxSpeed = Config.MaxSpeed
                
                -- 4. FIRE!
                tuneEvent:Fire(finalTune)
                print("🔥 FIRED GOD MODE!")
                
                InjectBtn.Text = "✅ SUCCESS!"
                InjectBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                
                -- 5. VISUAL UPDATE
                local values = car:FindFirstChild("Values")
                if values then
                    if values:FindFirstChild("Horsepower") then values.Horsepower.Value = Config.Horsepower end
                    if values:FindFirstChild("Torque") then values.Torque.Value = Config.Torque end
                    if values:FindFirstChild("BoostTurbo") then values.BoostTurbo.Value = Config.T_Boost end
                end
            else
                warn("Failed to Require Module.")
                InjectBtn.Text = "❌ Require Failed"
            end
        else
            warn("Components Missing in Car Model:")
            if not tuneModule then print("- A-Chassis Tune NOT FOUND") end
            if not tuneEvent then print("- TuneUpdatedEvent NOT FOUND") end
            InjectBtn.Text = "❌ Missing Parts"
        end
    else
        InjectBtn.Text = "⚠️ Sit in Driver Seat"
    end
    
    task.wait(2)
    InjectBtn.Text = "💉 INJECT DIRECT TUNE\n(Target: Car Model)"
    InjectBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
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
