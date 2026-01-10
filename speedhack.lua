-- [[ JOSEPEDOV12: WORKING VERSION ]] --
-- Method: Direct vehicle force manipulation + Collision bypass
-- Based on A-Chassis client-authoritative physics

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- === CONFIGURATION ===
local Config = {
    SpeedEnabled = false,
    TrafficBlocked = false,
    SpeedMultiplier = 2.5,
    ForceBypass = true -- Bypass collision speed checks
}

-- === UI CREATION ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JOSEPEDOV12_UI"
ScreenGui.ResetOnSpawn = false
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 240, 0, 280)
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
Title.Text = "JOSEPEDOV12 | SWFL"
Title.Size = UDim2.new(1, 0, 0, 35)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 0, 0)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 16
Title.Parent = MainFrame

-- Status Label
local StatusLabel = Instance.new("TextLabel")
StatusLabel.Text = "Status: Idle"
StatusLabel.Size = UDim2.new(0.9, 0, 0, 25)
StatusLabel.Position = UDim2.new(0.05, 0, 0.14, 0)
StatusLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
StatusLabel.Font = Enum.Font.Gotham
StatusLabel.TextSize = 12
StatusLabel.Parent = MainFrame
Instance.new("UICorner", StatusLabel).CornerRadius = UDim.new(0, 4)

-- Speed Display
local SpeedDisplay = Instance.new("TextLabel")
SpeedDisplay.Text = "Speed: 0 MPH"
SpeedDisplay.Size = UDim2.new(0.9, 0, 0, 25)
SpeedDisplay.Position = UDim2.new(0.05, 0, 0.25, 0)
SpeedDisplay.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SpeedDisplay.TextColor3 = Color3.fromRGB(0, 255, 0)
SpeedDisplay.Font = Enum.Font.GothamBold
SpeedDisplay.TextSize = 14
SpeedDisplay.Parent = MainFrame
Instance.new("UICorner", SpeedDisplay).CornerRadius = UDim.new(0, 4)

-- [BUTTON] 1. KILL TRAFFIC
local TrafficBtn = Instance.new("TextButton")
TrafficBtn.Size = UDim2.new(0.9, 0, 0, 40)
TrafficBtn.Position = UDim2.new(0.05, 0, 0.38, 0)
TrafficBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
TrafficBtn.Text = "🚫 Kill Traffic"
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
SpeedBtn.Size = UDim2.new(0.9, 0, 0, 40)
SpeedBtn.Position = UDim2.new(0.05, 0, 0.54, 0)
SpeedBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SpeedBtn.Text = "⚡ Speed Hack: OFF"
SpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBtn.Font = Enum.Font.GothamBold
SpeedBtn.TextSize = 14
SpeedBtn.Parent = MainFrame
Instance.new("UICorner", SpeedBtn).CornerRadius = UDim.new(0, 6)

-- === CORE SPEED SYSTEM ===
local activeConnection = nil
local currentCar = nil

local function getCurrentCar()
    local char = player.Character
    if not char then return nil end
    
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid or not humanoid.SeatPart then return nil end
    
    return humanoid.SeatPart.Parent
end

local function applySpeedHack()
    if activeConnection then
        activeConnection:Disconnect()
        activeConnection = nil
    end
    
    if not Config.SpeedEnabled then return end
    
    -- Method: Direct velocity multiplication on Heartbeat
    activeConnection = RunService.Heartbeat:Connect(function(dt)
        local car = getCurrentCar()
        if not car then return end
        
        -- Find the main driving part (DriveSeat)
        local driveSeat = car:FindFirstChild("DriveSeat")
        if not driveSeat then return end
        
        -- Get current velocity
        local currentVel = driveSeat.AssemblyLinearVelocity
        local currentSpeed = currentVel.Magnitude
        
        -- Update speed display (convert to MPH: studs/s * 0.681818)
        local mph = currentSpeed * 0.681818
        SpeedDisplay.Text = string.format("Speed: %.0f MPH", mph)
        
        -- Only boost if throttle is being applied
        local throttle = driveSeat.ThrottleFloat
        if throttle > 0.1 then
            -- Apply multiplier to current velocity
            local boostedVel = currentVel * Config.SpeedMultiplier
            
            -- Apply the boost (this is client-authoritative in A-Chassis)
            driveSeat.AssemblyLinearVelocity = boostedVel
            
            -- Also boost angular velocity for better handling at high speed
            local angularVel = driveSeat.AssemblyAngularVelocity
            driveSeat.AssemblyAngularVelocity = angularVel * 1.1
        end
    end)
end

-- Hook to bypass collision speed checks
local oldIndex = nil
oldIndex = hookmetamethod(game, "__index", newcclosure(function(self, key)
    if Config.ForceBypass and not checkcaller() then
        -- When collision system checks velocity, lie and say we're slow
        if (key == "AssemblyLinearVelocity" or key == "Velocity") then
            if typeof(self) == "Instance" and self.Name == "HumanoidRootPart" then
                local char = player.Character
                if char and self:IsDescendantOf(char) then
                    local realVel = oldIndex(self, key)
                    -- If going fast, report we're under threshold (95 < 100)
                    if realVel.Magnitude > 95 then
                        return realVel.Unit * 95
                    end
                end
            end
        end
    end
    return oldIndex(self, key)
end))

-- Button toggle
SpeedBtn.MouseButton1Click:Connect(function()
    Config.SpeedEnabled = not Config.SpeedEnabled
    
    if Config.SpeedEnabled then
        SpeedBtn.Text = "⚡ Speed Hack: ACTIVE"
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        SpeedBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
        StatusLabel.Text = "Status: Speed Active"
        StatusLabel.TextColor3 = Color3.fromRGB(0, 255, 0)
        
        applySpeedHack()
    else
        SpeedBtn.Text = "⚡ Speed Hack: OFF"
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        SpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        StatusLabel.Text = "Status: Speed Disabled"
        StatusLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
        
        if activeConnection then
            activeConnection:Disconnect()
            activeConnection = nil
        end
    end
end)

-- Monitor for vehicle changes
player.CharacterAdded:Connect(function(char)
    local humanoid = char:WaitForChild("Humanoid")
    humanoid.Seated:Connect(function(active)
        if active then
            task.wait(0.5)
            currentCar = getCurrentCar()
            if Config.SpeedEnabled then
                applySpeedHack()
            end
        else
            currentCar = nil
        end
    end)
end)

-- [SLIDER] Speed Multiplier
local SliderFrame = Instance.new("Frame")
SliderFrame.Size = UDim2.new(0.9, 0, 0, 55)
SliderFrame.Position = UDim2.new(0.05, 0, 0.72, 0)
SliderFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SliderFrame.Parent = MainFrame
Instance.new("UICorner", SliderFrame).CornerRadius = UDim.new(0, 6)

local SliderLabel = Instance.new("TextLabel")
SliderLabel.Text = "Multiplier: 2.5x"
SliderLabel.Size = UDim2.new(1, 0, 0, 22)
SliderLabel.BackgroundTransparency = 1
SliderLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
SliderLabel.Font = Enum.Font.GothamBold
SliderLabel.TextSize = 13
SliderLabel.Parent = SliderFrame

local SliderButton = Instance.new("TextButton")
SliderButton.Size = UDim2.new(0.85, 0, 0, 22)
SliderButton.Position = UDim2.new(0.075, 0, 0.55, 0)
SliderButton.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
SliderButton.Text = ""
SliderButton.Parent = SliderFrame
Instance.new("UICorner", SliderButton).CornerRadius = UDim.new(0, 4)

local SliderFill = Instance.new("Frame")
SliderFill.Size = UDim2.new(0.375, 0, 1, 0) -- 2.5/8 = 0.375 (default)
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
        Config.SpeedMultiplier = 1 + (pos * 7)
        SliderLabel.Text = string.format("Multiplier: %.1fx", Config.SpeedMultiplier)
    end
end)

-- CLOSE BUTTON
local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(0.87, 0, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = Color3.fromRGB(255, 0, 0)
CloseBtn.Font = Enum.Font.GothamBold
CloseBtn.TextSize = 18
CloseBtn.Parent = MainFrame
CloseBtn.MouseButton1Click:Connect(function() 
    -- Cleanup
    if activeConnection then activeConnection:Disconnect() end
    if oldIndex then hookmetamethod(game, "__index", oldIndex) end
    ScreenGui:Destroy()
end)

-- Speed update loop (even when not boosting, show current speed)
task.spawn(function()
    while task.wait(0.1) do
        if not Config.SpeedEnabled then
            local car = getCurrentCar()
            if car then
                local driveSeat = car:FindFirstChild("DriveSeat")
                if driveSeat then
                    local mph = driveSeat.AssemblyLinearVelocity.Magnitude * 0.681818
                    SpeedDisplay.Text = string.format("Speed: %.0f MPH", mph)
                end
            else
                SpeedDisplay.Text = "Speed: 0 MPH"
            end
        end
    end
end)

print("✅ JOSEPEDOV12 Loaded Successfully")
print("⚡ Speed multiplier works by directly boosting velocity")
print("🚫 Traffic killer disables NPC vehicle spawns")
