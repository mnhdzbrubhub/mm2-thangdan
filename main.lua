-- MM2 Script V4.4 - SNIPER ATTACK (FIX NGÁO)
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local LocalPlayer = Players.LocalPlayer

-- Config đơn giản (Không cần UI rườm rà)
local Toggles = { 
    AutoCoin = true, -- Mày thích nhặt xu
    AutoAttack = true, -- Sửa lỗi ngáo chém
    Speed = 35 -- Tốc độ bay trung bình cho Pixel 4
}

-- Hàm tìm mục tiêu gần nhất (Để không bay bừa)
local function GetClosestPlayer()
    local target = nil
    local dist = math.huge
    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character.Humanoid.Health > 0 then
            -- Nếu là Sheriff (cầm súng), chỉ bay đến thằng cầm dao (Killer)
            local isKiller = v.Backpack:FindFirstChild("Knife") or v.Character:FindFirstChild("Knife")
            local iHaveGun = LocalPlayer.Backpack:FindFirstChild("Gun") or LocalPlayer.Character:FindFirstChild("Gun")
            
            if iHaveGun and not isKiller then continue end -- Bỏ qua nếu mình cầm súng mà nó không phải killer
            
            local magnitude = (v.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if magnitude < dist then
                dist = magnitude
                target = v
            end
        end
    end
    return target
end

-- Hàm Tween mượt
local function TweenTo(cframe)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local distance = (LocalPlayer.Character.HumanoidRootPart.Position - cframe.Position).Magnitude
        local info = TweenInfo.new(distance / Toggles.Speed, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(LocalPlayer.Character.HumanoidRootPart, info, {CFrame = cframe})
        tween:Play()
        return tween
    end
end

-- Logic Tấn Công Sniper
task.spawn(function()
    while task.wait(0.5) do -- Cooldown 0.5s cho an toàn, tránh bị kick
        if Toggles.AutoAttack and LocalPlayer.Character then
            local target = GetClosestPlayer()
            if target then
                local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                if tool and (tool.Name == "Knife" or tool.Name == "Gun") then
                    if tool.Parent ~= LocalPlayer.Character then LocalPlayer.Character.Humanoid:EquipTool(tool) end
                    
                    -- Bay đến mục tiêu cụ thể
                    local offset = tool.Name == "Knife" and CFrame.new(0, 0, 1.2) or CFrame.new(0, 0, 5)
                    local tw = TweenTo(target.Character.HumanoidRootPart.CFrame * offset)
                    if tw then tw.Completed:Wait() end
                    
                    -- Click chém/bắn
                    VirtualUser:Button1Down(Vector2.new(0,0))
                    task.wait(0.1)
                    VirtualUser:Button1Up(Vector2.new(0,0))
                end
            end
        end
    end
end)

-- Logic Nhặt Xu (Dùng scanner cũ nhưng tối ưu)
task.spawn(function()
    while task.wait(0.5) do
        if Toggles.AutoCoin and LocalPlayer.Character then
            for _, v in pairs(workspace:GetDescendants()) do
                if Toggles.AutoCoin and v:IsA("TouchTransmitter") and v.Parent and (v.Parent.Name:find("Coin") or v.Parent.Name:find("Gold")) then
                    local tw = TweenTo(v.Parent.CFrame)
                    if tw then tw.Completed:Wait() end
                    task.wait(0.5) -- Cooldown 0.5s
                end
            end
        end
    end
end)

print("MM2 V4.4 Sniper Loaded - No UI, No Ngáo")
