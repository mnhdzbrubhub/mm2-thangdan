-- MM2 Script V4.2 - VIRTUAL CLICK ATTACK & AUTO SAVE
repeat task.wait() until game:IsLoaded()

local Players = game:GetService("Players")
local TweenService = game:GetService("TweenService")
local RunService = game:GetService("RunService")
local UserInputService = game:GetService("UserInputService")
local VirtualUser = game:GetService("VirtualUser") -- Dùng để giả lập click
local CoreGui = game:GetService("CoreGui")
local HttpService = game:GetService("HttpService")
local LocalPlayer = Players.LocalPlayer

-- FILE CONFIG
local filename = "thangdan_mm2_v4_2.json"
local Toggles = { ESP = false, AutoCoin = false, AutoAttack = false }

local function SaveConfig()
    if writefile then writefile(filename, HttpService:JSONEncode(Toggles)) end
end

local function LoadConfig()
    if isfile and isfile(filename) then
        local data = HttpService:JSONDecode(readfile(filename))
        for i, v in pairs(data) do Toggles[i] = v end
    end
end
LoadConfig()

-- DRAG UI LOGIC
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
if CoreGui:FindFirstChild("MM2_Hub_V4_2") then CoreGui.MM2_Hub_V4_2:Destroy() end
local ScreenGui = Instance.new("ScreenGui", CoreGui); ScreenGui.Name = "MM2_Hub_V4_2"
local MainFrame = Instance.new("Frame", ScreenGui)
MainFrame.Size = UDim2.new(0, 250, 0, 230); MainFrame.Position = UDim2.new(0.5, -125, 0.5, -115)
MainFrame.BackgroundColor3 = Color3.fromRGB(20, 20, 20); Instance.new("UICorner", MainFrame).CornerRadius = UDim.new(0, 15)
MakeDraggable(MainFrame)

local Title = Instance.new("TextLabel", MainFrame)
Title.Size = UDim2.new(1, 0, 0, 45); Title.Text = "MM2 V4.2 - AUTO CLICK"; Title.TextColor3 = Color3.fromRGB(222, 255, 154)
Title.BackgroundColor3 = Color3.fromRGB(35, 35, 35); Title.Font = Enum.Font.GothamBold; Instance.new("UICorner", Title).CornerRadius = UDim.new(0, 15)

local UIList = Instance.new("UIListLayout", MainFrame); UIList.Padding = UDim.new(0, 10); UIList.HorizontalAlignment = Enum.HorizontalAlignment.Center

local function UpdateBtn(Btn, flag)
    Btn.Text = (flag == "ESP" and "ESP Players" or flag == "AutoCoin" and "Auto Coin" or "Auto Attack Aura") .. ": " .. (Toggles[flag] and "[ON]" or "[OFF]")
    Btn.TextColor3 = Toggles[flag] and Color3.fromRGB(154, 255, 154) or Color3.fromRGB(255, 100, 100)
    Btn.BackgroundColor3 = Toggles[flag] and Color3.fromRGB(40, 75, 40) or Color3.fromRGB(55, 55, 55)
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

-- HÀM TWEEN
local function TweenTo(cframe, speed)
    if LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
        local dist = (LocalPlayer.Character.HumanoidRootPart.Position - cframe.Position).Magnitude
        local tween = TweenService:Create(LocalPlayer.Character.HumanoidRootPart, TweenInfo.new(dist/speed, Enum.EasingStyle.Linear), {CFrame = cframe})
        tween:Play(); return tween
    end
end

-- AUTO ATTACK FIX (VIRTUAL CLICK)
task.spawn(function()
    while task.wait(0.4) do
        if Toggles.AutoAttack then
            local Knife = LocalPlayer.Character:FindFirstChild("Knife") or LocalPlayer.Backpack:FindFirstChild("Knife")
            local Gun = LocalPlayer.Character:FindFirstChild("Gun") or LocalPlayer.Backpack:FindFirstChild("Gun")
            
            if Knife then
                if Knife.Parent ~= LocalPlayer.Character then LocalPlayer.Character.Humanoid:EquipTool(Knife) end
                for _, v in pairs(Players:GetPlayers()) do
                    if v ~= LocalPlayer and v.Character and v.Character:FindFirstChild("HumanoidRootPart") and v.Character.Humanoid.Health > 0 then
                        local tw = TweenTo(v.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 1.1), 35)
                        if tw then tw.Completed:Wait() end
                        
                        -- Giả lập click chuột/chạm màn hình để chém
                        VirtualUser:Button1Down(Vector2.new(0,0))
                        task.wait(0.1)
                        VirtualUser:Button1Up(Vector2.new(0,0))
                        
                        task.wait(0.3)
                    end
                end
            elseif Gun then
                if Gun.Parent ~= LocalPlayer.Character then LocalPlayer.Character.Humanoid:EquipTool(Gun) end
                for _, v in pairs(Players:GetPlayers()) do
                    if v ~= LocalPlayer and v.Character and (v.Backpack:FindFirstChild("Knife") or v.Character:FindFirstChild("Knife")) and v.Character.Humanoid.Health > 0 then
                        local tw = TweenTo(v.Character.HumanoidRootPart.CFrame * CFrame.new(0, 0, 4.5), 35)
                        if tw then tw.Completed:Wait() end
                        
                        -- Giả lập click để bắn
                        VirtualUser:Button1Down(Vector2.new(0,0))
                        task.wait(0.1)
                        VirtualUser:Button1Up(Vector2.new(0,0))
                        
                        task.wait(0.5)
                    end
                end
            end
        end
    end
end)

-- AUTO COIN (SCANNER)
task.spawn(function()
    while task.wait(0.6) do
        if Toggles.AutoCoin and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
            for _, v in pairs(workspace:GetDescendants()) do
                if Toggles.AutoCoin and v:IsA("TouchTransmitter") and v.Parent and (v.Parent.Name:find("Coin") or v.Parent.Name:find("Gold")) then
                    local tw = TweenTo(v.Parent.CFrame, 22)
                    if tw then tw.Completed:Wait() end
                    task.wait(0.5)
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
