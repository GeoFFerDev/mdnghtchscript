-- [[ JOSEPEDOV21: MANUAL OVERRIDE ]] --
-- Features: Manual Car ID Input, Debug Console Prints, Traffic Jammer
-- Optimized for Delta | Solves "ID Not Found" by letting you type it

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- === CONFIGURATION ===
local Config = {
    TrafficBlocked = false,
    HackedBoost = 10000, -- Extreme Boost
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

-- === UI CREATION ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JOSEPEDOV21_UI"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 230) -- Taller for Input Box
MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(5, 5, 5) -- Pure Black
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(255, 0, 255) -- Neon Purple
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Text = "JOSEPEDOV21"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 0, 255)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 18
Title.Parent = MainFrame

-- [BUTTON] 1. KILL TRAFFIC
local TrafficBtn = Instance.new("TextButton")
TrafficBtn.Size = UDim2.new(0.9, 0, 0, 40)
TrafficBtn.Position = UDim2.new(0.05, 0, 0.15, 0)
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
IDLabel.Text = "Car ID (Check Logs):"
IDLabel.Size = UDim2.new(0.9, 0, 0, 20)
IDLabel.Position = UDim2.new(0.05, 0, 0.40, 0)
IDLabel.BackgroundTransparency = 1
IDLabel.TextColor3 = Color3.fromRGB(200, 200, 200)
IDLabel.Font = Enum.Font.GothamBold
IDLabel.TextSize = 12
IDLabel.Parent = MainFrame

local IDBox = Instance.new("TextBox")
IDBox.Size = UDim2.new(0.9, 0, 0, 30)
IDBox.Position = UDim2.new(0.05, 0, 0.50, 0)
IDBox.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
IDBox.TextColor3 = Color3.fromRGB(255, 255, 0) -- Yellow Text
IDBox.Text = "143" -- Default from your logs
IDBox.Font = Enum.Font.GothamBold
IDBox.TextSize = 14
IDBox.Parent = MainFrame
Instance.new("UICorner", IDBox).CornerRadius = UDim.new(0, 6)

-- [BUTTON] 2. INJECT GOD TURBO
local InjectBtn = Instance.new("TextButton")
InjectBtn.Size = UDim2.new(0.9, 0, 0, 40)
InjectBtn.Position = UDim2.new(0.05, 0, 0.70, 0)
InjectBtn.BackgroundColor3 = Color3.fromRGB(0, 100, 0)
InjectBtn.Text = "💉 Inject God Turbo"
InjectBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
InjectBtn.Font = Enum.Font.GothamBold
InjectBtn.TextSize = 14
InjectBtn.Parent = MainFrame
Instance.new("UICorner", InjectBtn).CornerRadius = UDim.new(0, 6)

InjectBtn.MouseButton1Click:Connect(function()
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") and char.Humanoid.SeatPart then
        local car = char.Humanoid.SeatPart.Parent
        
        -- 1. Find Remote
        local remote = ReplicatedStorage:FindFirstChild("Modules") 
            and ReplicatedStorage.Modules:FindFirstChild("Modules") 
            and ReplicatedStorage.Modules.Modules:FindFirstChild("Network") 
            and ReplicatedStorage.Modules.Modules.Network:FindFirstChild("RemoteEvent")
            
        -- 2. Determine ID (Auto or Manual)
        local carVal = car:FindFirstChild("Car") and car.Car.Value or car
        local detectedID = carVal:GetAttribute("VehicleId") or carVal:GetAttribute("ID") or carVal:GetAttribute("CarID")
        
        -- DEBUG: Print all attributes to console (F9)
        print("=== DEBUG JOSEPEDOV21 ===")
        print("Attributes found on Car Value:")
        for name, value in pairs(carVal:GetAttributes()) do
            print(name, ":", value)
        end
        print("=========================")
        
        -- Use Detected ID if found, otherwise use TextBox
        local finalID = detectedID
        if not finalID then
            finalID = tonumber(IDBox.Text)
            print("Auto-detect failed. Using Manual ID:", finalID)
        else
            IDBox.Text = tostring(finalID) -- Update box with found ID
            print("Auto-detected ID:", finalID)
        end
        
        if remote and finalID then
            local hackedStats = {
                ["Turbochargers"] = Config.HackedCount,
                ["T_Boost"] = Config.HackedBoost,
                ["Superchargers"] = 0,
                ["S_Boost"] = 0
            }
            
            -- FIRE THE EVENT
            remote:FireServer("SetAspiration", finalID, "Turbo", hackedStats)
            
            InjectBtn.Text = "✅ SENT! ID: " .. tostring(finalID)
            InjectBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        else
            if not remote then InjectBtn.Text = "❌ Remote Missing" end
            if not finalID then InjectBtn.Text = "❌ Invalid ID Type" end
            InjectBtn.BackgroundColor3 = Color3.fromRGB(200, 0, 0)
        end
    else
        InjectBtn.Text = "⚠️ Sit in Driver Seat"
    end
    
    task.wait(2)
    InjectBtn.Text = "💉 Inject God Turbo"
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
