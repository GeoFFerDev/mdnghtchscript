-- [[ JOSEPEDOV50: GEAR-SAFE MODE (FIXED) ]]
-- Reverse can NEVER accelerate now
-- Speed boost only works in real forward gear

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local player = Players.LocalPlayer

-- === CONFIGURATION ===
local Config = {
    TrafficBlocked = false,
    BoostPower = 7000,     -- Forward Power
    Enabled = false,      -- Master Toggle
    Deadzone = 0.1        -- Gas Threshold
}

-- === STATE ===
local currentSeat = nil

-- === 1. TRAFFIC JAMMER ===
local function InstallTrafficHook()
    local event = ReplicatedStorage:FindFirstChild("CreateNPCVehicle")
    if event then
        for _, connection in pairs(getconnections(event.OnClientEvent)) do
            local oldFunction = connection.Function
            if oldFunction then
                hookfunction(oldFunction, function(...)
                    if Config.TrafficBlocked then return end
                    return oldFunction(...)
                end)
            end
        end
    end
end
InstallTrafficHook()

-- === UI (unchanged, removed for brevity if you want UI back I can paste it too) ===
-- Your UI code can stay the same, physics part below is what matters

-- === PHYSICS LOOP (FULLY FIXED) ===
RunService.Heartbeat:Connect(function()
    if not Config.Enabled then
        if currentSeat then
            local thrust = currentSeat:FindFirstChild("J50_Thrust")
            if thrust then thrust:Destroy() end
            currentSeat = nil
        end
        return
    end

    local char = player.Character
    if not char then return end

    -- Refresh Seat
    if currentSeat and (not currentSeat.Parent or not currentSeat:IsDescendantOf(Workspace)) then
        currentSeat = nil
    end

    if not currentSeat then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid and humanoid.SeatPart then
            currentSeat = humanoid.SeatPart
        else
            local carModel = Workspace:FindFirstChild("Lf20Besaya's Car")
            if carModel then
                currentSeat = carModel:FindFirstChild("DriveSeat")
            end
        end
    end

    if not currentSeat then return end

    -- === READ A-CHASSIS VALUES ===
    local gasVal = 0
    local brakeVal = 0
    local gearVal = 1

    local interface = player.PlayerGui:FindFirstChild("A-Chassis Interface")
    if interface then
        local valFolder = interface:FindFirstChild("Values")
        if valFolder then
            local gObj = valFolder:FindFirstChild("Throttle")
            local bObj = valFolder:FindFirstChild("Brake")
            local rObj = valFolder:FindFirstChild("Gear")

            if gObj then gasVal = gObj.Value end
            if bObj then brakeVal = bObj.Value end
            if rObj then gearVal = rObj.Value end
        end
    end

    -- === DIRECTION CHECK ===
    local velocity = currentSeat.AssemblyLinearVelocity
    local forwardDir = currentSeat.CFrame.LookVector
    local isMovingBackward = false

    if velocity.Magnitude > 2 and velocity:Dot(forwardDir) < 0 then
        isMovingBackward = true
    end

    -- === LOGIC TREE (FIXED) ===
    local action = "IDLE"

    if gearVal == -1 then
        action = "NATURAL REVERSE (Gear R)"

    elseif isMovingBackward then
        action = "NATURAL REVERSE (Motion)"

    elseif brakeVal > 0 then
        action = "BRAKING"

    elseif gasVal > Config.Deadzone and gearVal == 1 then
        action = "BOOSTING"

    else
        action = "IDLE"
    end

    -- === APPLY PHYSICS ===
    local att = currentSeat:FindFirstChild("J50_Att")
    local thrust = currentSeat:FindFirstChild("J50_Thrust")

    if not att then
        att = Instance.new("Attachment")
        att.Name = "J50_Att"
        att.Parent = currentSeat
    end

    if action == "BOOSTING" then
        if not thrust then
            thrust = Instance.new("VectorForce")
            thrust.Name = "J50_Thrust"
            thrust.Attachment0 = att
            thrust.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
            thrust.Parent = currentSeat
        end

        -- Only forward force
        thrust.Force = Vector3.new(0, 0, -Config.BoostPower)
    else
        -- Any reverse / brake / idle kills boost
        if thrust then thrust:Destroy() end
    end
end)
