-- [[ JOSEPEDOV4: UNIVERSAL GHOST ]] --
-- Features: Seat-Based Detection (No Folder Guessing), Limit Breaker, Minimize
-- Optimized for Delta

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- === CONFIGURATION ===
local Config = {
    SpeedEnabled = false,
    GhostMode = false,    -- Banish Traffic
    TargetSpeed = 400,    -- Max Speed (MPH)
    AccelPower = 2,       -- Acceleration
    BrakePower = 0.9      -- Braking Strength
}

-- === UI CREATION ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JOSEPEDOV4_UI"
ScreenGui.Parent = game.CoreGui

-- Main Frame
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

-- Open Button (Small)
local OpenBtn = Instance.new("TextButton")
OpenBtn.Name = "OpenBtn"
OpenBtn.Size = UDim2.new(0, 50, 0, 50)
OpenBtn.Position = UDim2.new(0, 10, 0.4, 0)
OpenBtn.BackgroundColor3 = Color3.fromRGB(0, 255, 255)
OpenBtn.Text = "J4"
OpenBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
OpenBtn.Font = Enum.Font.GothamBlack
OpenBtn.TextSize = 18
OpenBtn.Visible = false 
OpenBtn.Parent = ScreenGui
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 12)

-- Title
local Title = Instance.new("TextLabel")
Title.Text = "JOSEPEDOV4"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(0, 255, 255)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 18
Title.Parent = MainFrame

-- [TOGGLE] SPEED HACK
local SpeedBtn = Instance.new("TextButton")
SpeedBtn.Size = UDim2.new(0.9, 0, 0, 40)
SpeedBtn.Position = UDim2.new(0.05, 0, 0.20, 0)
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
    else
        SpeedBtn.Text = "Speed Hack: OFF"
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") and char.Humanoid.SeatPart then
            if char.Humanoid.SeatPart:FindFirstChild("LimitBreaker") then
                char.Humanoid.SeatPart.LimitBreaker:Destroy()
            end
        end
    end
end)

-- [TOGGLE] GHOST TRAFFIC
local GhostBtn = Instance.new("TextButton")
GhostBtn.Size = UDim2.new(0.9, 0, 0, 40)
GhostBtn.Position = UDim2.new(0.05, 0, 0.45, 0)
GhostBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
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
        GhostBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 255)
    else
        GhostBtn.Text = "Ghost Traffic: OFF"
        GhostBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)

-- Minimize Logic
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

-- Close Button
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

-- === UNIVERSAL GHOST LOGIC (SEAT SCANNER) ===
-- We scan for seats, not folder names. This is much harder for the game to hide.
RunService.Stepped:Connect(function()
    if not Config.GhostMode then return end
    
    local myChar = player.Character
    local mySeat = nil
    if myChar and myChar:FindFirstChild("Humanoid") then
        mySeat = myChar.Humanoid.SeatPart
    end

    -- Loop through EVERYTHING in Workspace to find seats
    -- Note: We use GetDescendants() but filtered for performance
    for _, obj in pairs(Workspace:GetDescendants()) do
        if obj:IsA("VehicleSeat") or obj:IsA("Seat") then
            -- FOUND A CAR SEAT
            local carModel = obj:FindFirstAncestorWhichIsA("Model")
            
            if carModel then
                -- CHECK: Is this OUR car?
                local isMine = false
                if mySeat and (mySeat == obj or mySeat:IsDescendantOf(carModel)) then
                    isMine = true
                end
                
                -- If it's NOT our car, BANISH IT
                if not isMine then
                    -- Double check it's actually a vehicle (has wheels or engine)
                    if carModel:FindFirstChild("Wheels") or carModel:FindFirstChild("A-Chassis Tune") or carModel.Name:lower():match("car") or carModel.Name:lower():match("traffic") then
                        
                        -- Banish Logic: Anchor and Teleport Underground
                        for _, part in pairs(carModel:GetDescendants()) do
                            if part:IsA("BasePart") then
                                part.CanCollide = false
                                part.Anchored = true
                                -- Only move it if it's not already underground
                                if part.Position.Y > -100 then
                                    part.CFrame = CFrame.new(part.Position.X, -500, part.Position.Z)
                                end
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
