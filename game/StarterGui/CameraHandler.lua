--!nonstrict
local CamSpeed =0.10
local CamSpeedBoost = 0.3

local c = game.Workspace.CurrentCamera
local plr = game.Players.LocalPlayer
local char = plr.Character or plr.CharacterAdded:Wait()
local humanoid:Humanoid = char:WaitForChild("Humanoid")
local context = game:GetService("ContextActionService")
local uis = game:GetService("UserInputService")
local mouse = plr:GetMouse()
local rs = game:GetService("RunService")
local keysDown = {}
local mouseMoveMode:boolean = true
uis.MouseIconEnabled = false
c.CameraSubject = nil
c.CameraType = Enum.CameraType.Scriptable
local Controls = require(plr.PlayerScripts:WaitForChild("PlayerModule")):GetControls()
Controls:Disable()

local validKeys = {"Q","E","W","A","S","D","LeftShift"}

function InputBegan(Input:InputObject)
	for i, key in pairs(validKeys) do
		if key == Input.KeyCode.Name then
			keysDown[key] = true
		end
	end
	if Input.UserInputType == Enum.UserInputType.MouseButton3 then
		mouseMoveMode = not mouseMoveMode
		if mouseMoveMode then
			uis.MouseIconEnabled = false
			uis.MouseBehavior = Enum.MouseBehavior.LockCurrentPosition
		else
			uis.MouseIconEnabled = true
			uis.MouseBehavior = Enum.MouseBehavior.Default
		end
	end
end

function InputEnded(Input:InputObject)
	for key, v in pairs(keysDown) do
		if key == Input.KeyCode.Name then
			keysDown[key] = false
		end
	end
end

function RenderStepped(dt:number)
	CamSpeed =0.1*(dt*60.75)
	CamSpeedBoost = 0.3*(dt*60.75)
	if mouseMoveMode == true then
		local delta = uis:GetMouseDelta()
		local cf = c.CFrame
		local deltaY = delta.Y
		local yAngle = cf:ToEulerAngles(Enum.RotationOrder.YZX)
		local newAmount = math.deg(yAngle)+deltaY
		if newAmount > 65 or newAmount < -65 then
			if not (yAngle<0 and delta.Y<0) and not (yAngle>0 and delta.Y>0) then
				delta = Vector2.new(delta.X,0)
			end end
		cf *= CFrame.Angles(-math.rad(deltaY),0,0)
		cf = CFrame.Angles(0,-math.rad(delta.X),0) * (cf - cf.Position) + cf.Position
		cf = CFrame.lookAt(cf.Position, cf.Position + cf.LookVector)
		if delta ~= Vector2.new(0,0) then c.CFrame = c.CFrame:Lerp(cf,uis.MouseDeltaSensitivity) end
	end

	if keysDown["W"] then
		c.CFrame *= CFrame.new(Vector3.new(0,0,-(if keysDown.LeftShift then CamSpeedBoost else CamSpeed)))
	end
	if keysDown["A"] then
		c.CFrame *= CFrame.new(Vector3.new(-(if keysDown.LeftShift then CamSpeedBoost else CamSpeed),0,0))
	end
	if keysDown["S"] then
		c.CFrame *= CFrame.new(Vector3.new(0,0,(if keysDown.LeftShift then CamSpeedBoost else CamSpeed)))
	end
	if keysDown["D"] then
		c.CFrame *= CFrame.new(Vector3.new((if keysDown.LeftShift then CamSpeedBoost else CamSpeed),0,0))
	end
	if keysDown["E"] then
		c.CFrame *= CFrame.new(Vector3.new(0,(if keysDown.LeftShift then CamSpeedBoost else CamSpeed),0))
	end
	if keysDown["Q"] then
		c.CFrame *= CFrame.new(Vector3.new(0,-(if keysDown.LeftShift then CamSpeedBoost else CamSpeed),0))
	end
end

uis.InputBegan:Connect(InputBegan)
uis.InputEnded:Connect(InputEnded)

rs.RenderStepped:Connect(RenderStepped)
