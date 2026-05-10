-- MM2 Script V3.9 - GLOBAL COIN SCANNER & PRO DRAG
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

local Toggles = { ESP = false, AutoCoin = false, AutoAttack = false }

-- LOGIC KÉO THẢ XỊN SÒ (DRAG FIX)
local function MakeDraggable(gui)
    local dragging, dragInput, dragStart, startPos
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
        if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end
    end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- UI SETUP
if CoreGui:FindFirstChild("MM2_Hub_Final") then CoreGui.MM2_Hub_Final:Destroy() end
local ScreenGui = Instance.new("ScreenGui", CoreGui)
ScreenGui.Name = "MM2_Hub_Final"

local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 250, 0, 230)
MainFrame.Position = UDim2.new(0.5, -125, 0.5, -115)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15)
MainFrame.BorderSizePixel = 0
Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 15)
MakeDraggable(MainFrame)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 45)
Title.Text = "MM2 V3.9 - SCANNER"
Title.TextColor3 = Color3.fromRGB(222, 255, 154)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30)
Title.Font = Enum.Font.GothamBold
Title.TextSize = 16
Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 15)

local UIList = Instance.new("UIListLayout", MainFrame)
UIList.Padding = UDim.new(0, 10)
UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center
UIList.SortOrder = Enum.SortOrder.LayoutOrder

local Spacer = Instance.new("Frame", MainFrame)
Spacer.Size = UDim2.new(1, 0, 0, 40); Spacer.BackgroundTransparency = 1; Spacer.LayoutOrder = -1

local function CreateButton(name, flag, order)
    local Btn = Instance.new("TextButton", MainFrame)
    Btn.Size = UDim2.new(0, 220, 0, 42)
    Btn.BackgroundColor3 = Color3.fromRGB(45, 45, 45)
    Btn.Text = name .. ": [OFF]"
    Btn.TextColor3 = Color3.fromRGB(255, 100, 100)
    Btn.Font = Enum.Font.GothamSemibold
    Btn.LayoutOrder = order
    Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 10)
    
    Btn.MouseButton1Click:Connect(function()
        Toggles[flag] = not Toggles[flag]
        Btn.Text = name .. ": " .. (Toggles[flag] and "[ON]" or "[OFF]")
        Btn.TextColor3 = Toggles[flag] and Color3.fromRGB(154, 255, 154) or Color3.fromRGB(255, 100, 100)
        Btn.BackgroundColor3 = Toggles[flag] and Color3.fromRGB(30, 60, 30) or Color3.fromRGB(45, 45, 45)
    end)
end

CreateButton("ESP Players", "ESP", 1)
CreateButton("Auto Coin (Super Scan)", "AutoCoin", 2)
CreateButton("Auto Attack Aura", "AutoAttack", 3)

-- SUPER SCANNER LOGIC
local function FindBestCoin()
    local bestCoin = nil
    -- Quét toàn bộ workspace để tìm vật phẩm có TouchInterest (thứ mày có thể nhặt) và tên liên quan đến Coin
    for _, v in pairs(workspace:GetDescendants()) do
        if v:IsA("TouchTransmitter") and v.Parent and (v.Parent.Name:find("Coin") or v.Parent.Name:find("Gold")) then
            bestCoin = v.Parent
            break
        end
    end
    return bestCoin
end

task.spawn(function()
    while task.wait(0.5) do
        if Toggles.AutoCoin and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            local target = FindBestCoin()
            if target and target:IsA("BasePart") then
                local dist = (LocalPlayer.Character.HumanoidRootPart.Position - target.Position).Magnitude
                -- Lướt đến (Tween)
                local tween = TweenService:Create(LocalPlayer.Character.HumanoidRootPart, TweenInfo.new(dist/22, Enum.EasingStyle.Linear), {CFrame = target.CFrame})
                tween:Play()
                tween.Completed:Wait()
                task.wait(0.5) -- Nghỉ 0.5s đúng ý mày để không bị kick
            end
        end
    end
end)

-- AUTO ATTACK (GIỮ NGUYÊN)
task.spawn(function()
    while task.wait(0.5) do
        if Toggles.AutoAttack then
            local Knife = LocalPlayer.Character:FindFirstChild("Knife") or LocalPlayer.Backpack:FindFirstChild("Knife")
            local Gun = LocalPlayer.Character:FindFirstChild("Gun") or LocalPlayer.Backpack:FindFirstChild("Gun")
            if Knife then
                if not LocalPlayer.Character:FindFirstChild("Knife") then LocalPlayer.Character.Humanoid:EquipTool(Knife) end
                for _, v in pairs(Players:GetPlayers()) do
                    if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character.Humanoid.Health > 0 then
                        LocalPlayer.Character.HumanoidRootPart.CFrame = v.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1.5)
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
                local h = p.Character:FindFirstChild("MM2_ESP") or Instance.new("Highlight", p.Character)
                h.Name = "MM2_ESP"
                h.FillColor = (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) and Color3.fromRGB(255, 0, 0) or (p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun")) and Color3.fromRGB(0, 0, 255) or Color3.fromRGB(0, 255, 0)
            end
        end
    end
end)
