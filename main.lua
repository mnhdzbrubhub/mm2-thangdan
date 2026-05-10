-- MM2 Script V3.1 - FIX AUTO COIN TELEPORT
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- State
local Toggles = {
    ESP = false,
    AutoCoin = false,
    AutoAttack = false
}

-- UI Setup (Giữ nguyên giao diện mượt của mày)
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2_Hub_V3_1"
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Size = UDim2.new(0, 250, 0, 220)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -110)
MainFrame.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local UICorner = Instance.new("UICorner")
UICorner.CornerRadius = UDim.new(0, 10)
UICorner.Parent = MainFrame

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 40)
Title.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
Title.Text = "MM2 V3.1 - THẰNG ĐẦN"
Title.TextColor3 = Color3.fromRGB(222, 255, 154)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 18
Title.Parent = MainFrame

local TitleCorner = Instance.new("UICorner")
TitleCorner.CornerRadius = UDim.new(0, 10)
TitleCorner.Parent = Title

local UIList = Instance.new("UIListLayout")
UIList.Parent = MainFrame
UIList.Padding = UDim.new(0, 8)
UIList.SortOrder = Enum.SortOrder.LayoutOrder
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function CreateButton(name, flag)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(0, 220, 0, 40)
    Btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Btn.Text = name .. ": [OFF]"
    Btn.TextColor3 = Color3.fromRGB(255, 100, 100)
    Btn.Font = Enum.Font.GothamSemibold
    Btn.TextSize = 14
    Btn.Parent = MainFrame
    
    local BtnCorner = Instance.new("UICorner")
    BtnCorner.CornerRadius = UDim.new(0, 8)
    BtnCorner.Parent = Btn
    
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

-- FIXED AUTO COIN (Mày sẽ bay đến chỗ xu)
task.spawn(function()
    while task.wait() do
        if Toggles.AutoCoin and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local container = workspace:FindFirstChild("Normal") and workspace.Normal:FindFirstChild("CoinContainer")
            if container then
                for _, coin in pairs(container:GetChildren()) do
                    if Toggles.AutoCoin and coin:IsA("BasePart") and coin.Name == "CoinVisual" or coin.Name == "Coin" then
                        -- Bay đến cách đồng xu một tí để nhặt cho mượt
                        LocalPlayer.Character.HumanoidRootPart.CFrame = coin.CFrame
                        task.wait(0.15) -- Delay tí cho nó giống người thật, tránh bị kick
                        if not Toggles.AutoCoin then break end
                    end
                end
            end
        end
    end
end)

-- AUTO ATTACK LOGIC (Killer/Sheriff)
task.spawn(function()
    while task.wait() do
        if Toggles.AutoAttack then
            local Knife = LocalPlayer.Character:FindFirstChild("Knife") or LocalPlayer.Backpack:FindFirstChild("Knife")
            local Gun = LocalPlayer.Character:FindFirstChild("Gun") or LocalPlayer.Backpack:FindFirstChild("Gun")
            
            if Knife then
                if not LocalPlayer.Character:FindFirstChild("Knife") then
                    LocalPlayer.Character.Humanoid:EquipTool(Knife)
                end
                for _, v in pairs(Players:GetPlayers()) do
                    if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character.Humanoid.Health > 0 then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = v.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 2)
                        Knife:Activate()
                        firetouchinterest(v.Character.HumanoidRootPart, Knife.Handle, 0)
                        firetouchinterest(v.Character.HumanoidRootPart, Knife.Handle, 1)
                    end
                end
            elseif Gun then
                if not LocalPlayer.Character:FindFirstChild("Gun") then
                    LocalPlayer.Character.Humanoid:EquipTool(Gun)
                end
                for _, v in pairs(Players:GetPlayers()) do
                    if v ~= LocalPlayer and v.Character and (v.Backpack:FindFirstChild("Knife") or v.Character:FindFirstChild("Knife")) and v.Character.Humanoid.Health > 0 then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = v.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 5)
                        Gun:Activate()
                    end
                end
            end
        end
    end
end)

-- ESP LOGIC
RunService.RenderStepped:Connect(function()
    if Toggles.ESP then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local highlight = p.Character:FindFirstChild("MM2_ESP") or Instance.new("Highlight", p.Character)
                highlight.Name = "MM2_ESP"
                if p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife") then
                    highlight.FillColor = Color3.fromRGB(255, 0, 0)
                elseif p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun") then
                    highlight.FillColor = Color3.fromRGB(0, 0, 255)
                else
                    highlight.FillColor = Color3.fromRGB(0, 255, 0)
                end
            end
        end
    end
end)

print("MM2 V3.1 Fixed - Thang Dan Hub")
