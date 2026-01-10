-- [[ JOSEPEDOV10: TORQUE LORD ]] --
-- Features: Wheel Spin Hack (Bypasses A-Chassis Limits), Traffic Jammer, UI
-- Optimized for Delta

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- === CONFIGURATION ===
local Config = {
    SpeedEnabled = false,
    TrafficBlocked = false,
    SpinSpeed = 200,    -- Rotation Speed (Higher = Faster)
    TorquePower = 10000 -- Force Strength
}

-- === TRAFFIC JAMMER (HOOK) ===
local function InstallTrafficHook()
    local event = ReplicatedStorage:FindFirstChild("CreateNPCVehicle")
    if event then
        for _, connection in pairs(getconnections(event.OnClientEvent)) do
            local oldFunction = connection.Function
            if oldFunction then
                hookfunction(connection.Function, function(...)
                    if Config.TrafficBlocked then return end -- BLOCK
                    return oldFunction(...) -- ALLOW
                end)
            end
        end
    end
end
InstallTrafficHook()

-- === UI CREATION ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JOSEPEDOV10_UI"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 180) 
MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 10, 30) -- Deep Purple Theme
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
OpenBtn.BackgroundColor3 = Color3.fromRGB(170, 0, 255)
OpenBtn.Text = "J10"
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.Font = Enum.Font.GothamBlack
OpenBtn.TextSize = 18
OpenBtn.Visible = false 
OpenBtn.Parent = ScreenGui
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 12)

-- Title
local Title = Instance.new("TextLabel")
Title.Text = "JOSEPEDOV10"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(170, 0, 255)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 18
Title.Parent = MainFrame

-- [TOGGLE] SPEED HACK (Wheel Spin)
local SpeedBtn = Instance.new("TextButton")
SpeedBtn.Size = UDim2.new(0.9, 0, 0, 40)
SpeedBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
SpeedBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
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
        
        -- Try to Force Attributes immediately (One time boost)
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") and char.Humanoid.SeatPart then
            local car = char.Humanoid.SeatPart.Parent
            local carVal = car:FindFirstChild("Car") and car.Car.Value or car
            if carVal then
                carVal:SetAttribute("MaxBoost", 5000)
                carVal:SetAttribute("Torque", 5000)
                carVal:SetAttribute("MaxSpeed", 500)
            end
        end
        
    else
        SpeedBtn.Text = "Speed Hack: OFF"
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        -- Cleanup Spinners
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") and char.Humanoid.SeatPart then
            local car = char.Humanoid.SeatPart.Parent
            for _, part in pairs(car:GetDescendants()) do
                if part.Name == "J10_Spinner" then part:Destroy() end
            end
        end
    end
end)

-- [TOGGLE] TRAFFIC JAMMER
local TrafficBtn = Instance.new("TextButton")
TrafficBtn.Size = UDim2.new(0.9, 0, 0, 40)
TrafficBtn.Position = UDim2.new(0.05, 0, 0.55, 0)
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

-- === WHEEL SPIN LOGIC ===
RunService.Heartbeat:Connect(function()
    if not Config.SpeedEnabled then return end
    
    local char = player.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid or not humanoid.SeatPart then return end
    
    local seat = humanoid.SeatPart
    local car = seat.Parent
    
    -- Find Wheels (A-Chassis usually names them FL, FR, RL, RR)
    -- Or puts them in a "Wheels" folder
    local wheelsFolder = car:FindFirstChild("Wheels")
    local wheels = {}
    
    if wheelsFolder then
        wheels = wheelsFolder:GetChildren()
    else
        -- Fallback: Search for any part named like a wheel
        for _, part in pairs(car:GetChildren()) do
            if part.Name:match("Wheel") or part.Name == "FL" or part.Name == "FR" or part.Name == "RL" or part.Name == "RR" then
                table.insert(wheels, part)
            end
        end
    end
    
    if seat.Throttle > 0 then
        -- SPIN THE WHEELS
        for _, wheel in pairs(wheels) do
            if wheel:IsA("BasePart") then
                local spinner = wheel:FindFirstChild("J10_Spinner")
                
                if not spinner then
                    spinner = Instance.new("AngularVelocity")
                    spinner.Name = "J10_Spinner"
                    spinner.Attachment0 = wheel:FindFirstChild("Attachment") or Instance.new("Attachment", wheel)
                    spinner.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
                    spinner.MaxTorque = Config.TorquePower
                    spinner.Parent = wheel
                end
                
                -- Force Rotation on the X-Axis (usually forward for wheels)
                -- We spin it negatively or positively depending on car orientation
                -- Try changing 1 to -1 if car goes backwards
                spinner.AngularVelocity = Vector3.new(Config.SpinSpeed, 0, 0) 
            end
        end
    else
        -- Remove Spinners when not gas
        for _, wheel in pairs(wheels) do
            if wheel:FindFirstChild("J10_Spinner") then
                wheel.J10_Spinner:Destroy()
            end
        end
    end
end)
