-- [[ JOSEPEDOV9: CFrame Speed ]] --
-- Features: Position-Based Speed (Bypasses Velocity Limits), Traffic Jammer, UI
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
    SpeedPower = 1, -- Studs per frame (Start small!)
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
ScreenGui.Name = "JOSEPEDOV9_UI"
ScreenGui.Parent = game.CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 180) 
MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
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
OpenBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 100) -- Matrix Green
OpenBtn.Text = "J9"
OpenBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
OpenBtn.Font = Enum.Font.GothamBlack
OpenBtn.TextSize = 18
OpenBtn.Visible = false 
OpenBtn.Parent = ScreenGui
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 12)

-- Title
local Title = Instance.new("TextLabel")
Title.Text = "JOSEPEDOV9"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(0, 255, 100)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 18
Title.Parent = MainFrame

-- [TOGGLE] CFRAME SPEED (The Bypass)
local SpeedBtn = Instance.new("TextButton")
SpeedBtn.Size = UDim2.new(0.9, 0, 0, 40)
SpeedBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
SpeedBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
SpeedBtn.Text = "CFrame Speed: OFF"
SpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBtn.Font = Enum.Font.GothamBold
SpeedBtn.TextSize = 14
SpeedBtn.Parent = MainFrame
Instance.new("UICorner", SpeedBtn).CornerRadius = UDim.new(0, 6)

SpeedBtn.MouseButton1Click:Connect(function()
    Config.SpeedEnabled = not Config.SpeedEnabled
    if Config.SpeedEnabled then
        SpeedBtn.Text = "CFrame Speed: ON"
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50) 
    else
        SpeedBtn.Text = "CFrame Speed: OFF"
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
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
        -- Clear cars
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

-- === CFRAME SPEED LOOP ===
-- This moves the car by changing its Position, ignoring Physics limits.
RunService.Heartbeat:Connect(function()
    if not Config.SpeedEnabled then return end
    
    local char = player.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid or not humanoid.SeatPart then return end
    
    local seat = humanoid.SeatPart
    local car = seat.Parent
    
    -- Only boost if holding Gas (Throttle > 0)
    if seat.Throttle > 0 then
        -- Get the direction the car is facing
        local lookDirection = seat.CFrame.LookVector
        
        -- Teleport slightly forward
        -- We use TranslateBy to move relative to world
        local rootPart = car.PrimaryPart or seat
        if rootPart then
            rootPart.CFrame = rootPart.CFrame + (lookDirection * Config.SpeedPower)
            
            -- Optional: Set velocity to max allowed to keep sound engine working
            rootPart.AssemblyLinearVelocity = lookDirection * 100
        end
    end
end)
