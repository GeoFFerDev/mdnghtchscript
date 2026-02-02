-- === CACHED SERVICES ===
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")

local player = Players.LocalPlayer

-- === INTERNAL STATE ===
local currentSeat
local thrust, turn, attachment
local lastForce = 0
local lastTurn = 0

-- === HELPERS ===
local function lerp(a, b, t)
    return a + (b - a) * math.clamp(t, 0, 1)
end

local function cleanupForces()
    if thrust then thrust.Force = Vector3.zero end
    if turn then turn.AngularVelocity = Vector3.zero end
end

RunService.Heartbeat:Connect(function(dt)
    if not Config.Enabled then
        cleanupForces()
        currentSeat = nil
        return
    end

    local char = player.Character
    if not char then return end

    -- === SEAT RESOLUTION ===
    if not currentSeat or not currentSeat:IsDescendantOf(Workspace) then
        local humanoid = char:FindFirstChild("Humanoid")
        currentSeat = humanoid and humanoid.SeatPart
    end
    if not currentSeat then return end

    -- === ATTACHMENT / FORCES (CREATE ONCE) ===
    attachment = attachment or Instance.new("Attachment", currentSeat)
    attachment.Name = "J53_Att"

    thrust = thrust or Instance.new("VectorForce", currentSeat)
    thrust.Name = "J53_Thrust"
    thrust.Attachment0 = attachment
    thrust.RelativeTo = Enum.ActuatorRelativeTo.Attachment0

    turn = turn or Instance.new("BodyAngularVelocity", currentSeat)
    turn.Name = "J53_Turn"
    turn.MaxTorque = Vector3.new(0, currentSeat.AssemblyMass * 800, 0)

    -- === INPUT READ ===
    local gas, brake, gear, steer = 0, 0, 1, currentSeat.Steer

    local gui = player.PlayerGui:FindFirstChild("A-Chassis Interface")
    local values = gui and gui:FindFirstChild("Values")
    if values then
        gas = values.Throttle and values.Throttle.Value or gas
        brake = values.Brake and values.Brake.Value or brake
        gear = values.Gear and values.Gear.Value or gear
        steer = values.SteerT and values.SteerT.Value or steer
    end

    -- === REVERSE LOCKOUT ===
    if gear == -1 or brake > 0.1 then
        cleanupForces()
        return
    end

    -- === POWER CALCULATION ===
    if gas > Config.Deadzone then
        local mass = currentSeat.AssemblyMass
        local steerAbs = math.abs(steer)

        -- Smooth grip reduction while steering
        local grip = lerp(1, 0.65, steerAbs)

        local targetForce =
            mass * Config.PowerMultiplier * 45 * grip

        lastForce = lerp(lastForce, targetForce, dt * 6)
        thrust.Force = Vector3.new(0, 0, -lastForce)

        -- === TURN ASSIST (SCALED & SMOOTHED) ===
        if steerAbs > 0.05 then
            local speedFactor = math.clamp(currentSeat.AssemblyLinearVelocity.Magnitude / 120, 0.4, 1)
            local targetTurn = -steer * Config.TurnStrength * speedFactor

            lastTurn = lerp(lastTurn, targetTurn, dt * 8)
            turn.AngularVelocity = Vector3.new(0, lastTurn, 0)
        else
            lastTurn = lerp(lastTurn, 0, dt * 10)
            turn.AngularVelocity = Vector3.zero
        end
    else
        cleanupForces()
    end
end)
