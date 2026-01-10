-- [[ JOSEPEDOV6: EVENT OVERRIDE ]] --
-- Features: Internal Tune Event Hijack, Limit Breaker V2, Minimized UI
-- Optimized for Delta

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local player = Players.LocalPlayer

-- === CONFIGURATION ===
local Config = {
    SpeedEnabled = false,
    TargetSpeed = 400,    -- Max Speed (MPH)
    AccelPower = 3,       -- Acceleration
    BrakePower = 0.8
}

-- === UI CREATION ===
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "JOSEPEDOV6_UI"
ScreenGui.Parent = game.CoreGui

-- Main Frame
local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 220, 0, 180) -- Compact
MainFrame.Position = UDim2.new(0.1, 0, 0.2, 0)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
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
OpenBtn.BackgroundColor3 = Color3.fromRGB(255, 0, 255) -- Magenta
OpenBtn.Text = "J6"
OpenBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OpenBtn.Font = Enum.Font.GothamBlack
OpenBtn.TextSize = 18
OpenBtn.Visible = false 
OpenBtn.Parent = ScreenGui
Instance.new("UICorner", OpenBtn).CornerRadius = UDim.new(0, 12)

-- Title
local Title = Instance.new("TextLabel")
Title.Text = "JOSEPEDOV6"
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundTransparency = 1
Title.TextColor3 = Color3.fromRGB(255, 0, 255) -- Magenta Theme
Title.Font = Enum.Font.GothamBlack
Title.TextSize = 18
Title.Parent = MainFrame

-- [TOGGLE] PHYSICS SPEED (Backup)
local SpeedBtn = Instance.new("TextButton")
SpeedBtn.Size = UDim2.new(0.9, 0, 0, 40)
SpeedBtn.Position = UDim2.new(0.05, 0, 0.25, 0)
SpeedBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
SpeedBtn.Text = "Force Speed: OFF"
SpeedBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
SpeedBtn.Font = Enum.Font.GothamBold
SpeedBtn.TextSize = 14
SpeedBtn.Parent = MainFrame
Instance.new("UICorner", SpeedBtn).CornerRadius = UDim.new(0, 6)

SpeedBtn.MouseButton1Click:Connect(function()
    Config.SpeedEnabled = not Config.SpeedEnabled
    if Config.SpeedEnabled then
        SpeedBtn.Text = "Force Speed: ON"
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(50, 200, 50) 
    else
        SpeedBtn.Text = "Force Speed: OFF"
        SpeedBtn.BackgroundColor3 = Color3.fromRGB(200, 50, 50)
        local char = player.Character
        if char and char:FindFirstChild("Humanoid") and char.Humanoid.SeatPart then
            if char.Humanoid.SeatPart:FindFirstChild("LimitBreaker") then
                char.Humanoid.SeatPart.LimitBreaker:Destroy()
            end
        end
    end
end)

-- [BUTTON] OVERRIDE TUNE (The New Hack)
local OverrideBtn = Instance.new("TextButton")
OverrideBtn.Size = UDim2.new(0.9, 0, 0, 40)
OverrideBtn.Position = UDim2.new(0.05, 0, 0.55, 0)
OverrideBtn.BackgroundColor3 = Color3.fromRGB(255, 170, 0) -- Orange
OverrideBtn.Text = "🔥 Inject Super Tune"
OverrideBtn.TextColor3 = Color3.fromRGB(255, 255, 255)
OverrideBtn.Font = Enum.Font.GothamBold
OverrideBtn.TextSize = 14
OverrideBtn.Parent = MainFrame
Instance.new("UICorner", OverrideBtn).CornerRadius = UDim.new(0, 6)

OverrideBtn.MouseButton1Click:Connect(function()
    local char = player.Character
    if char and char:FindFirstChild("Humanoid") and char.Humanoid.SeatPart then
        local car = char.Humanoid.SeatPart.Parent
        local carValue = car:FindFirstChild("Car") and car.Car.Value or car
        
        -- Try to find the Event we saw in the code: "UpdateTune"
        -- Code line: Value_upvr:WaitForChild("UpdateTune")
        local updateEvent = carValue:FindFirstChild("UpdateTune")
        
        -- Try to find the Tune Module
        local tuneModule = carValue:FindFirstChild("A-Chassis Tune")
        
        if tuneModule then
            local success, tuneData = pcall(require, tuneModule)
            
            if success and tuneData then
                -- MODIFY THE DATA TABLE
                tuneData.Horsepower = 100000
                tuneData.Torque = 50000
                tuneData.MaxSpeed = 500
                tuneData.PeakRPM = 12000
                tuneData.Redline = 13000
                tuneData.Turbochargers = 2
                tuneData.T_Boost = 50
                tuneData.Superchargers = 1
                tuneData.S_Boost = 50
                
                -- FORCE UPDATE (If the event exists)
                if updateEvent then
                    -- We fire the event to tell the car "Here is your new engine!"
                    updateEvent:Fire(tuneData) 
                    OverrideBtn.Text = "✅ Tune Injected!"
                else
                    -- Fallback: Just requiring it might update it if it's a shared table
                    OverrideBtn.Text = "⚠️ Event Missing (Edited Table)"
                end
                
                -- Attribute fallback (from V5)
                carValue:SetAttribute("MaxBoost", 500)
                carValue:SetAttribute("CurrentBoost", 500)
                
            else
                OverrideBtn.Text = "❌ Locked Module"
            end
        else
            OverrideBtn.Text = "❌ No Tune Script"
        end
        
        task.wait(2)
        OverrideBtn.Text = "🔥 Inject Super Tune"
    else
        OverrideBtn.Text = "⚠️ Sit in Driver Seat!"
        task.wait(2)
        OverrideBtn.Text = "🔥 Inject Super Tune"
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

-- === FORCE SPEED LOOP (Backup) ===
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
