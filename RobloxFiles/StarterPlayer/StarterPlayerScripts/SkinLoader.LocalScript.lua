local ReplicatedStorage = game:GetService('ReplicatedStorage')

local remote_img = require(game.ReplicatedStorage.remote_img)

ReplicatedStorage:WaitForChild("loadPlayerSkin").OnClientEvent:Connect(function(uuid, player, Character)

	local sessionUrl = "https://" .. game.ReplicatedStorage.SESSION_SERVER.Value .. "/session/minecraft/profile/" .. uuid
	local skinUrl = remote_img.retreive_image_url(sessionUrl)
	local skin = remote_img.create_image(skinUrl)
	task.wait()

	local skinContent = Content.fromObject(skin)
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