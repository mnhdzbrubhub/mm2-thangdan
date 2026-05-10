-- MM2 Script V4.8 - ANTI-VOID & LOBBY SAFE
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local RunService = game:GetService("RunService")
local LocalPlayer = Players.LocalPlayer

local Toggles = { ESP = false, AutoCoin = false, AutoAttack = false }

-- UI SETUP (GIỮ NGUYÊN)
if CoreGui:FindFirstChild("ThangDan_V48") then CoreGui.ThangDan_V48:Destroy() end
local ScreenGui = Instance.new("ScreenGui", CoreGui); ScreenGui.Name = "ThangDan_V48"
local Main = Instance.new("Frame", ScreenGui)
Main.Size = UDim2.new(0, 220, 0, 180); Main.Position = UDim2.new(0.5, -110, 0.5, -90)
Main.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Main.Active = true; Main.Draggable = true
Instance.new("UICorner", Main).CornerRadius = UDim.new(0, 10)

local Title = Instance.new("TextLabel", Main)
Title.Size = UDim2.new(1, 0, 0, 35); Title.Text = "MM2 V4.8 - ANTI VOID"; Title.TextColor3 = Color3.fromRGB(222, 255, 154)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35); Title.Font = Enum.Font.GothamBold
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 10)

local UIList = Instance.new("UIListLayout", Main); UIList.Padding = UDim.new(0, 5); UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
local s = Instance.new("Frame", Main); s.Size = UDim2.new(1,0,0,35); s.BackgroundTransparency = 1; s.LayoutOrder = -1

local function CreateBtn(name, flag)
    local Btn = Instance.new("TextButton", Main)
    Btn.Size = UDim2.new(0, 200, 0, 35); Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Btn.Text = name .. ": [OFF]"; Btn.TextColor3 = Color3.fromRGB(255, 100, 100); Btn.Font = Enum.Font.GothamSemibold
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 8)
    Btn.MouseButton1Click:Connect(function()
        Toggles[flag] = not Toggles[flag]
        Btn.Text = name .. ": " .. (Toggles[flag] and "[ON]" or "[OFF]")
        Btn.TextColor3 = Toggles[flag] and Color3.fromRGB(154, 255, 154) or Color3.fromRGB(255, 100, 100)
        Btn.BackgroundColor3 = Toggles[flag] and Color3.fromRGB(30, 60, 30) or Color3.fromRGB(45, 45, 45)
    end)
end

CreateBtn("ESP Players", "ESP")
CreateBtn("Auto Coin", "AutoCoin")
CreateBtn("Auto Kill/Sheriff", "AutoAttack")

-- CHECK XEM CÓ ĐANG TRONG TRẬN KHÔNG
local function IsInMatch()
    return workspace:FindFirstChild("Normal") ~= nil -- MM2 thường để map trong folder Normal khi bắt đầu
end

local function TweenTo(cframe, speed)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local dist = (LocalPlayer.Character.HumanoidRootPart.Position - cframe.Position).Magnitude
        local tw = TweenService:Create(LocalPlayer.Character.HumanoidRootPart, TweenInfo.new(dist/speed, Enum.EasingStyle.Linear), {CFrame = cframe})
        tw:Play(); return tw
    end
end

local function GetMyRole()
    local tool = LocalPlayer.Backpack:FindFirstChild("Knife") or LocalPlayer.Character:FindFirstChild("Knife")
    if tool then return "Killer" end
    tool = LocalPlayer.Backpack:FindFirstChild("Gun") or LocalPlayer.Character:FindFirstChild("Gun")
    if tool then return "Sheriff" end
    return "Innocent"
end

-- LOGIC AUTO ATTACK (THÊM CHECK MATCH)
task.spawn(function()
    while task.wait(0.4) do
        if Toggles.AutoAttack and IsInMatch() then
            pcall(function()
                local role = GetMyRole()
                if role ~= "Innocent" then
                    local target, dist = nil, math.huge
                    for _, v in pairs(Players:GetPlayers()) do
                        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character.Humanoid.Health > 0 then
                            local enemyKnife = v.Backpack:FindFirstChild("Knife") or v.Character:FindFirstChild("Knife")
                            if role == "Sheriff" and not enemyKnife then continue end
                            local d = (v.Character.HumanoidRootPart.Position - LocalPlayer.Character.HumanoidRootPart.Position).Magnitude
                            if d < dist then dist = d; target = v end
                        end
                    end
                    if target and IsInMatch() then -- Check lại lần nữa trước khi bay
                        local tool = (role == "Killer") and (LocalPlayer.Backpack:FindFirstChild("Knife") or LocalPlayer.Character:FindFirstChild("Knife")) or (LocalPlayer.Backpack:FindFirstChild("Gun") or LocalPlayer.Character:FindFirstChild("Gun"))
                        if tool.Parent ~= LocalPlayer.Character then LocalPlayer.Character.Humanoid:EquipTool(tool) end
                        local offset = (role == "Killer") and CFrame.new(0, 0, 1.1) or CFrame.new(0, 0, 5)
                        local tw = TweenTo(target.Character.HumanoidRootPart.CFrame * offset, 35)
                        if tw then tw.Completed:Wait() end
                        VirtualUser:Button1Down(Vector2.new(0,0)); task.wait(0.1); VirtualUser:Button1Up(Vector2.new(0,0))
                    end
                end
            end)
        end
    end
end)

-- LOGIC AUTO COIN (THÊM CHECK MATCH)
task.spawn(function()
    while task.wait(0.5) do
        if Toggles.AutoCoin and IsInMatch() and GetMyRole() == "Innocent" then
            pcall(function()
                for _, v in pairs(workspace:GetDescendants()) do
                    if Toggles.AutoCoin and IsInMatch() and GetMyRole() == "Innocent" and v:IsA("TouchTransmitter") and v.Parent and (v.Parent.Name:find("Coin") or v.Parent.Name:find("Gold")) then
                        local tw = TweenTo(v.Parent.CFrame, 22)
                        if tw then tw.Completed:Wait() end
                        task.wait(0.5)
                    end
                end
            end)
        end
    end
end)

-- ESP (LUÔN CHẠY)
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
