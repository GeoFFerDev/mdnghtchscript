-- [[ JOSEPEDOV20: SERVER INJECTION ]] --
-- Features: RemoteEvent Exploitation (Server-Sided Power), Traffic Jammer
-- Optimized for Delta | Based on "Aspiration.txt" Logs

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- === CONFIGURATION ===
local Config = {
    TrafficBlocked = false,
    -- God Mode Turbo Stats
    HackedBoost = 5000, -- Normal is ~15. 5000 is insane speed.
    HackedCount = 4     -- Quad Turbo
}

-- === 1. TRAFFIC JAMMER (The Working Hook) ===
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
ScreenGui.Name = "JOSEPEDOV20_UI"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 180) 
MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(5, 10, 20) -- Deep Ocean
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(0, 150, 255)
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Text = "JOSEPEDOV20"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(0, 150, 255)
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

-- [BUTTON] 2. INJECT GOD TURBO (The New Hack)
local InjectBtn = Instance.new("TextButton")
InjectBtn.Size = UDim2.new(0.9, 0, 0, 40)
InjectBtn.Position = UDim2.new(0.05, 0, 0.50, 0)
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
        
        -- 1. Find the Remote Event
        -- Path from your logs: ReplicatedStorage.Modules.Modules.Network.RemoteEvent
        local remote = ReplicatedStorage:FindFirstChild("Modules") 
            and ReplicatedStorage.Modules:FindFirstChild("Modules") 
            and ReplicatedStorage.Modules.Modules:FindFirstChild("Network") 
            and ReplicatedStorage.Modules.Modules.Network:FindFirstChild("RemoteEvent")
            
        -- 2. Find the Car ID
        -- Your log showed "143". This is likely an Attribute on the Car Value.
        local carVal = car:FindFirstChild("Car") and car.Car.Value or car
        local carID = carVal:GetAttribute("VehicleId") or carVal:GetAttribute("ID")
        
        -- Fallback: If we can't find ID, try to guess or use the log's number if consistent
        -- But "143" likely changes per car. We rely on finding the Attribute.
        
        if remote and carID then
            -- 3. FIRE THE EXPLOIT
            -- We replicate the log structure exactly
            -- Args: "SetAspiration", CarID, "Turbo", {Stats Table}
            
            local hackedStats = {
                ["Turbochargers"] = Config.HackedCount, -- 4 Turbos
                ["T_Boost"] = Config.HackedBoost,       -- 5000 PSI per turbo
                ["Superchargers"] = 0,
                ["S_Boost"] = 0
            }
            
            remote:FireServer("SetAspiration", carID, "Turbo", hackedStats)
            
            InjectBtn.Text = "✅ SENT TO SERVER!"
            InjectBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
            
            -- Optional: Fire local event too (UpdateTune) just to be sure
            local tuneEvent = carVal:FindFirstChild("TuneUpdatedEvent")
            if tuneEvent then
               -- We can try firing this too, but the Server Remote is the main target
            end
            
        else
            if not remote then InjectBtn.Text = "❌ Remote Not Found" end
            if not carID then InjectBtn.Text = "❌ Car ID Not Found" end
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
