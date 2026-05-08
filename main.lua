-- MM2 Script with UI for "thằng đần"
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local CoreGui = game:GetService("CoreGui")
local LocalPlayer = Players.LocalPlayer

-- State
local Toggles = {
    ESP = false,
    AutoCoin = false
}

-- UI Setup
local ScreenGui = Instance.new("ScreenGui")
ScreenGui.Name = "MM2_Hub"
ScreenGui.Parent = CoreGui

local MainFrame = Instance.new("Frame")
MainFrame.Name = "MainFrame"
MainFrame.Size = UDim2.new(0, 200, 0, 150)
MainFrame.Position = UDim2.new(0.5, -100, 0.5, -75)
MainFrame.BackgroundColor3 = Color3.fromRGB(35, 35, 35)
MainFrame.BorderSizePixel = 0
MainFrame.Active = true
MainFrame.Draggable = true
MainFrame.Parent = ScreenGui

local Title = Instance.new("TextLabel")
Title.Size = UDim2.new(1, 0, 0, 30)
Title.BackgroundColor3 = Color3.fromRGB(50, 50, 50)
Title.Text = "MM2 HUB - THẰNG ĐẦN"
Title.TextColor3 = Color3.fromRGB(255, 255, 255)
Title.Font = Enum.Font.SourceSansBold
Title.Parent = MainFrame

local UIList = Instance.new("UIListLayout")
UIList.Parent = MainFrame
UIList.Padding = UDim.new(0, 5)
UIList.SortOrder = Enum.SortOrder.LayoutOrder

-- Button Template
local function CreateButton(name, flag)
    local Btn = Instance.new("TextButton")
    Btn.Size = UDim2.new(1, -10, 0, 35)
    Btn.BackgroundColor3 = Color3.fromRGB(60, 60, 60)
    Btn.Text = name .. ": [OFF]"
    Btn.TextColor3 = Color3.fromRGB(255, 0, 0)
    Btn.Font = Enum.Font.SourceSans
    Btn.TextSize = 14
    Btn.Parent = MainFrame
    
    Btn.MouseButton1Click:Connect(function()
        Toggles[flag] = not Toggles[flag]
        Btn.Text = name .. ": " .. (Toggles[flag] and "[ON]" or "[OFF]")
        Btn.TextColor3 = Toggles[flag] and Color3.fromRGB(0, 255, 0) or Color3.fromRGB(255, 0, 0)
    end)
end

CreateButton("ESP Players", "ESP")
CreateButton("Auto Collect Coins", "AutoCoin")

-- ESP Logic
RunService.RenderStepped:Connect(function()
    for _, p in pairs(Players:GetPlayers()) do
        if p ~= LocalPlayer and p.Character then
            local highlight = p.Character:FindFirstChild("MM2_ESP")
            if Toggles.ESP then
                if not highlight then
                    highlight = Instance.new("Highlight")
                    highlight.Name = "MM2_ESP"
                    highlight.Parent = p.Character
                end
                
                -- Phân biệt vai trò qua màu sắc
                if p.Backpack:FindFirstChild("Knife") or p.Character:FindFirstChild("Knife") then
                    highlight.FillColor = Color3.fromRGB(255, 0, 0) -- Murder
                elseif p.Backpack:FindFirstChild("Gun") or p.Character:FindFirstChild("Gun") then
                    highlight.FillColor = Color3.fromRGB(0, 0, 255) -- Sheriff
                else
                    highlight.FillColor = Color3.fromRGB(0, 255, 0) -- Innocent
                end
            else
                if highlight then highlight:Destroy() end
            end
        end
    end
end)

-- Auto Coin Logic
task.spawn(function()
    while task.wait(0.1) do
        if Toggles.AutoCoin then
            local container = workspace:FindFirstChild("Normal") and workspace.Normal:FindFirstChild("CoinContainer")
            if container then
                for _, coin in pairs(container:GetChildren()) do
                    if coin:IsA("BasePart") and LocalPlayer.Character and LocalPlayer.Character:FindFirstChild("HumanoidRootPart") then
                        coin.CFrame = LocalPlayer.Character.HumanoidRootPart.CFrame
                    end
                end
            end
        end
    end
end)

print("MM2 Script Loaded for Thang Dan")