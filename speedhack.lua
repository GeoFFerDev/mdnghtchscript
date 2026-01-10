-- [[ JOSEPEDOV12: THE LIAR ]] --
-- Features: Velocity Spoofing (Speed Limit Bypass), Traffic Disconnector
-- Optimized for Delta | Based on "sourcedec.zip" Analysis

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- === CONFIGURATION ===
local Config = {
    SpeedEnabled = false,
    TrafficBlocked = false,
    SpoofFactor = 0.1, -- 0.1 means we tell the game we are going 10% of real speed
    ForcePower = 20 -- Extra push for acceleration
}

-- === UI CREATION ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JOSEPEDOV12_UI"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 220)
MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(10, 10, 10) -- Pitch Black
MainFrame.BorderSizePixel = 2
MainFrame.BorderColor3 = Color3.fromRGB(255, 0, 0) -- Red Outline
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

-- Title
local Title = Instance.new("TextLabel")
Title.Text = "JOSEPEDOV12"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 0, 0)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 18
Title.Parent = MainFrame

-- [BUTTON] 1. KILL TRAFFIC (Disconnector)
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
        
        -- METHOD: Disconnect the event entirely
        local event = ReplicatedStorage:FindFirstChild("CreateNPCVehicle")
        if event then
            for _, connection in pairs(getconnections(event.OnClientEvent)) do
                connection:Disable() -- This cuts the wire permanently for this session
            end
        end
        
        -- Cleanup existing
        local npcFolder = Workspace:FindFirstChild("NPCVehicles") or Workspace:FindFirstChild("Traffic")
        if npcFolder then npcFolder:ClearAllChildren() end
    else
        TrafficBtn.Text = "Traffic: ALLOWED"
        TrafficBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        
        local event = ReplicatedStorage:FindFirstChild("CreateNPCVehicle")
        if event then
            for _, connection in pairs(getconnections(event.OnClientEvent)) do
                connection:Enable() -- Reconnect
            end
        end
    end
end)

-- [BUTTON] 2. SPEED SPOOFER (The "Liar" Hack)
local SpeedBtn = Instance.new("TextButton")
SpeedBtn.Size = UDim2.new(0.9, 0, 0, 40)
SpeedBtn.Position = UDim2.new(0.05, 0, 0.45, 0)
SpeedBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
SpeedBtn.Text = "⚡ Speed Spoof: OFF"
SpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBtn.Font = Enum.Font.GothamBold
SpeedBtn.TextSize = 14
SpeedBtn.Parent = MainFrame
Instance.new("UICorner", SpeedBtn).CornerRadius = UDim.new(0, 6)

-- HOOK LOGIC
local oldIndex = nil
oldIndex = hookmetamethod(game, "__index", function(self, key)
    -- Only active if enabled and checking Velocity
    if Config.SpeedEnabled and not checkcaller() then
        if key == "Velocity" or key == "AssemblyLinearVelocity" then
            -- Check if "self" is a part of our car
            local char = player.Character
            if char and char:FindFirstChild("Humanoid") and char.Humanoid.SeatPart then
                local car = char.Humanoid.SeatPart.Parent
                if self:IsDescendantOf(car) then
                    -- RETURN THE LIE: "We are moving very slow"
                    -- The game physics engine then adds MORE power to compensate
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
        SpeedBtn.Text = "⚡ Speed Spoof: ACTIVE"
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 0)
        SpeedBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
    else
        SpeedBtn.Text = "⚡ Speed Spoof: OFF"
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
        SpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
    end
end)

-- [BUTTON] 3. CFrame Assist (Helper)
-- Sometimes spoofing isn't enough for acceleration, this adds a tiny push
local AssistBtn = Instance.new("TextButton")
AssistBtn.Size = UDim2.new(0.9, 0, 0, 40)
AssistBtn.Position = UDim2.new(0.05, 0, 0.70, 0)
AssistBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
AssistBtn.Text = "🚀 Assist Push: OFF"
AssistBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
AssistBtn.Font = Enum.Font.GothamBold
AssistBtn.TextSize = 14
AssistBtn.Parent = MainFrame
Instance.new("UICorner", AssistBtn).CornerRadius = UDim.new(0, 6)

local assistEnabled = false
AssistBtn.MouseButton1Click:Connect(function()
    assistEnabled = not assistEnabled
    if assistEnabled then
        AssistBtn.Text = "🚀 Assist Push: ON"
        AssistBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 0)
    else
        AssistBtn.Text = "🚀 Assist Push: OFF"
        AssistBtn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    end
end)

-- LOOP FOR ASSIST PUSH
RunService.Heartbeat:Connect(function()
    if not assistEnabled then return end
    
    local char = player.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid or not humanoid.SeatPart then return end
    
    local seat = humanoid.SeatPart
    if seat.Throttle > 0 then
        seat.AssemblyLinearVelocity = seat.AssemblyLinearVelocity + (seat.CFrame.LookVector * Config.ForcePower)
    end
end)

-- CLOSE BUTTON
local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(0.85, 0, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
CloseBtn.Parent = MainFrame
CloseBtn.MouseButton1Click:Connect(function() ScreenGui:Destroy() end)
