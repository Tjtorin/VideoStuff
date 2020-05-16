local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local UserInputSerivce = game:GetService("UserInputService")
local TweenService = game:GetService("TweenService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local player = Players.LocalPlayer
local playerGui = player:WaitForChild("PlayerGui")
local dialog = playerGui:WaitForChild("DialogGui")
local character = player.Character or player.CharacterAdded:Wait()
local rootPart = character:WaitForChild("HumanoidRootPart")
local camera = workspace.CurrentCamera
local npcs = workspace:WaitForChild("NPCs")
local npcText = require(ReplicatedStorage:WaitForChild("NPCText"))

local isTalking = false

-- Show 'E' button
RunService.RenderStepped:Connect(function()
	for _, npc in pairs(npcs:GetChildren()) do
		local dist = (rootPart.Position - npc.HumanoidRootPart.Position).magnitude
		if dist < 10 and not isTalking then
			npc.HumanoidRootPart.ButtonGui.Enabled = true
		else
			npc.HumanoidRootPart.ButtonGui.Enabled = false
		end
	end
end)

-- Change the text of dialog.DialogLabel
local function setDialogText(text)
	dialog.DialogLabel.Text = ""
	for first, last in utf8.graphemes(text) do
		local grapheme = string.sub(text, first, last)
		
		if grapheme == "@" and string.sub(text, first+1, last+1) == "p" then
			wait(1)
		else
			if string.sub(text, first-1, last-1) ~= "@" then
				dialog.DialogLabel.Text = dialog.DialogLabel.Text .. grapheme
				wait(.05)
			end
		end
	end
end

-- Settings for tweening camera when talking to npc
local camTweenInfo = TweenInfo.new(
	1.5,
	Enum.EasingStyle.Quint,
	Enum.EasingDirection.Out
)

UserInputSerivce.InputBegan:Connect(function(input)
	for _, npc in pairs(npcs:GetChildren()) do
		local button = npc.HumanoidRootPart.ButtonGui
		
		if button.Enabled and not isTalking then
			if input.KeyCode == Enum.KeyCode.E then
				isTalking = true
				repeat wait()
					camera.CameraType = Enum.CameraType.Scriptable
				until camera.CameraType == Enum.CameraType.Scriptable
				character.Humanoid.WalkSpeed = 0
				
				-- Tween camera to view npc
				local camProperties = {CFrame = npc.CameraPart.CFrame}
				TweenService:Create(camera, camTweenInfo, camProperties):Play()
				
				dialog.Enabled = true
				
				dialog.DialogLabel.Continue.Visible = false
				setDialogText(npcText[npc.Name][1])
				dialog.DialogLabel.Continue.Visible = true
				
				local i = 2
				connection = dialog.DialogLabel.Continue.MouseButton1Click:Connect(function()
					if npcText[npc.Name][i] == nil then
						connection:Disconnect()
						dialog.Enabled = false
						isTalking = false
						camera.CameraType = Enum.CameraType.Custom
						character.Humanoid.WalkSpeed = 16
					else
						dialog.DialogLabel.Continue.Visible = false
						setDialogText(npcText[npc.Name][i])
						dialog.DialogLabel.Continue.Visible = true
						
						i = i + 1
					end
				end)
			end
		end
	end
end)



--------------- PUT THE REST OF THIS CODE INSIDE OF A MODULE SCRIPT --------------- 
local module = {}

module.NPC_1 = {
	"Hello there!@p My name is NPC and I specialize in stuff.",
	"Would you like a cookie?"
}

module.NPC_2 = {
	"Is spongebob a sponge or a bob?@p The world may never know."
}

module.NPC_3 = {
	"Hello!@p Would you like to buy any thing from my shop?",
	"Im selling a cheap Dominus Aeureus for 980,000 robux!"
}

return module