-- [[ JOSEPEDOV26: SPLIT-LINK INJECTOR ]] --
-- Features: Character-to-Car Injection, Full Table Merge, Traffic Jammer
-- Optimized for Delta | Fixes "Missing Data" by finding the Module in Character

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- === CONFIGURATION ===
local Config = {
    TrafficBlocked = false,
    -- God Mode Stats
    Horsepower = 60000,    -- 60k HP
    Torque = 25000,        -- 25k Torque
    Redline = 12000,       -- High RPM
    MaxSpeed = 999,        -- Infinite Speed
    Turbochargers = 4,     -- Quad Turbo
    T_Boost = 5000,        -- 5k Boost
    FinalDrive = 0.3       -- Low Ratio = 600+ MPH
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
ScreenGui.Name = "JOSEPEDOV26_UI"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 220)
MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(255, 0, 255) -- Neon Purple
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Text = "JOSEPEDOV26"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 0, 255)
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

-- [BUTTON] 2. INJECT SPLIT TUNE
local InjectBtn = Instance.new("TextButton")
InjectBtn.Size = UDim2.new(0.9, 0, 0, 50)
InjectBtn.Position = UDim2.new(0.05, 0, 0.45, 0)
InjectBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 150)
InjectBtn.Text = "💉 INJECT SPLIT TUNE\n(Character -> Car)"
InjectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
InjectBtn.Font = Enum.Font.GothamBold
InjectBtn.TextSize = 14
InjectBtn.Parent = MainFrame
Instance.new("UICorner", InjectBtn).CornerRadius = UDim.new(0, 6)

InjectBtn.MouseButton1Click:Connect(function()
    print("=== JOSEPEDOV26 DEBUG ===")
    
    local char = player.Character
    if not char then 
        warn("Character not found!")
        return 
    end
    
    -- 1. FIND MODULE (Inside Character)
    local tuneModule = char:FindFirstChild("A-Chassis Tune")
    if tuneModule then
        print("✅ FOUND TUNE MODULE IN CHARACTER!")
    else
        warn("❌ Module NOT in Character. Searching Descendants...")
        -- Fallback: Search deeper just in case
        for _, v in pairs(char:GetDescendants()) do
            if v.Name == "A-Chassis Tune" and v:IsA("ModuleScript") then
                tuneModule = v
                print("✅ Found Module deep in Character:", v:GetFullName())
                break
            end
        end
    end

    -- 2. FIND EVENT (Inside Car)
    local humanoid = char:FindFirstChild("Humanoid")
    if humanoid and humanoid.SeatPart then
        local car = humanoid.SeatPart.Parent
        print("Car Found:", car.Name)
        
        local tuneEvent = car:FindFirstChild("TuneUpdatedEvent")
        if not tuneEvent then
             -- Try searching deep in car
             for _, v in pairs(car:GetDescendants()) do
                 if v.Name == "TuneUpdatedEvent" then
                     tuneEvent = v
                     print("✅ Found Event deep in Car:", v:GetFullName())
                     break
                 end
             end
        else
            print("✅ FOUND EVENT IN CAR ROOT!")
        end
        
        -- 3. THE MERGE & FIRE
        if tuneModule and tuneEvent then
            local success, originalTune = pcall(require, tuneModule)
            if success then
                print("Module Loaded. Cloning Table...")
                
                -- CLONE TABLE (Important!)
                local newTune = {}
                for k, v in pairs(originalTune) do
                    newTune[k] = v
                end
                
                -- INJECT GOD STATS
                newTune.Horsepower = Config.Horsepower
                newTune.Torque = Config.Torque
                newTune.MaxTorque = Config.Torque
                newTune.PeakRPM = Config.Redline
                newTune.Redline = Config.Redline + 1000
                newTune.FinalDrive = Config.FinalDrive
                newTune.Turbochargers = Config.Turbochargers
                newTune.T_Boost = Config.T_Boost
                newTune.MaxSpeed = Config.MaxSpeed
                
                -- FIRE!
                tuneEvent:Fire(newTune)
                print("🔥 FIRED GOD TUNE INTO CAR!")
                
                InjectBtn.Text = "✅ TUNE INJECTED!"
                InjectBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
                
                -- 4. UPDATE "VALUES" FOLDER (Visuals)
                -- You mentioned a "Values" folder in the car. Let's update that too.
                local carVal = car:FindFirstChild("Car") and car.Car.Value or car
                local valFolder = carVal:FindFirstChild("Values") or car:FindFirstChild("Values")
                
                if valFolder then
                    print("Updating Values Folder...")
                    if valFolder:FindFirstChild("Horsepower") then valFolder.Horsepower.Value = Config.Horsepower end
                    if valFolder:FindFirstChild("Torque") then valFolder.Torque.Value = Config.Torque end
                    if valFolder:FindFirstChild("BoostTurbo") then valFolder.BoostTurbo.Value = Config.T_Boost end
                end
                
            else
                warn("Failed to Require Module.")
                InjectBtn.Text = "❌ Module Error"
            end
        else
            if not tuneModule then warn("Missing Module in Character") end
            if not tuneEvent then warn("Missing Event in Car") end
            InjectBtn.Text = "❌ Components Missing"
        end
    else
        InjectBtn.Text = "⚠️ Sit in Driver Seat"
    end
    
    task.wait(2)
    InjectBtn.Text = "💉 INJECT SPLIT TUNE\n(Character -> Car)"
    InjectBtn.BackgroundColor3 = Color3.fromRGB(100, 0, 150)
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
