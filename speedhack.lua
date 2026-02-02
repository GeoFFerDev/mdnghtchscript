-- [[ JOSEPEDOV53: HANDLING ASSIST OPTIMIZED ]] --
-- Stability Fixes: Object Pooling, Caching, and Safety Clamps

local Players = game:GetService("Players")
local ReplicatedStorage = game:GetService("ReplicatedStorage")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")
local player = Players.LocalPlayer

-- === CONFIGURATION ===
local Config = {
    TrafficBlocked = false,
    BoostPower = 7000,
    PowerMultiplier = 3,
    TurnStrength = 2.5,
    Enabled = false,
    Deadzone = 0.1
}

-- === STATE & CACHE ===
local currentSeat = nil
local chassisValues = nil
local lastMass = 0

-- === OPTIMIZED PHYSICS OBJECTS (Object Pooling) ===
-- We create these once and toggle them to save memory and prevent lag spikes.
local thrustForce = Instance.new("VectorForce")
thrustForce.Name = "J53_Thrust"
local turnVelocity = Instance.new("BodyAngularVelocity")
turnVelocity.Name = "J53_Turn"
local attachment = Instance.new("Attachment")
attachment.Name = "J53_Att"

-- === DRAG FUNCTION ===
local function MakeDraggable(gui)
    local dragging, dragInput, dragStart, startPos
    local function update(input)
        local delta = input.Position - dragStart
        gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
    end
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true
            dragStart = input.Position
            startPos = gui.Position
            input.Changed:Connect(function()
                if input.UserInputState == Enum.UserInputState.End then dragging = false end
            end)
        end
    end)
    gui.InputChanged:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then
            dragInput = input
        end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then update(input) end
    end)
end

-- === TRAFFIC HOOK ===
local function InstallTrafficHook()
    local event = ReplicatedStorage:FindFirstChild("CreateNPCVehicle")
    if event then
        for _, connection in pairs(getconnections(event.OnClientEvent)) do
            local oldFunction = connection.Function
            if oldFunction then
                hookfunction(connection.Function, function(...)
                    if Config.TrafficBlocked then return end
                    return oldFunction(...)
                end)
            end
        end
    end
end
InstallTrafficHook()

-- [[ UI SECTION REMAINS THE SAME FOR COMPATIBILITY ]] --
-- (Logic for buttons would be inserted here)

-- === CLEANUP FUNCTION ===
local function ClearPhysics()
    thrustForce.Enabled = false
    turnVelocity.MaxTorque = Vector3.new(0, 0, 0)
    currentSeat = nil
    chassisValues = nil
end

-- === OPTIMIZED PHYSICS LOOP ===
RunService.Heartbeat:Connect(function()
    if not Config.Enabled then 
        ClearPhysics()
        return 
    end
    
    local char = player.Character
    if not char then return end
    
    -- 1. Optimized Car/Chassis Detection
    if not currentSeat or not currentSeat.Parent then
        local humanoid = char:FindFirstChild("Humanoid")
        if humanoid and humanoid.SeatPart then
            currentSeat = humanoid.SeatPart
            lastMass = currentSeat.AssemblyMass
            attachment.Parent = currentSeat
            thrustForce.Parent = currentSeat
            thrustForce.Attachment0 = attachment
            thrustForce.RelativeTo = Enum.ActuatorRelativeTo.Attachment0
            turnVelocity.Parent = currentSeat
            
            -- Cache the A-Chassis folder to avoid searching every frame
            local gui = player:FindFirstChild("PlayerGui")
            local interface = gui and gui:FindFirstChild("A-Chassis Interface")
            chassisValues = interface and interface:FindFirstChild("Values")
        else
            return 
        end
    end
    
    -- 2. READ VALUES (Cached)
    local gasVal = chassisValues and chassisValues:FindFirstChild("Throttle") and chassisValues.Throttle.Value or 0
    local brakeVal = chassisValues and chassisValues:FindFirstChild("Brake") and chassisValues.Brake.Value or 0
    local gearVal = chassisValues and chassisValues:FindFirstChild("Gear") and chassisValues.Gear.Value or 1
    local steerVal = (chassisValues and chassisValues:FindFirstChild("SteerT")) and chassisValues.SteerT.Value or currentSeat.Steer
    
    -- 3. LOGIC & PHYSICS
    local isReversing = (gearVal == -1) or (brakeVal > 0.1)
    
    if not isReversing and gasVal > Config.Deadzone then
        -- Forward Thrust
        local gripFactor = (math.abs(steerVal) > 0.1) and 0.7 or 1.0
        local targetForce = lastMass * Config.PowerMultiplier * 50 * gripFactor
        
        thrustForce.Enabled = true
        thrustForce.Force = Vector3.new(0, 0, -targetForce)
        
        -- Turn Assist (Angular Velocity Fix)
        if math.abs(steerVal) > 0.1 then
            -- Safety Clamp: Ensure torque doesn't exceed a stable limit for the mass
            turnVelocity.MaxTorque = Vector3.new(0, lastMass * 1000, 0) 
            turnVelocity.AngularVelocity = Vector3.new(0, -steerVal * Config.TurnStrength, 0)
        else
            turnVelocity.MaxTorque = Vector3.new(0, 0, 0)
        end
    else
        -- Idle/Reverse Safety
        thrustForce.Enabled = false
        turnVelocity.MaxTorque = Vector3.new(0, 0, 0)
    end
end)
