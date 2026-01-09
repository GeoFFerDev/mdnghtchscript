-- [[ JOSEPEDOV4: VOID EDITION ]] --
-- Features: Banished Traffic (Empty Road), Limit Breaker Speed, Minimized UI
-- Optimized for Delta

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- === CONFIGURATION ===
local Config = {
    SpeedEnabled = false,
    GhostMode = false,    -- Now "Banish Mode"
    TargetSpeed = 400,    -- Max Speed (MPH)
    AccelPower = 2,       -- Acceleration
    BrakePower = 0.9      -- Braking Strength
}

-- === UI CREATION ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JOSEPEDOV4_UI"
ScreenGui.Parent = game.CoreGui

-- 1. THE MAIN MENU FRAME
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 230)
MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true 
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 8)
UICorner.Parent = MainFrame

-- 2. THE "OPEN" BUTTON (Hidden by default)
local OpenBtn = Instance.new("TextButton")
OpenBtn.Name = "OpenBtn"
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0, 10, 0.4, 0) -- Left side
OpenBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 255) -- Cyan
OpenBtn.Text = "J4"
OpenBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
OpenBtn.Font = Enum.Font.GothamBlack
OpenBtn.TextSize = 18
OpenBtn.Visible = false 
OpenBtn.Parent = ScreenGui
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 12)

-- [TITLE]
local Title = Instance.new("TextLabel")
Title.Text = "JOSEPEDOV4"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(0, 255, 255) -- Cyan
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 18
Title.Parent = MainFrame

-- [TOGGLE] SPEED HACK
local SpeedBtn = Instance.new("TextButton")
SpeedBtn.Size = UDim2.new(0.9, 0, 0, 40)
SpeedBtn.Position = UDim2.new(0.05, 0, 0.20, 0)
SpeedBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Red
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
    else
        SpeedBtn.Text = "Speed Hack: OFF"
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        -- Cleanup Speed
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") and char.Humanoid.SeatPart then
            if char.Humanoid.SeatPart:FindFirstChild("LimitBreaker") then
                char.Humanoid.SeatPart.LimitBreaker:Destroy()
            end
        end
    end
end)

-- [TOGGLE] BANISH TRAFFIC (Void Mode)
local GhostBtn = Instance.new("TextButton")
GhostBtn.Size = UDim2.new(0.9, 0, 0, 40)
GhostBtn.Position = UDim2.new(0.05, 0, 0.45, 0)
GhostBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50) -- Red
GhostBtn.Text = "Ghost Traffic: OFF"
GhostBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
GhostBtn.Font = Enum.Font.GothamBold
GhostBtn.TextSize = 14
GhostBtn.Parent = MainFrame
Instance.new("UICorner", GhostBtn).CornerRadius = UDim.new(0, 6)

GhostBtn.MouseButton1Click:Connect(function()
    Config.GhostMode = not Config.GhostMode
    if Config.GhostMode then
        GhostBtn.Text = "Ghost Traffic: ON 👻"
        GhostBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 255) -- Purple
    else
        GhostBtn.Text = "Ghost Traffic: OFF"
        GhostBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)

-- [BUTTON] MINIMIZE (-)
local MinBtn = Instance.new("TextButton")
MinBtn.Text = "-"
MinBtn.Size = UDim2.new(0, 30, 0, 30)
MinBtn.Position = UDim2.new(0.70, 0, 0, 0) -- Next to X
MinBtn.BackgroundTransparency = 1
MinBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
MinBtn.Font = Enum.Font.GothamBlack
MinBtn.TextSize = 24
MinBtn.Parent = MainFrame

MinBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = false
    OpenBtn.Visible = true
end)

OpenBtn.MouseButton1Click:Connect(function()
    MainFrame.Visible = true
    OpenBtn.Visible = false
end)

-- [BUTTON] CLOSE (X)
local CloseBtn = Instance.new("TextButton")
CloseBtn.Text = "X"
CloseBtn.Size = UDim2.new(0, 30, 0, 30)
CloseBtn.Position = UDim2.new(0.85, 0, 0, 0)
CloseBtn.BackgroundTransparency = 1
CloseBtn.TextColor3 = Color3.fromRGB(255, 100, 100)
CloseBtn.Font = Enum.Font.GothamBlack
CloseBtn.TextSize = 18
CloseBtn.Parent = MainFrame

CloseBtn.MouseButton1Click:Connect(function()
    ScreenGui:Destroy()
end)

-- === BANISH TRAFFIC LOGIC (VOID METHOD) ===
-- Instead of changing collision (which fails), we just move them underground.
RunService.Stepped:Connect(function()
    if not Config.GhostMode then return end
    
    local myCar = nil
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") and char.Humanoid.SeatPart then
        myCar = char.Humanoid.SeatPart.Parent
    end

    -- Scans for known traffic folders
    local trafficFolders = {Workspace:FindFirstChild("NPC vehicles"), Workspace:FindFirstChild("Traffic"), Workspace:FindFirstChild("Vehicles")}
    
    for _, folder in pairs(trafficFolders) do
        if folder then
            for _, car in pairs(folder:GetChildren()) do
                -- Ensure we don't banish our own car
                if car ~= myCar and car:IsA("Model") then
                    local primary = car.PrimaryPart or car:FindFirstChild("Body") or car:FindFirstChild("DriveSeat")
                    
                    if primary then
                        -- TELEPORT THEM UNDERGROUND
                        -- We lock them to Y = -500 so they fall out of the world visually
                        -- We use Anchored = true so they don't try to drive back up
                        for _, part in pairs(car:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.Anchored = true
                                part.CanCollide = false 
                                part.CFrame = CFrame.new(part.Position.X, -500, part.Position.Z)
                            end
                        end
                    end
                end
            end
        end
    end
end)

-- === SPEED LOOP ===
RunService.Heartbeat:Connect(function()
    if not Config.SpeedEnabled then return end
    local char = player.Character
    if not char then return end
    local humanoid = char:FindFirstChild("Humanoid")
    if not humanoid or not humanoid.SeatPart then return end
    
    local seat = humanoid.SeatPart
    local existingVel = seat:FindFirstChild("LimitBreaker")
    local currentSpeed = seat.Velocity.Magnitude
    
    if seat.Throttle > 0 then
        if not existingVel then
            local bv = Instance.new("BodyVelocity")
            bv.Name = "LimitBreaker"
            bv.MaxForce = Vector3.new(100000, 0, 100000) 
            bv.Parent = seat
            existingVel = bv
        end
        if currentSpeed < (Config.TargetSpeed * 1.5) then 
            existingVel.Velocity = seat.CFrame.LookVector * (currentSpeed + Config.AccelPower)
        else
             existingVel.Velocity = seat.CFrame.LookVector * currentSpeed
        end
    elseif seat.Throttle < 0 then
        if not existingVel then
            local bv = Instance.new("BodyVelocity")
            bv.Name = "LimitBreaker"
            bv.MaxForce = Vector3.new(100000, 0, 100000)
            bv.Parent = seat
            existingVel = bv
        end
        existingVel.Velocity = seat.Velocity * Config.BrakePower
        if seat.Velocity.Magnitude < 5 then existingVel:Destroy() end
    else
        if existingVel then existingVel:Destroy() end
    end
end)
