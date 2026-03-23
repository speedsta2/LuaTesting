local StarterGui = game:GetService("StarterGui")
local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local VirtualInputManager = game:GetService("VirtualInputManager")
local Stats = game:GetService("Stats")

local Player = Players.LocalPlayer

task.wait(1)

StarterGui:SetCore("SendNotification", {
	Title = "BelenWare",
	Text = "Auto Perry Loaded",
	Icon = "rbxassetid://249529865",
	Duration = 8
})
StarterGui:SetCore("SendNotification", {
	Title = "BelenWare",
	Text = "It's best to hit the ball the first time when it come's to you then the auto perry will work as intended.",
	Icon = "rbxassetid://1764960415",
	Duration = 12
})

local Parried = false
local TrainingParried = false

local Connection
local TrainingConnection

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

local function GetTrainingBall()
	for _, Ball in pairs(workspace.TrainingBalls:GetChildren()) do
		if Ball:GetAttribute("realBall") then
			return Ball
		end
	end
end

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

local function ResetTrainingConnection()
	if TrainingConnection then
		TrainingConnection:Disconnect()
		TrainingConnection = nil
	end

	local Ball = GetTrainingBall()
	if not Ball then return end

	TrainingConnection = Ball:GetAttributeChangedSignal("target"):Connect(function()
		TrainingParried = false
	end)
end

workspace.Balls.ChildAdded:Connect(function()
	task.wait()
	ResetConnection()
end)

workspace.TrainingBalls.ChildAdded:Connect(function()
	task.wait()
	ResetTrainingConnection()
end)

RunService.PreSimulation:Connect(function()

	local Character = Player.Character
	if not Character then return end

	local HRP = Character:FindFirstChild("HumanoidRootPart")
	if not HRP then return end

	local Ping = GetPing()
	local ReactionTime = 0.18 + Ping

	local Ball = GetBall()
	if Ball then
		local Zoomies = Ball:FindFirstChild("zoomies")
		if Zoomies then
			local Speed = Zoomies.VectorVelocity.Magnitude
			if Speed > 0 then
				local Distance = (HRP.Position - Ball.Position).Magnitude
				local TravelTime = Distance / Speed

				if Ball:GetAttribute("target") == Player.Name and not Parried then
					if TravelTime <= ReactionTime then
						VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,0)
						Parried = true
					end
				end
			end
		end
	end
	local TBall = GetTrainingBall()
	if TBall then
		local Zoomies = TBall:FindFirstChild("zoomies")
		if Zoomies then
			local Speed = Zoomies.VectorVelocity.Magnitude
			if Speed > 0 then
				local Distance = (HRP.Position - TBall.Position).Magnitude
				local TravelTime = Distance / Speed

				if TBall:GetAttribute("target") == Player.Name and not TrainingParried then
					if TravelTime <= ReactionTime then
						VirtualInputManager:SendMouseButtonEvent(0,0,0,true,game,0)
						TrainingParried = true
					end
				end
			end
		end
	end

end)
