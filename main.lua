-- MM2 Script V3.5 - AUTO EXECUTE READY (0.5S SAFE)
repeat task.wait() until game:IsLoaded() -- Đảm bảo game load xong mới chạy

local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Khởi tạo State (Mặc định OFF để an toàn, mày tự bật sau khi vào game)
local Toggles = {
    ESP = false,
    AutoCoin = false,
    AutoAttack = false
}

-- UI Setup (Bo góc Gen Z cho bớt phèn)
if CoreGui:FindFirstChild("MM2_Hub_Auto") then CoreGui.MM2_Hub_Auto:Destroy() end

local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2_Hub_Auto"
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 220)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -110)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.Parent = ScreenGui
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.Text = "MM2 AUTO - THẰNG ĐẦN"
Title.TextColor3 = Color3.fromRGB(222, 255, 154)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.Parent = MainFrame
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 10)

local UIList = Instance.new("UIListLayout", MainFrame)
UIList.Padding = UDim.new(0, 8)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function CreateButton(name, flag)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 220, 0, 40)
    Btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Btn.Text = name .. ": [OFF]"
    Btn.TextColor3 = Color3.fromRGB(255, 100, 100)
    Btn.Parent = MainFrame
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

-- Vòng lặp nhặt xu an toàn (0.5s Cooldown)
task.spawn(function()
    while true do
        task.wait(0.5)
        if Toggles.AutoCoin and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            for _, v in pairs(workspace:GetDescendants()) do
                if Toggles.AutoCoin and v:IsA("BasePart") and (v.Name == "CoinVisual" or v.Name == "Coin") then
                    LocalPlayer.Character.HumanoidRootPart.CFrame = v.CFrame
                    task.wait(0.5)
                    if not Toggles.AutoCoin then break end
                end
            end
        end
    end
end)

-- Vòng lặp tấn công an toàn
task.spawn(function()
    while true do
        task.wait(0.5)
        if Toggles.AutoAttack then
            local Knife = LocalPlayer.Character:FindFirstChild("Knife") or LocalPlayer.Backpack:FindFirstChild("Knife")
            local Gun = LocalPlayer.Character:FindFirstChild("Gun") or LocalPlayer.Backpack:FindFirstChild("Gun")
            
            if Knife then
                if not LocalPlayer.Character:FindFirstChild("Knife") then LocalPlayer.Character.Humanoid:EquipTool(Knife) end
                for _, v in pairs(Players:GetPlayers()) do
                    if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character.Humanoid.Health > 0 then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = v.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2)
                        Knife:Activate()
                        break 
                    end
                end
            elseif Gun then
                if not LocalPlayer.Character:FindFirstChild("Gun") then LocalPlayer.Character.Humanoid:EquipTool(Gun) end
                for _, v in pairs(Players:GetPlayers()) do
                    if v ~= LocalPlayer and v.Character and (v.Backpack:FindFirstChild("Knife") or v.Character:FindFirstChild("Knife")) and v.Character.Humanoid.Health > 0 then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = v.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
                        Gun:Activate()
                        break
                    end
                end
            end
        end
    end
end)

-- ESP
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
