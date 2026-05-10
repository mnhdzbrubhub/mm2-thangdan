-- MM2 Script V4.5 - GOD MODE (AUTO START - NO UI)
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

print("THANG DAN HUB V4.5 - DANG KICH HOAT...")

-- HAM TWEEN (LUOT MUOT)
local function TweenTo(cframe, speed)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local dist = (LocalPlayer.Character.HumanoidRootPart.Position - cframe.Position).Magnitude
        local info = TweenInfo.new(dist/speed, Enum.EasingStyle.Linear)
        local tw = TweenService:Create(LocalPlayer.Character.HumanoidRootPart, info, {CFrame = cframe})
        tw:Play()
        return tw
    end
end

-- LOGIC TIM MUC TIEU (FIX NGÁO TUYET DOI)
local function GetTarget()
    local target = nil
    local dist = math.huge
    
    local myKnife = LocalPlayer.Backpack:FindFirstChild("Knife") or LocalPlayer.Character:FindFirstChild("Knife")
    local myGun = LocalPlayer.Backpack:FindFirstChild("Gun") or LocalPlayer.Character:FindFirstChild("Gun")

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character.Humanoid.Health > 0 then
            local enemyHasKnife = v.Backpack:FindFirstChild("Knife") or v.Character:FindFirstChild("Knife")
            
            -- Neu minh cam súng: Chỉ target thang cam dao
            if myGun and not enemyHasKnife then continue end
            
            local d = (v.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if d < dist then
                dist = d
                target = v
            end
        end
    end
    return target
end

-- VONG LAP AUTO ATTACK (TU DONG CHAY)
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            local target = GetTarget()
            local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
            
            if target and tool and (tool.Name == "Knife" or tool.Name == "Gun") then
                -- Tu trang bi
                if tool.Parent ~= LocalPlayer.Character then LocalPlayer.Character.Humanoid:EquipTool(tool) end
                
                -- Bay den
                local offset = (tool.Name == "Knife") and CFrame.new(0, 0, 1.1) or CFrame.new(0, 0, 5)
                local tw = TweenTo(target.Character.HumanoidRootPart.CFrame * offset, 35)
                if tw then tw.Completed:Wait() end
                
                -- Tu dong click
                VirtualUser:Button1Down(Vector2.new(0,0))
                task.wait(0.1)
                VirtualUser:Button1Up(Vector2.new(0,0))
            end
        end)
    end
end)

-- VONG LAP AUTO COIN (TU DONG CHAY)
task.spawn(function()
    while task.wait(0.5) do
        pcall(function()
            for _, v in pairs(workspace:GetDescendants()) do
                if v:IsA("TouchTransmitter") and v.Parent and (v.Parent.Name:find("Coin") or v.Parent.Name:find("Gold")) then
                    local tw = TweenTo(v.Parent.CFrame, 22)
                    if tw then tw.Completed:Wait() end
                    task.wait(0.5)
                end
            end
        end)
    end
end)

warn("MM2 V4.5 - DA BAT AUTO KILL VA COIN!")
