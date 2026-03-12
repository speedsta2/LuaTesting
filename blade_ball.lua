local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Stats = game:GetService("Stats")

local Player = Players.LocalPlayer

task.wait(1)

StarterGui:SetCore("SendNotification", {
	Title = "WillHub",
	Text = "Best Auto Perry Loaded",
	Icon = "rbxassetid://135351041318579",
	Duration = 8
})
StarterGui:SetCore("SendNotification", {
	Title = "WillHub",
	Text = "It's best to hit the ball the first time when it come's to you then the auto perry will work fine.",
	Icon = "rbxassetid://135351041318579",
	Duration = 12
})

local Parried = false
local Connection

local function GetPing()
	local pingString = Stats.Network.ServerStatsItem["Data Ping"]:GetValueString()
	local pingNumber = tonumber(pingString:match("%d+"))
	return (pingNumber or 50) / 1000
end

local function GetBall()
	for _, Ball in pairs(workspace.Balls:GetChildren()) do
		if Ball:GetAttribute("realBall") then
			return Ball
		end
	end
end

-- Reset connection when target changes
local function ResetConnection()
	if Connection then
		Connection:Disconnect()
		Connection = nil
	end

	local Ball = GetBall()
	if not Ball then return end

	Connection = Ball:GetAttributeChangedSignal("target"):Connect(function()
		Parried = false
	end)
end

-- When new ball spawns
workspace.Balls.ChildAdded:Connect(function()
	task.wait()
	ResetConnection()
end)
RunService.PreSimulation:Connect(function()

	local Character = Player.Character
	if not Character then return end

	local HRP = Character:FindFirstChild("HumanoidRootPart")
	local Ball = GetBall()

	if not HRP or not Ball then return end

	local Zoomies = Ball:FindFirstChild("zoomies")
	if not Zoomies then return end

	local Speed = Zoomies.VectorVelocity.Magnitude
	if Speed <= 0 then return end

	local Distance = (HRP.Position - Ball.Position).Magnitude
	local TravelTime = Distance / Speed

	local Ping = GetPing()
	local ReactionTime = 0.18 + Ping

	if Ball:GetAttribute("target") == Player.Name and not Parried then
		if TravelTime <= ReactionTime then

			VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,0)
			Parried = true

		end
	end
end)
