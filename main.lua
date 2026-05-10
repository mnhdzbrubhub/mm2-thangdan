-- MM2 Script V3.6 - TWEEN MODE (ANTI-KICK)
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local Toggles = {
    ESP = false,
    AutoCoin = false,
    AutoAttack = false
}

-- UI Setup (Vẫn mượt cho Pixel 4)
if CoreGui:FindFirstChild("MM2_Hub_Tween") then CoreGui.MM2_Hub_Tween:Destroy() end
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "MM2_Hub_Tween"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 250, 0, 220)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -110)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "MM2 TWEEN - THẰNG ĐẦN"
Title.TextColor3 = Color3.fromRGB(222, 255, 154)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 10)

local UIList = Instance.new("UIListLayout", MainFrame)
UIList.Padding = UDim.new(0, 8)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function CreateButton(name, flag)
    local Btn = Instance.new("TextButton", MainFrame)
    Btn.Size = UDim2.new(0, 220, 0, 40)
    Btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Btn.Text = name .. ": [OFF]"
    Btn.TextColor3 = Color3.fromRGB(255, 100, 100)
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
    
    Btn.MouseButton1Click:Connect(function()
        Toggles[flag] = not Toggles[flag]
        Btn.Text = name .. ": " .. (Toggles[flag] and "[ON]" or "[OFF]")
        Btn.TextColor3 = Toggles[flag] and Color3.fromRGB(154, 255, 154) or Color3.fromRGB(255, 100, 100)
        Btn.BackgroundColor3 = Toggles[flag] and Color3.fromRGB(40, 80, 40) or Color3.fromRGB(60, 60, 60)
    end)
end

CreateButton("ESP Players", "ESP")
CreateButton("Auto Collect Coins", "AutoCoin")
CreateButton("Auto Kill/Shoot Aura", "AutoAttack")

-- Hàm Tween mượt mà
local function TweenTo(cframe, speed)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local distance = (LocalPlayer.Character.HumanoidRootPart.Position - cframe.Position).Magnitude
        local info = TweenInfo.new(distance / speed, Enum.EasingStyle.Linear)
        local tween = TweenService:Create(LocalPlayer.Character.HumanoidRootPart, info, {CFrame = cframe})
        tween:Play()
        return tween
    end
end

-- TWEEN AUTO COIN (Tốc độ 25 để an toàn)
task.spawn(function()
    while true do
        task.wait(0.1)
        if Toggles.AutoCoin then
            for _, v in pairs(workspace:GetDescendants()) do
                if Toggles.AutoCoin and v:IsA("BasePart") and (v.Name == "CoinVisual" or v.Name == "Coin") then
                    local tween = TweenTo(v.CFrame, 25) -- Tốc độ lướt là 25 (vừa phải)
                    if tween then tween.Completed:Wait() end
                    task.wait(0.2) -- Nghỉ tí cho đỡ kick
                    if not Toggles.AutoCoin then break end
                end
            end
        end
    end
end)

-- TWEEN ATTACK (Lướt đến mục tiêu)
task.spawn(function()
    while true do
        task.wait(0.1)
        if Toggles.AutoAttack then
            local Knife = LocalPlayer.Character:FindFirstChild("Knife") or LocalPlayer.Backpack:FindFirstChild("Knife")
            local Gun = LocalPlayer.Character:FindFirstChild("Gun") or LocalPlayer.Backpack:FindFirstChild("Gun")
            
            if Knife then
                if not LocalPlayer.Character:FindFirstChild("Knife") then LocalPlayer.Character.Humanoid:EquipTool(Knife) end
                for _, v in pairs(Players:GetPlayers()) do
                    if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character.Humanoid.Health > 0 then
                        local tween = TweenTo(v.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1.5), 35)
                        if tween then tween.Completed:Wait() end
                        Knife:Activate()
                        task.wait(0.5)
                        break
                    end
                end
            elseif Gun then
                if not LocalPlayer.Character:FindFirstChild("Gun") then LocalPlayer.Character.Humanoid:EquipTool(Gun) end
                for _, v in pairs(Players:GetPlayers()) do
                    if v ~= LocalPlayer and v.Character and (v.Backpack:FindFirstChild("Knife") or v.Character:FindFirstChild("Knife")) and v.Character.Humanoid.Health > 0 then
                        local tween = TweenTo(v.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5), 35)
                        if tween then tween.Completed:Wait() end
                        Gun:Activate()
                        task.wait(0.5)
                        break
                    end
                end
            end
        end
    end
end)

-- ESP (Giữ nguyên)
RunService.RenderStepped:Connect(function()
    if Toggles.ESP then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local highlight = p.Character:FindFirstChild("MM2_ESP") or Instance.new("Highlight", p.Character)
                highlight.Name = "MM2_ESP"
                highlight.FillColor = (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) and Color3.fromRGB(255, 0, 0) or (p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun")) and Color3.fromRGB(0, 0, 255) or Color3.fromRGB(0, 255, 0)
            end
        end
    end
end)
