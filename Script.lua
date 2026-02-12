local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Workspace = game:GetService("Workspace")
local UserInputService = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera = Workspace.CurrentCamera

local FOVRadius = 120
local TargetPart = "Head"
local AimbotEnabled = true
local ESPEnabled = true
local TeamCheck = true 
local LegitMode = false
local Smoothness = 0.15 
local SpeedEnabled = false
local WalkSpeedValue = 50

local ActiveNotifications = {}

local function ShowNotification(msg)
    local Sound = Instance.new("Sound")
    Sound.SoundId = "rbxassetid://4590662766"
    Sound.Volume = 0.6
    Sound.Parent = game:GetService("CoreGui")
    Sound:Play()
    game:GetService("Debris"):AddItem(Sound, 2)

    local Notification = Instance.new("ScreenGui")
    Notification.Parent = game.CoreGui
    
    local TextLabel = Instance.new("TextLabel")
    TextLabel.Parent = Notification
    TextLabel.BackgroundTransparency = 0.4
    TextLabel.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
    TextLabel.TextColor3 = Color3.fromRGB(255, 255, 255)
    TextLabel.Size = UDim2.new(0, 260, 0, 45)
    
    local YOffset = 40 + (#ActiveNotifications * 50)
    TextLabel.Position = UDim2.new(1, -270, 0, YOffset)
    TextLabel.Text = "  " .. msg
    TextLabel.Font = Enum.Font.GothamBold
    TextLabel.TextSize = 14
    TextLabel.TextXAlignment = Enum.TextXAlignment.Left
    
    local Corner = Instance.new("UICorner")
    Corner.CornerRadius = UDim.new(0, 10)
    Corner.Parent = TextLabel
    
    table.insert(ActiveNotifications, Notification)

    task.spawn(function()
        task.wait(3)
        if TextLabel then
            for i = 0.4, 1, 0.05 do
                TextLabel.BackgroundTransparency = i
                TextLabel.TextTransparency = (i-0.4)*2
                task.wait(0.04)
            end
        end
        for i, v in ipairs(ActiveNotifications) do
            if v == Notification then table.remove(ActiveNotifications, i) break end
        end
        Notification:Destroy()
    end)
end

local FOVCircle = Drawing.new("Circle")
FOVCircle.Thickness = 2
FOVCircle.Color = Color3.fromRGB(170, 0, 255)
FOVCircle.Transparency = 0.8
FOVCircle.Filled = false
FOVCircle.Radius = FOVRadius
FOVCircle.Visible = true

local ESPObjects = {}
local SkeletonESP = {}
local Bones = {
    {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
    {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
    {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
    {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
    {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
}

local function CreateESP(player)
    if player == LocalPlayer then return end
    local text = Drawing.new("Text")
    text.Size = 16
    text.Color = Color3.fromRGB(170, 0, 255)
    text.Center = true
    text.Outline = true
    ESPObjects[player] = text
    
    SkeletonESP[player] = {}
    for _, bone in pairs(Bones) do
        local line = Drawing.new("Line")
        line.Thickness = 1.8
        line.Color = Color3.fromRGB(170, 0, 255)
        table.insert(SkeletonESP[player], {bone[1], bone[2], line})
    end
end

for _, p in pairs(Players:GetPlayers()) do CreateESP(p) end
Players.PlayerAdded:Connect(CreateESP)

UserInputService.InputBegan:Connect(function(input, gameProcessed)
    if gameProcessed then return end
    
    if input.KeyCode == Enum.KeyCode.Home then
        AimbotEnabled = not AimbotEnabled
        ESPEnabled = not ESPEnabled
        FOVCircle.Visible = AimbotEnabled
        ShowNotification(AimbotEnabled and "SISTEMA: ATIVADO ✅" or "SISTEMA: DESATIVADO ❌")
    elseif input.KeyCode == Enum.KeyCode.T then
        LegitMode = false
        FOVCircle.Color = Color3.fromRGB(170, 0, 255)
        ShowNotification("MODO AIMBOT BRUTO ATIVADO 🔴")
    elseif input.KeyCode == Enum.KeyCode.Y then
        LegitMode = true
        FOVCircle.Color = Color3.fromRGB(0, 255, 120)
        ShowNotification("MODO LEGIT ATIVADO 🟢")
    elseif input.KeyCode == Enum.KeyCode.Delete then
        SpeedEnabled = not SpeedEnabled
        ShowNotification(SpeedEnabled and "ULTRA VELOCIDADE: ON ⚡" or "ULTRA VELOCIDADE: OFF 🛑")
    elseif input.KeyCode == Enum.KeyCode.RightAlt then
        WalkSpeedValue = WalkSpeedValue + 10
        ShowNotification("VELOCIDADE AUMENTADA: " .. WalkSpeedValue)
    elseif input.KeyCode == Enum.KeyCode.QuotedDouble or input.KeyCode == Enum.KeyCode.Semicolon or input.KeyCode == Enum.KeyCode.Hash then
        WalkSpeedValue = math.max(16, WalkSpeedValue - 10)
        ShowNotification("VELOCIDADE DIMINUÍDA: " .. WalkSpeedValue)
    elseif input.KeyCode == Enum.KeyCode.PageUp then
        FOVRadius = math.min(800, FOVRadius + 20)
        FOVCircle.Radius = FOVRadius
        ShowNotification("FOV: " .. FOVRadius)
    elseif input.KeyCode == Enum.KeyCode.PageDown then
        FOVRadius = math.max(10, FOVRadius - 20)
        FOVCircle.Radius = FOVRadius
        ShowNotification("FOV: " .. FOVRadius)
    elseif input.KeyCode == Enum.KeyCode.J then
        TeamCheck = false
        ShowNotification("TEAM AIMBOT: LIGADO 🏳️‍🌈")
    elseif input.KeyCode == Enum.KeyCode.K then
        TeamCheck = true
        ShowNotification("TEAM AIMBOT: DESATIVADO 🛡️")
    end
end)

RunService.RenderStepped:Connect(function()
    FOVCircle.Position = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)

    if SpeedEnabled and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = WalkSpeedValue
    elseif LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("Humanoid") then
        LocalPlayer.Character.Humanoid.WalkSpeed = 16
    end

    if AimbotEnabled then
        local function IsVisible(char)
            local part = char:FindFirstChild(TargetPart)
            if not part then return false end
            local params = RaycastParams.new()
            params.FilterType = Enum.RaycastFilterType.Exclude
            params.FilterDescendantsInstances = {LocalPlayer.Character, char}
            local result = Workspace:Raycast(Camera.CFrame.Position, part.Position - Camera.CFrame.Position, params)
            return result == nil
        end

        local function GetClosest()
            local closest = nil local shortest = FOVRadius local screenCenter = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
            for _, p in pairs(Players:GetPlayers()) do
                local char = p.Character
                local hum = char and char:FindFirstChildOfClass("Humanoid")
                
                if p ~= LocalPlayer and (not TeamCheck or p.Team ~= LocalPlayer.Team) and char and char:FindFirstChild(TargetPart) and hum and hum.Health > 0 and IsVisible(char) then
                    local pos, onScreen = Camera:WorldToViewportPoint(char[TargetPart].Position)
                    if onScreen then
                        local dist = (Vector2.new(pos.X, pos.Y) - screenCenter).Magnitude
                        if dist < shortest then shortest = dist closest = p end
                    end
                end
            end
            return closest
        end
        
        local target = GetClosest()
        if target then
            local targetPos = target.Character[TargetPart].Position
            if LegitMode then
                Camera.CFrame = Camera.CFrame:Lerp(CFrame.new(Camera.CFrame.Position, targetPos), Smoothness)
            else
                Camera.CFrame = CFrame.new(Camera.CFrame.Position, targetPos)
            end
        end
    end

    for player, bones in pairs(SkeletonESP) do
        local char = player.Character
        local text = ESPObjects[player]
        if ESPEnabled and char and char:FindFirstChild("Humanoid") and char.Humanoid.Health > 0 and (not TeamCheck or player.Team ~= LocalPlayer.Team) then
            local hrp = char:FindFirstChild("HumanoidRootPart")
            if hrp then
                local pos, onScreen = Camera:WorldToViewportPoint(hrp.Position)
                text.Visible = onScreen
                if onScreen then
                    text.Position = Vector2.new(pos.X, pos.Y - 35)
                    text.Text = player.Name
                end
            end
            for _, data in pairs(bones) do
                local p1, p2, line = char:FindFirstChild(data[1]), char:FindFirstChild(data[2]), data[3]
                if p1 and p2 then
                    local a, o1 = Camera:WorldToViewportPoint(p1.Position)
                    local b, o2 = Camera:WorldToViewportPoint(p2.Position)
                    line.Visible = o1 and o2
                    if line.Visible then line.From = Vector2.new(a.X, a.Y) line.To = Vector2.new(b.X, b.Y) end
                else line.Visible = false end
            end
        else
            text.Visible = false
            for _, d in pairs(bones) do d[3].Visible = false end
        end
    end
end)
