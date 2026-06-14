local ReplicatedStorage = game:GetService('ReplicatedStorage')

local remote_img = require(game.ReplicatedStorage.remote_img)

ReplicatedStorage:WaitForChild("loadPlayerSkin").OnClientEvent:Connect(function(uuid, player, Character)

	local sessionUrl = "https://" .. game.ReplicatedStorage.SESSION_SERVER.Value .. "/session/minecraft/profile/" .. uuid
	local skinUrl = remote_img.retreive_image_url(sessionUrl)
	local skin = remote_img.create_image(skinUrl)
	task.wait()

	local skinContent = Content.fromObject(skin)


	-- DEBUG: show the decoded skin as a flat 2D image
	--[[
	local player = game:GetService("Players").LocalPlayer
	local debugGui = Instance.new("ScreenGui")
	debugGui.Name = "SkinDebugGui"
	debugGui.ResetOnSpawn = false
	debugGui.Parent = player:WaitForChild("PlayerGui")
	
	local debugImage = Instance.new("ImageLabel")
	debugImage.Size = UDim2.new(0, 256, 0, 256) -- scaled up so a 64x64 image is visible
	debugImage.Position = UDim2.new(0, 20, 0, 20)
	debugImage.BackgroundColor3 = Color3.fromRGB(0, 200, 0) -- green background to see transparency
	debugImage.BorderSizePixel = 0
	debugImage.ScaleType = Enum.ScaleType.Fit
	debugImage.ImageContent = skinContent
	debugImage.Parent = debugGui
	]]

	-- DEBUG

	
	for _, part in pairs(Character.SecondLayer:GetChildren()) do

		if part:IsA("MeshPart") then
			part.TextureContent = skinContent
		end
	end
	for _, part in pairs(Character:GetChildren()) do
		if part:IsA("MeshPart") then
			part.TextureContent = skinContent
		end
	end
end)