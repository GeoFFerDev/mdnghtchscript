-- [[ JOSEPEDOV5: ATTRIBUTE EDITION ]] --
-- Features: Attribute Modding (Based on Decompiled Code), Limit Breaker Speed, Minimized UI
-- Optimized for Delta

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- === CONFIGURATION ===
local Config = {
    SpeedEnabled = false,
    TargetSpeed = 400,    -- Max Speed (MPH)
    AccelPower = 3,       -- Acceleration (Increased for V5)
    BrakePower = 0.8
}

-- === UI CREATION ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JOSEPEDOV5_UI"
ScreenGui.Parent = game.CoreGui

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 200) -- Smaller since we removed Traffic
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
OpenBtn.Text = "J5"
OpenBtn.TextColor3 = Color3.fromRGB(0, 0, 0)
OpenBtn.Font = Enum.Font.GothamBlack
OpenBtn.TextSize = 18
OpenBtn.Visible = false 
OpenBtn.Parent = ScreenGui
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 12)

-- Title
local Title = Instance.new("TextLabel")
Title.Text = "JOSEPEDOV5"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(0, 255, 255)
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 18
Title.Parent = MainFrame

-- [TOGGLE] SPEED HACK (Physics)
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

-- [BUTTON] UPGRADE ENGINE (New Attribute Hack)
local UpgradeBtn = Instance.new("TextButton")
UpgradeBtn.Size = UDim2.new(0.9, 0, 0, 40)
UpgradeBtn.Position = UDim2.new(0.05, 0, 0.50, 0)
UpgradeBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 0) -- Orange
UpgradeBtn.Text = "⚡ Upgrade Attributes"
UpgradeBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
UpgradeBtn.Font = Enum.Font.GothamBold
UpgradeBtn.TextSize = 14
UpgradeBtn.Parent = MainFrame
Instance.new("UICorner", UpgradeBtn).CornerRadius = UDim.new(0, 6)

UpgradeBtn.MouseButton1Click:Connect(function()
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") and char.Humanoid.SeatPart then
        local car = char.Humanoid.SeatPart.Parent
        
        -- Based on your decompiled code, the stats are in the Car Value object
        -- Line 4: local Value_13_upvr = script.Parent.Parent.Car.Value
        local carValue = car:FindFirstChild("Car") and car.Car.Value or car
        
        if carValue then
            -- We look for the attributes mentioned in your file (Line 44, 193)
            local statsToBuff = {"MaxBoost", "Horsepower", "Torque", "MaxSpeed", "Turbochargers", "PeakRPM", "Redline"}
            
            for _, stat in pairs(statsToBuff) do
                local current = carValue:GetAttribute(stat)
                if current then
                    -- Multiply by 5 for massive boost
                    carValue:SetAttribute(stat, current * 5)
                end
            end
            
            -- Also check for NumberValues inside "Values" folder (Line 240 in your file)
            local valuesFolder = carValue:FindFirstChild("Values") or car:FindFirstChild("Values")
            if valuesFolder then
                for _, v in pairs(valuesFolder:GetChildren()) do
                    if v:IsA("NumberValue") and (v.Name == "Horsepower" or v.Name == "Torque" or v.Name == "BoostTurbo") then
                        v.Value = v.Value * 5
                    end
                end
            end
            
            UpgradeBtn.Text = "✅ Upgraded!"
            task.wait(2)
            UpgradeBtn.Text = "⚡ Upgrade Attributes"
        else
            UpgradeBtn.Text = "❌ Car Value Not Found"
            task.wait(2)
            UpgradeBtn.Text = "⚡ Upgrade Attributes"
        end
    else
        UpgradeBtn.Text = "⚠️ Sit in Driver Seat!"
        task.wait(2)
        UpgradeBtn.Text = "⚡ Upgrade Attributes"
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

-- === LIMIT BREAKER SPEED LOOP ===
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
        -- Push harder if we are below target speed
        if currentSpeed < (Config.TargetSpeed * 1.5) then 
            existingVel.Velocity = seat.CFrame.LookVector * (currentSpeed + Config.AccelPower)
        else
            -- Maintain max speed
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
