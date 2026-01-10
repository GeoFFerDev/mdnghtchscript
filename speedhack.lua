-- [[ JOSEPEDOV12: ACTUAL WORKING METHOD ]] --
-- Method: Spoof throttle input + Modify client-side tune before replication
-- The server trusts initial tune values, so we modify them before the car loads

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- === CONFIGURATION ===
local Config = {
    SpeedEnabled = false,
    TrafficBlocked = false,
    PowerMultiplier = 3.0,
    ThrottleBoost = 1.5
}

-- === UI CREATION ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JOSEPEDOV12_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 260, 0, 300)
MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0)
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- Title
local Title = Instance.new("TextLabel")
Title.Text = "JOSEPEDOV12 | SWFL ELITE"
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 0, 0)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 15
Title.Parent = MainFrame

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Text = "Status: Idle"
StatusLabel.Size = UDim2.new(0.92, 0, 0, 25)
StatusLabel.Position = UDim2.new(0.04, 0, 0.13, 0)
StatusLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 11
StatusLabel.Parent = MainFrame
Instance.new("UICorner", StatusLabel).CornerRadius = UDim.new(0, 4)

-- Speed Display
local SpeedDisplay = Instance.new("TextLabel")
SpeedDisplay.Text = "Speed: 0 MPH"
SpeedDisplay.Size = UDim2.new(0.92, 0, 0, 25)
SpeedDisplay.Position = UDim2.new(0.04, 0, 0.23, 0)
SpeedDisplay.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SpeedDisplay.TextColor3 = Color3.fromRGB(0, 255, 0)
SpeedDisplay.Font = Enum.Font.GothamBold
SpeedDisplay.TextSize = 13
SpeedDisplay.Parent = MainFrame
Instance.new("UICorner", SpeedDisplay).CornerRadius = UDim.new(0, 4)

-- [BUTTON] 1. KILL TRAFFIC
local TrafficBtn = Instance.new("TextButton")
TrafficBtn.Size = UDim2.new(0.92, 0, 0, 38)
TrafficBtn.Position = UDim2.new(0.04, 0, 0.35, 0)
TrafficBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TrafficBtn.Text = "🚫 Kill Traffic"
TrafficBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
TrafficBtn.Font = Enum.Font.GothamBold
TrafficBtn.TextSize = 13
TrafficBtn.Parent = MainFrame
Instance.new("UICorner", TrafficBtn).CornerRadius = UDim.new(0, 6)

TrafficBtn.MouseButton1Click:Connect(function()
    Config.TrafficBlocked = not Config.TrafficBlocked
    if Config.TrafficBlocked then
        TrafficBtn.Text = "Traffic: DEAD 💀"
        TrafficBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        StatusLabel.Text = "Status: Traffic Disabled"
        
        local event = ReplicatedStorage:FindFirstChild("CreateNPCVehicle")
        if event then
            for _, connection in pairs(getconnections(event.OnClientEvent)) do
                connection:Disable()
            end
        end
        
        local npcFolder = Workspace:FindFirstChild("NPCVehicles")
        if npcFolder then 
            local vehicles = npcFolder:FindFirstChild("Vehicles")
            if vehicles then vehicles:ClearAllChildren() end
        end
    else
        TrafficBtn.Text = "🚫 Kill Traffic"
        TrafficBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        StatusLabel.Text = "Status: Traffic Enabled"
        
        local event = ReplicatedStorage:FindFirstChild("CreateNPCVehicle")
        if event then
            for _, connection in pairs(getconnections(event.OnClientEvent)) do
                connection:Enable()
            end
        end
    end
end)

-- [BUTTON] 2. SPEED HACK
local SpeedBtn = Instance.new("TextButton")
SpeedBtn.Size = UDim2.new(0.92, 0, 0, 38)
SpeedBtn.Position = UDim2.new(0.04, 0, 0.50, 0)
SpeedBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SpeedBtn.Text = "⚡ Speed Hack: OFF"
SpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBtn.Font = Enum.Font.GothamBold
SpeedBtn.TextSize = 13
SpeedBtn.Parent = MainFrame
Instance.new("UICorner", SpeedBtn).CornerRadius = UDim.new(0, 6)

-- === CORE SYSTEM ===
local modifiedCars = {}
local originalNamecall

-- Function to modify car tune module
local function modifyCarTune(car)
    if modifiedCars[car] then return end
    
    local tuneModule = car:FindFirstChild("A-Chassis Tune")
    if not tuneModule then return end
    
    -- Get the actual module (it's a ModuleScript)
    local success, tune = pcall(function()
        return require(tuneModule)
    end)
    
    if not success or not tune then return end
    
    -- Store original values
    if not tune._ORIGINAL then
        tune._ORIGINAL = {
            Horsepower = tune.Horsepower,
            Redline = tune.Redline,
            PeakRPM = tune.PeakRPM,
            PeakSharpness = tune.PeakSharpness,
            EqPoint = tune.EqPoint,
            Ratios = {table.unpack(tune.Ratios)},
            FinalDrive = tune.FinalDrive,
            FDMult = tune.FDMult,
            E_Torque = tune.E_Torque or 50,
            E_Horsepower = tune.E_Horsepower or 0
        }
    end
    
    if Config.SpeedEnabled then
        -- BOOST ENGINE POWER
        tune.Horsepower = tune._ORIGINAL.Horsepower * Config.PowerMultiplier
        tune.E_Horsepower = tune._ORIGINAL.E_Horsepower * Config.PowerMultiplier
        tune.E_Torque = tune._ORIGINAL.E_Torque * Config.PowerMultiplier
        
        -- Extend redline for more top speed
        tune.Redline = tune._ORIGINAL.Redline * 1.2
        tune.PeakRPM = tune._ORIGINAL.PeakRPM * 1.2
        
        -- Optimize gear ratios for acceleration
        for i = 1, #tune.Ratios do
            if i > 1 then -- Don't touch reverse gear
                tune.Ratios[i] = tune._ORIGINAL.Ratios[i] * 0.85
            end
        end
        
        -- Better final drive
        tune.FinalDrive = tune._ORIGINAL.FinalDrive * 0.9
        
        StatusLabel.Text = "Status: Tune Modified"
    else
        -- RESTORE ORIGINAL
        tune.Horsepower = tune._ORIGINAL.Horsepower
        tune.E_Horsepower = tune._ORIGINAL.E_Horsepower
        tune.E_Torque = tune._ORIGINAL.E_Torque
        tune.Redline = tune._ORIGINAL.Redline
        tune.PeakRPM = tune._ORIGINAL.PeakRPM
        tune.Ratios = {table.unpack(tune._ORIGINAL.Ratios)}
        tune.FinalDrive = tune._ORIGINAL.FinalDrive
        
        StatusLabel.Text = "Status: Tune Restored"
    end
    
    -- Fire the update event to apply changes
    local updateEvent = car:FindFirstChild("UpdateTune")
    if updateEvent then
        updateEvent:FireServer(tune)
    end
    
    modifiedCars[car] = true
end

-- Hook namecall to intercept input replication
originalNamecall = hookmetamethod(game, "__namecall", newcclosure(function(self, ...)
    local method = getnamecallmethod()
    local args = {...}
    
    if not checkcaller() and Config.SpeedEnabled then
        if method == "FireServer" and self.Name == "Replication" then
            -- Args are: Steer, Throttle, Brake, PBrake, Gear, etc.
            -- Boost throttle input
            if args[2] and typeof(args[2]) == "number" then
                args[2] = math.min(args[2] * Config.ThrottleBoost, 1) -- Throttle
            end
            return originalNamecall(self, unpack(args))
        end
    end
    
    return originalNamecall(self, ...)
end))

-- Get current car
local function getCurrentCar()
    local char = player.Character
    if not char then return nil end
    
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid or not humanoid.SeatPart then return nil end
    
    return humanoid.SeatPart.Parent
end

-- Button toggle
SpeedBtn.MouseButton1Click:Connect(function()
    Config.SpeedEnabled = not Config.SpeedEnabled
    
    if Config.SpeedEnabled then
        SpeedBtn.Text = "⚡ Speed Hack: ACTIVE"
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        SpeedBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
        StatusLabel.Text = "Status: Applying Boost..."
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        
        -- Apply to current car
        local car = getCurrentCar()
        if car then
            modifyCarTune(car)
        else
            StatusLabel.Text = "Status: Get in a car!"
        end
    else
        SpeedBtn.Text = "⚡ Speed Hack: OFF"
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        SpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        StatusLabel.Text = "Status: Restoring Normal..."
        StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        
        -- Restore current car
        local car = getCurrentCar()
        if car then
            modifiedCars[car] = nil
            modifyCarTune(car)
        end
    end
end)

-- Monitor for new vehicles
player.CharacterAdded:Connect(function(char)
    local humanoid = char:WaitForChild("Humanoid")
    humanoid.Seated:Connect(function(active)
        if active then
            task.wait(1) -- Wait for car to fully load
            local car = getCurrentCar()
            if car and Config.SpeedEnabled then
                modifyCarTune(car)
            end
        end
    end)
end)

-- Auto-apply on existing car
task.spawn(function()
    local char = player.Character
    if char then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid then
            humanoid.Seated:Connect(function(active)
                if active then
                    task.wait(1)
                    local car = getCurrentCar()
                    if car and Config.SpeedEnabled then
                        modifyCarTune(car)
                    end
                end
            end)
            
            -- Check if already seated
            if humanoid.SeatPart then
                task.wait(1)
                local car = getCurrentCar()
                if car and Config.SpeedEnabled then
                    modifyCarTune(car)
                end
            end
        end
    end
end)

-- [SLIDER] Power Multiplier
local SliderFrame = Instance.new("Frame")
SliderFrame.Size = UDim2.new(0.92, 0, 0, 60)
SliderFrame.Position = UDim2.new(0.04, 0, 0.67, 0)
SliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SliderFrame.Parent = MainFrame
Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 6)

local SliderLabel = Instance.new("TextLabel")
SliderLabel.Text = "Power: 3.0x"
SliderLabel.Size = UDim2.new(1, 0, 0, 24)
SliderLabel.BackgroundTransparency = 1
SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SliderLabel.Font = Enum.Font.GothamBold
SliderLabel.TextSize = 13
SliderLabel.Parent = SliderFrame

local SliderButton = Instance.new("TextButton")
SliderButton.Size = UDim2.new(0.88, 0, 0, 24)
SliderButton.Position = UDim2.new(0.06, 0, 0.55, 0)
SliderButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SliderButton.Text = ""
SliderButton.Parent = SliderFrame
Instance.new("UICorner", SliderButton).CornerRadius = UDim.new(0, 4)

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(0.4, 0, 1, 0) -- 3/7 ≈ 0.4 (default 3x)
SliderFill.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
SliderFill.BorderSizePixel = 0
SliderFill.Parent = SliderButton
Instance.new("UICorner", SliderFill).CornerRadius = UDim.new(0, 4)

local dragging = false
SliderButton.InputBegan:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = true
    end
end)

SliderButton.InputEnded:Connect(function(input)
    if input.UserInputType == Enum.UserInputType.MouseButton1 then
        dragging = false
    end
end)

game:GetService("UserInputService").InputChanged:Connect(function(input)
    if dragging and input.UserInputType == Enum.UserInputType.MouseMovement then
        local pos = (input.Position.X - SliderButton.AbsolutePosition.X) / SliderButton.AbsoluteSize.X
        pos = math.clamp(pos, 0, 1)
        
        SliderFill.Size = UDim2.new(pos, 0, 1, 0)
        
        -- Map 0-1 to 1x-8x
        Config.PowerMultiplier = 1 + (pos * 7)
        SliderLabel.Text = string.format("Power: %.1fx", Config.PowerMultiplier)
        
        -- Re-apply if active
        if Config.SpeedEnabled then
            local car = getCurrentCar()
            if car then
                modifiedCars[car] = nil
                modifyCarTune(car)
            end
        end
    end
end)

-- CLOSE BUTTON
local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(0.88, 0, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.Parent = MainFrame
CloseBtn.MouseButton1Click:Connect(function() 
    -- Restore all modified cars
    for car, _ in pairs(modifiedCars) do
        if car.Parent then
            Config.SpeedEnabled = false
            modifyCarTune(car)
        end
    end
    
    if originalNamecall then 
        hookmetamethod(game, "__namecall", originalNamecall) 
    end
    ScreenGui:Destroy()
end)

-- Speed monitor (always active)
task.spawn(function()
    while task.wait(0.1) do
        local car = getCurrentCar()
        if car then
            local driveSeat = car:FindFirstChild("DriveSeat")
            if driveSeat then
                local vel = driveSeat.AssemblyLinearVelocity
                local mph = vel.Magnitude * 0.681818
                SpeedDisplay.Text = string.format("Speed: %.0f MPH", mph)
                
                if mph > 200 then
                    SpeedDisplay.TextColor3 = Color3.fromRGB(255, 0, 0)
                elseif mph > 150 then
                    SpeedDisplay.TextColor3 = Color3.fromRGB(255, 170, 0)
                else
                    SpeedDisplay.TextColor3 = Color3.fromRGB(0, 255, 0)
                end
            end
        else
            SpeedDisplay.Text = "Speed: 0 MPH"
            SpeedDisplay.TextColor3 = Color3.fromRGB(0, 255, 0)
        end
    end
end)

print("✅ JOSEPEDOV12 Elite Loaded")
print("📊 Method: Tune modification + Input boosting")
print("🎯 This modifies the car's engine specs directly
