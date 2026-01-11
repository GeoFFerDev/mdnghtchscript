-- [[ JOSEPEDOV17: RPM HOOKER ]] --
-- Features: RotVelocity Hook (Infinite Revs), Traffic Disconnector, Auto-Grip
-- Optimized for Delta | Fixes V16's "Slow" issue by maintaining Grip

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- === CONFIGURATION ===
local Config = {
    SpeedEnabled = false,
    TrafficBlocked = false,
    SpoofFactor = 0.2, -- We tell the game we are 5x slower than reality (Lower = Faster)
    GripPower = 2.5,   -- 2.5x Normal Grip (Sticks to road)
}

-- === 1. TRAFFIC JAMMER (The Working Hook) ===
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
ScreenGui.Name = "JOSEPEDOV17_UI"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 220)
MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(255, 50, 50) -- Red Theme
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Text = "JOSEPEDOV17"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 50, 50)
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

-- [BUTTON] 2. RPM HOOK (Speed)
local SpeedBtn = Instance.new("TextButton")
SpeedBtn.Size = UDim2.new(0.9, 0, 0, 40)
SpeedBtn.Position = UDim2.new(0.05, 0, 0.45, 0)
SpeedBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SpeedBtn.Text = "⚡ RPM Hook: OFF"
SpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBtn.Font = Enum.Font.GothamBold
SpeedBtn.TextSize = 14
SpeedBtn.Parent = MainFrame
Instance.new("UICorner", SpeedBtn).CornerRadius = UDim.new(0, 6)

-- === THE SPEED HOOK LOGIC ===
local oldIndex = nil
oldIndex = hookmetamethod(game, "__index", function(self, key)
    -- Only run if enabled and called by the Game Script (not us)
    if Config.SpeedEnabled and not checkcaller() then
        -- Check if the game is reading Wheel Speed
        if key == "RotVelocity" then
            -- Verify "self" is a Wheel on our car
            local char = player.Character
            if char and char:FindFirstChild("Humanoid") and char.Humanoid.SeatPart then
                local car = char.Humanoid.SeatPart.Parent
                if self:IsDescendantOf(car) and self:IsA("BasePart") then
                    -- RETURN THE LIE: "We are spinning slowly"
                    -- This tricks the A-Chassis Limiter into giving more power
                    return oldIndex(self, key) * Config.SpoofFactor
                end
            end
        end
    end
    return oldIndex(self, key)
end)

SpeedBtn.MouseButton1Click:Connect(function()
    Config.SpeedEnabled = not Config.SpeedEnabled
    if Config.SpeedEnabled then
        SpeedBtn.Text = "⚡ RPM Hook: ACTIVE"
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(255, 50, 50) -- Red
        SpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
        
        -- AUTO-APPLY GRIP (Fixes the V16 "Slow" issue)
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") and char.Humanoid.SeatPart then
            local car = char.Humanoid.SeatPart.Parent
            for _, part in pairs(car:GetDescendants()) do
                if part:IsA("BasePart") and (part.Name == "FL" or part.Name == "FR" or part.Name == "RL" or part.Name == "RR" or part.Name:match("Wheel")) then
                    -- High Friction = Good Grip
                    part.CustomPhysicalProperties = PhysicalProperties.new(10, Config.GripPower, 0, 100, 100)
                end
            end
        end
        
    else
        SpeedBtn.Text = "⚡ RPM Hook: OFF"
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end
end)

-- [BUTTON] 3. PANIC RESET
local PanicBtn = Instance.new("TextButton")
PanicBtn.Size = UDim2.new(0.9, 0, 0, 40)
PanicBtn.Position = UDim2.new(0.05, 0, 0.70, 0)
PanicBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
PanicBtn.Text = "⚠️ RESET ALL"
PanicBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
PanicBtn.Font = Enum.Font.GothamBold
PanicBtn.TextSize = 14
PanicBtn.Parent = MainFrame
Instance.new("UICorner", PanicBtn).CornerRadius = UDim.new(0, 6)

PanicBtn.MouseButton1Click:Connect(function()
    Config.SpeedEnabled = false
    SpeedBtn.Text = "⚡ RPM Hook: OFF"
    SpeedBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    -- Reset Friction (Optional, usually resetting char works best)
end)

-- Minimize
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
