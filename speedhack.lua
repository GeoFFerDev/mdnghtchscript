-- [[ JOSEPEDOV22: HYBRID GOD MODE ]] --
-- Features: Server Turbo Injection + Client Gear Tuning + Traffic Jammer
-- Optimized for Delta | Fixes "Missing Remote" & "Top Speed Cap"

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- === CONFIGURATION ===
local Config = {
    TrafficBlocked = false,
    HackedBoost = 10000, -- Server Turbo
    HackedCount = 4
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

-- === HELPER: FIND REMOTE RECURSIVELY ===
-- This fixes the "Missing Remote" error by searching deeper folders
local function FindRemote(name, root)
    for _, child in pairs(root:GetDescendants()) do
        if child.Name == name and child:IsA("RemoteEvent") then
            return child
        end
    end
    return nil
end

-- === UI CREATION ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JOSEPEDOV22_UI"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 320) -- Taller for more options
MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 15)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(0, 255, 255) -- Cyan
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Text = "JOSEPEDOV22"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(0, 255, 255)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 18
Title.Parent = MainFrame

-- [BUTTON] 1. KILL TRAFFIC
local TrafficBtn = Instance.new("TextButton")
TrafficBtn.Size = UDim2.new(0.9, 0, 0, 35)
TrafficBtn.Position = UDim2.new(0.05, 0, 0.12, 0)
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

-- [INPUT] CAR ID BOX
local IDLabel = Instance.new("TextLabel")
IDLabel.Text = "Car ID (143):"
IDLabel.Size = UDim2.new(0.4, 0, 0, 20)
IDLabel.Position = UDim2.new(0.05, 0, 0.28, 0)
IDLabel.BackgroundTransparency = 1
IDLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
IDLabel.Font = Enum.Font.GothamBold
IDLabel.TextSize = 12
IDLabel.TextXAlignment = Enum.TextXAlignment.Left
IDLabel.Parent = MainFrame

local IDBox = Instance.new("TextBox")
IDBox.Size = UDim2.new(0.4, 0, 0, 30)
IDBox.Position = UDim2.new(0.05, 0, 0.35, 0)
IDBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
IDBox.TextColor3 = Color3.fromRGB(255, 255, 0)
IDBox.Text = "143"
IDBox.Font = Enum.Font.GothamBold
IDBox.TextSize = 14
IDBox.Parent = MainFrame
Instance.new("UICorner", IDBox).CornerRadius = UDim.new(0, 6)

-- [INPUT] TOP SPEED BOX
local SpeedLabel = Instance.new("TextLabel")
SpeedLabel.Text = "Max Speed:"
SpeedLabel.Size = UDim2.new(0.4, 0, 0, 20)
SpeedLabel.Position = UDim2.new(0.55, 0, 0.28, 0)
SpeedLabel.BackgroundTransparency = 1
SpeedLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
SpeedLabel.Font = Enum.Font.GothamBold
SpeedLabel.TextSize = 12
SpeedLabel.TextXAlignment = Enum.TextXAlignment.Left
SpeedLabel.Parent = MainFrame

local SpeedBox = Instance.new("TextBox")
SpeedBox.Size = UDim2.new(0.4, 0, 0, 30)
SpeedBox.Position = UDim2.new(0.55, 0, 0.35, 0)
SpeedBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
SpeedBox.TextColor3 = Color3.fromRGB(0, 255, 255)
SpeedBox.Text = "600"
SpeedBox.Font = Enum.Font.GothamBold
SpeedBox.TextSize = 14
SpeedBox.Parent = MainFrame
Instance.new("UICorner", SpeedBox).CornerRadius = UDim.new(0, 6)

-- [BUTTON] 2. INJECT EVERYTHING (Hybrid)
local InjectBtn = Instance.new("TextButton")
InjectBtn.Size = UDim2.new(0.9, 0, 0, 50)
InjectBtn.Position = UDim2.new(0.05, 0, 0.52, 0)
InjectBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
InjectBtn.Text = "💉 INJECT GOD MODE\n(Server Boost + Client Speed)"
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
        
        -- === STEP 1: SERVER INJECTION (ACCELERATION) ===
        -- Use recursive search to fix "Remote Missing"
        local remote = FindRemote("RemoteEvent", ReplicatedStorage)
        local carID = tonumber(IDBox.Text)
        
        if remote and carID then
            local hackedStats = {
                ["Turbochargers"] = Config.HackedCount,
                ["T_Boost"] = Config.HackedBoost, -- 10,000 PSI
                ["Superchargers"] = 0,
                ["S_Boost"] = 0
            }
            remote:FireServer("SetAspiration", carID, "Turbo", hackedStats)
            print("Server Injection Sent to ID:", carID)
        else
            if not remote then warn("Still couldn't find RemoteEvent!") end
        end
        
        -- === STEP 2: CLIENT INJECTION (TOP SPEED) ===
        -- This unlocks the Gears/Redline so you can actually USE the speed
        local tuneModule = carVal:FindFirstChild("A-Chassis Tune")
        local tuneEvent = carVal:FindFirstChild("TuneUpdatedEvent")
        local targetSpeed = tonumber(SpeedBox.Text) or 600
        
        if tuneModule and tuneEvent then
            local success, tune = pcall(require, tuneModule)
            if success and tune then
                -- Modify local logic to accept high speed
                tune.Horsepower = tune.Horsepower + 5000 -- Add local power too
                tune.MaxSpeed = targetSpeed
                tune.PeakRPM = 12000
                tune.Redline = 13000
                tune.FinalDrive = 0.5 -- Lower Ratio = Higher Top Speed
                
                -- Force the car to update
                tuneEvent:Fire(tune)
                print("Client Tune Updated! Target Speed:", targetSpeed)
            end
        end
        
        InjectBtn.Text = "✅ GOD MODE ACTIVE!"
        InjectBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        
    else
        InjectBtn.Text = "⚠️ Sit in Driver Seat"
    end
    
    task.wait(2)
    InjectBtn.Text = "💉 INJECT GOD MODE\n(Server Boost + Client Speed)"
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
