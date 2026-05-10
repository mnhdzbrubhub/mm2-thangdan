-- MM2 Script V4.6 - CLASSIC UI & SNIPER LOGIC
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- Khởi tạo trạng thái
local Toggles = { ESP = false, AutoCoin = false, AutoAttack = false }

-- UI SETUP (CODE THUẦN - SIÊU NHẸ)
if CoreGui:FindFirstChild("ThangDan_Classic") then CoreGui.ThangDan_Classic:Destroy() end
local ScreenGui = Instance.new("ScreenGui", CoreGui); ScreenGui.Name = "ThangDan_Classic"

local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 220, 0, 180)
Main.Position = UDim2.new(0.5, -110, 0.5, -90)
Main.BackgroundColor3 = Color3.fromRGB(25, 25, 25)
Main.Active = true
Main.Draggable = true -- Cho mày kéo thoải mái
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 35)
Title.Text = "MM2 V4.6 - THẰNG ĐẦN"
Title.TextColor3 = Color3.fromRGB(222, 255, 154)
Title.BackgroundColor3 = Color3.fromRGB(40, 40, 40)
Title.Font = Enum.Font.GothamBold
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 10)

local UIList = Instance.new("UIListLayout", Main)
UIList.Padding = UDim.new(0, 5); UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function CreateBtn(name, flag)
    local Btn = Instance.new("TextButton", Main)
    Btn.Size = UDim2.new(0, 200, 0, 35)
    Btn.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
    Btn.Text = name .. ": [OFF]"
    Btn.TextColor3 = Color3.fromRGB(255, 100, 100)
    Btn.Font = Enum.Font.GothamSemibold
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
    
    Btn.MouseButton1Click:Connect(function()
        Toggles[flag] = not Toggles[flag]
        Btn.Text = name .. ": " .. (Toggles[flag] and "[ON]" or "[OFF]")
        Btn.TextColor3 = Toggles[flag] and Color3.fromRGB(154, 255, 154) or Color3.fromRGB(255, 100, 100)
        Btn.BackgroundColor3 = Toggles[flag] and Color3.fromRGB(40, 70, 40) or Color3.fromRGB(50, 50, 50)
    end)
end

-- Spacer cho UI đẹp
local s = Instance.new("Frame", Main); s.Size = UDim2.new(1,0,0,35); s.BackgroundTransparency = 1; s.LayoutOrder = -1

CreateBtn("ESP Players", "ESP")
CreateBtn("Auto Coin", "AutoCoin")
CreateBtn("Auto Kill/Sheriff", "AutoAttack")

-- LOGIC TWEEN
local function TweenTo(cframe, speed)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local dist = (LocalPlayer.Character.HumanoidRootPart.Position - cframe.Position).Magnitude
        local tw = TweenService:Create(LocalPlayer.Character.HumanoidRootPart, TweenInfo.new(dist/speed, Enum.EasingStyle.Linear), {CFrame = cframe})
        tw:Play()
        return tw
    end
end

-- LOGIC SNIPER (CHỐNG NGÁO)
local function GetBestTarget()
    local target, dist = nil, math.huge
    local myKnife = LocalPlayer.Backpack:FindFirstChild("Knife") or LocalPlayer.Character:FindFirstChild("Knife")
    local myGun = LocalPlayer.Backpack:FindFirstChild("Gun") or LocalPlayer.Character:FindFirstChild("Gun")

    for _, v in pairs(Players:GetPlayers()) do
        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character.Humanoid.Health > 0 then
            local enemyKnife = v.Backpack:FindFirstChild("Knife") or v.Character:FindFirstChild("Knife")
            if myGun and not enemyKnife then continue end -- Sheriff chỉ bắn thằng cầm dao
            
            local d = (v.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
            if d < dist then dist = d; target = v end
        end
    end
    return target
end

-- VÒNG LẶP CHIẾN ĐẤU
task.spawn(function()
    while task.wait(0.5) do
        if Toggles.AutoAttack and LocalPlayer.Character then
            pcall(function()
                local target = GetBestTarget()
                local tool = LocalPlayer.Character:FindFirstChildOfClass("Tool") or LocalPlayer.Backpack:FindFirstChildOfClass("Tool")
                if target and tool and (tool.Name == "Knife" or tool.Name == "Gun") then
                    if tool.Parent ~= LocalPlayer.Character then LocalPlayer.Character.Humanoid:EquipTool(tool) end
                    local offset = (tool.Name == "Knife") and CFrame.new(0, 0, 1.2) or CFrame.new(0, 0, 5)
                    local tw = TweenTo(target.Character.HumanoidRootPart.CFrame * offset, 35)
                    if tw then tw.Completed:Wait() end
                    VirtualUser:Button1Down(Vector2.new(0,0)); task.wait(0.1); VirtualUser:Button1Up(Vector2.new(0,0))
                end
            end)
        end
    end
end)

-- VÒNG LẶP NHẶT XU
task.spawn(function()
    while task.wait(0.5) do
        if Toggles.AutoCoin and LocalPlayer.Character then
            pcall(function()
                for _, v in pairs(workspace:GetDescendants()) do
                    if Toggles.AutoCoin and v:IsA("TouchTransmitter") and v.Parent and (v.Parent.Name:find("Coin") or v.Parent.Name:find("Gold")) then
                        local tw = TweenTo(v.Parent.CFrame, 22)
                        if tw then tw.Completed:Wait() end
                        task.wait(0.5)
                    end
                end
            end)
        end
    end
end)

-- ESP
RunService.RenderStepped:Connect(function()
    if Toggles.ESP then
        for _, p in pairs(Players:GetPlayers()) do
            if p ~= LocalPlayer and p.Character then
                local h = p.Character:FindFirstChild("MM2_ESP") or Instance.new("Highlight", p.Character)
                h.Name = "MM2_ESP"
                h.FillColor = (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) and Color3.fromRGB(255, 0, 0) or (p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun")) and Color3.fromRGB(0, 0, 255) or Color3.fromRGB(0, 255, 0)
            end
        end
    end
end)
