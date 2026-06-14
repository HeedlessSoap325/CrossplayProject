local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local BlockService = require(ReplicatedStorage:WaitForChild("BlockService"))
local modelsFolder = ReplicatedStorage:WaitForChild("models")
local blocksFolder = workspace:WaitForChild("Blocks")

local remoteEvent = Instance.new("RemoteEvent")
remoteEvent.Name = "BlockPlaceEvent"
remoteEvent.Parent = ReplicatedStorage

local function onBlockPlace(player, blockData)
	local key = string.format("%d,%d,%d", blockData.x, blockData.y, blockData.z)

	local block = BlockService.Blocks[key]
	if block then
		warn("Block already exists at location: " .. key)
		return
	end

	local data = {
		x = blockData.x,
		y = blockData.y,
		z = blockData.z,
		t = blockData.material,
		material = blockData.material,
		direction = blockData.direction,
		action = "BUILD"
	}

	local url = "http://" .. ReplicatedStorage.IP.Value .. "/post"
	local success, response = pcall(function()
		print("Calling HTTP Request")
		return HttpService:PostAsync(url, HttpService:JSONEncode(data), Enum.HttpContentType.ApplicationJson)
	end)

	if success then
		print("Setting Block")
		BlockService:SetBlock(data, modelsFolder, blocksFolder)
		print("Block Set")
	else
		warn("Failed to send block place data: " .. tostring(response))
	end
end

remoteEvent.OnServerEvent:Connect(onBlockPlace)
