-- [[ JOSEPEDOV4: PATHFINDER EDITION ]] --
-- Features: Exact Path Ghosting (Based on your Dex findings), Limit Breaker, Minimize
-- Optimized for Delta

local Players = game:GetService("Players")
local Workspace = game:GetService("Workspace")
local RunService = game:GetService("RunService")
local player = Players.LocalPlayer

-- === CONFIGURATION ===
local Config = {
    SpeedEnabled = false,
    GhostEnabled = false,
    TargetSpeed = 400,
    AccelPower = 2,
    BrakePower = 0.9
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

-- === EXACT PATH LOGIC ===
-- This targets: Workspace > NPC vehicles > Vehicles > [Numbers] > Part > Car
local function GhostSpecificCar(carModel)
    if not carModel then return end
    
    -- Loop through all parts inside the car model
    for _, part in pairs(carModel:GetDescendants()) do
        if part:IsA("BasePart") or part:IsA("MeshPart") or part:IsA("Part") then
            -- Force Collision OFF based on the checkboxes you saw
            part.CanCollide = false
            part.CanTouch = false
            part.CanQuery = false
            
            -- Make transparent so you know it worked
            if part.Transparency < 0.5 then
                part.Transparency = 0.8
            end
        end
    end
end

-- The main loop that finds the specific folder
local function ApplyGhosting()
    local npcRoot = Workspace:FindFirstChild("NPC vehicles")
    if npcRoot then
        local vehiclesFolder = npcRoot:FindFirstChild("Vehicles")
        if vehiclesFolder then
            -- Iterate through the Numbered Folders
            for _, numberFolder in pairs(vehiclesFolder:GetChildren()) do
                -- Inside the numbered folder, you said there is a "Part" or "Car"
                -- We will just ghost EVERYTHING inside that number folder to be safe
                GhostSpecificCar(numberFolder)
            end
        end
    end
end

GhostBtn.MouseButton1Click:Connect(function()
    Config.GhostEnabled = not Config.GhostEnabled
    if Config.GhostEnabled then
        GhostBtn.Text = "Ghost Traffic: ON 👻"
        GhostBtn.BackgroundColor3 = Color3.fromRGB(150, 100, 255)
        ApplyGhosting() -- Run once immediately
    else
        GhostBtn.Text = "Ghost Traffic: OFF"
        GhostBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
    end
end)

-- Listener for NEW cars spawning in that specific folder
Workspace.DescendantAdded:Connect(function(descendant)
    if Config.GhostEnabled then
        -- Check if the new object is inside "NPC vehicles"
        if descendant:IsDescendantOf(Workspace:FindFirstChild("NPC vehicles")) then
            if descendant:IsA("Model") or descendant:IsA("Folder") then
                task.wait(0.1) -- Wait for parts to load
                GhostSpecificCar(descendant)
            end
        end
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
