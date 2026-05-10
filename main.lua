-- MM2 Script V4.3 - ABSOLUTE FLY & FIX AUTO
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser")
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- CONFIG SYSTEM
local filename = "thangdan_mm2_v4_3.json"
local Toggles = { ESP = false, AutoCoin = false, AutoAttack = false }

local function SaveConfig()
    if writefile then writefile(filename, HttpService:JSONEncode(Toggles)) end
end

local function LoadConfig()
    if isfile and isfile(filename) then
        local success, data = pcall(function() return HttpService:JSONDecode(readfile(filename)) end)
        if success then for i, v in pairs(data) do Toggles[i] = v end end
    end
end
LoadConfig()

-- DRAG UI
local function MakeDraggable(gui)
    local dragging, dragInput, dragStart, startPos
    gui.InputBegan:Connect(function(input)
        if input.UserInputType == Enum.UserInputType.MouseButton1 or input.UserInputType == Enum.UserInputType.Touch then
            dragging = true; dragStart = input.Position; startPos = gui.Position
            input.Changed:Connect(function() if input.UserInputState == Enum.UserInputState.End then dragging = false end end)
        end
    end)
    gui.InputChanged:Connect(function(input) if input.UserInputType == Enum.UserInputType.MouseMovement or input.UserInputType == Enum.UserInputType.Touch then dragInput = input end end)
    UserInputService.InputChanged:Connect(function(input)
        if input == dragInput and dragging then
            local delta = input.Position - dragStart
            gui.Position = UDim2.new(startPos.X.Scale, startPos.X.Offset + delta.X, startPos.Y.Scale, startPos.Y.Offset + delta.Y)
        end
    end)
end

-- UI SETUP
if CoreGui:FindFirstChild("MM2_Hub_V4_3") then CoreGui.MM2_Hub_V4_3:Destroy() end
local ScreenGui = Instance.new("ScreenGui", CoreGui); ScreenGui.Name = "MM2_Hub_V4_3"
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 250, 0, 230); MainFrame.Position = UDim2.new(0.5, -125, 0.5, -115)
MainFrame.BackgroundColor3 = Color3.fromRGB(15, 15, 15); Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 15)
MakeDraggable(MainFrame)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 45); Title.Text = "MM2 V4.3 - ABSOLUTE FLY"; Title.TextColor3 = Color3.fromRGB(222, 255, 154)
Title.BackgroundColor3 = Color3.fromRGB(30, 30, 30); Title.Font = Enum.Font.GothamBold; Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 15)

local UIList = Instance.new("UIListLayout", MainFrame); UIList.Padding = UDim.new(0, 10); UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function UpdateBtn(Btn, flag)
    Btn.Text = (flag == "ESP" and "ESP Players" or flag == "AutoCoin" and "Auto Coin" or "Auto Attack Aura") .. ": " .. (Toggles[flag] and "[ON]" or "[OFF]")
    Btn.TextColor3 = Toggles[flag] and Color3.fromRGB(154, 255, 154) or Color3.fromRGB(255, 100, 100)
    Btn.BackgroundColor3 = Toggles[flag] and Color3.fromRGB(30, 65, 30) or Color3.fromRGB(45, 45, 45)
end

local function CreateButton(name, flag, order)
    local Btn = Instance.new("TextButton", MainFrame)
    Btn.Size = UDim2.new(0, 220, 0, 42); Btn.Font = Enum.Font.GothamSemibold; Instance.new("UICorner", Btn).CornerRadius = UDim.new(0, 10)
    UpdateBtn(Btn, flag)
    Btn.MouseButton1Click:Connect(function()
        Toggles[flag] = not Toggles[flag]; UpdateBtn(Btn, flag); SaveConfig()
    end)
end
CreateButton("ESP Players", "ESP", 1); CreateButton("Auto Coin", "AutoCoin", 2); CreateButton("Auto Attack Aura", "AutoAttack", 3)

-- TWEEN ENGINE
local function TweenTo(cframe, speed)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local dist = (LocalPlayer.Character.HumanoidRootPart.Position - cframe.Position).Magnitude
        local tween = TweenService:Create(LocalPlayer.Character.HumanoidRootPart, TweenInfo.new(dist/speed, Enum.EasingStyle.Linear), {CFrame = cframe})
        tween:Play(); return tween
    end
end

-- AUTO ATTACK (FLY & SHOOT/KILL)
task.spawn(function()
    while task.wait(0.4) do
        if Toggles.AutoAttack then
            pcall(function()
                local Knife = LocalPlayer.Character:FindFirstChild("Knife") or LocalPlayer.Backpack:FindFirstChild("Knife")
                local Gun = LocalPlayer.Character:FindFirstChild("Gun") or LocalPlayer.Backpack:FindFirstChild("Gun")
                
                if Knife then
                    if Knife.Parent ~= LocalPlayer.Character then LocalPlayer.Character.Humanoid:EquipTool(Knife) end
                    for _, v in pairs(Players:GetPlayers()) do
                        if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character.Humanoid.Health > 0 then
                            local tw = TweenTo(v.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1), 35)
                            if tw then tw.Completed:Wait() end
                            VirtualUser:Button1Down(Vector2.new(0,0)); task.wait(0.05); VirtualUser:Button1Up(Vector2.new(0,0))
                            task.wait(0.2)
                        end
                    end
                elseif Gun then
                    if Gun.Parent ~= LocalPlayer.Character then LocalPlayer.Character.Humanoid:EquipTool(Gun) end
                    for _, v in pairs(Players:GetPlayers()) do
                        if v ~= LocalPlayer and v.Character and (v.Backpack:FindFirstChild("Knife") or v.Character:FindFirstChild("Knife")) and v.Character.Humanoid.Health > 0 then
                            local tw = TweenTo(v.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4), 35)
                            if tw then tw.Completed:Wait() end
                            VirtualUser:Button1Down(Vector2.new(0,0)); task.wait(0.05); VirtualUser:Button1Up(Vector2.new(0,0))
                            task.wait(0.4)
                        end
                    end
                end
            end)
        end
    end
end)

-- AUTO COIN (FLY & COLLECT)
task.spawn(function()
    while task.wait(0.5) do
        if Toggles.AutoCoin and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
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
        pcall(function()
            for _, p in pairs(Players:GetPlayers()) do
                if p ~= LocalPlayer and p.Character then
                    local h = p.Character:FindFirstChild("MM2_ESP") or Instance.new("Highlight", p.Character)
                    h.Name = "MM2_ESP"
                    h.FillColor = (p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife")) and Color3.fromRGB(255, 0, 0) or (p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun")) and Color3.fromRGB(0, 0, 255) or Color3.fromRGB(0, 255, 0)
                end
            end
        end)
    end
end)
