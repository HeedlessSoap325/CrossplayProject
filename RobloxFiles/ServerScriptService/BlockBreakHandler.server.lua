local ReplicatedStorage = game:GetService("ReplicatedStorage")
local HttpService = game:GetService("HttpService")

local BlockService = require(ReplicatedStorage:WaitForChild("BlockService"))
local modelsFolder = ReplicatedStorage:WaitForChild("models")
local blocksFolder = workspace:WaitForChild("Blocks")

local remoteEvent = Instance.new("RemoteEvent")
remoteEvent.Name = "BlockBrokenEvent"
remoteEvent.Parent = ReplicatedStorage

local function onBlockInteraction(player, blockPosition)
	local key = string.format("%d,%d,%d", blockPosition.X / 3, blockPosition.Y / 3, blockPosition.Z / 3)
	local block = BlockService.Blocks[key]

	if block then
		local data = {
			x = blockPosition.X / 3,
			y = blockPosition.Y / 3,
			z = blockPosition.Z / 3,
			t = block.t,
			action = "BREAK"
		}

		spawn(function()
			local url = "http://" .. ReplicatedStorage.IP.Value .. "/post"
			local success, response = pcall(function()
				return HttpService:PostAsync(url, HttpService:JSONEncode(data), Enum.HttpContentType.ApplicationJson)
			end)

			if success then
				BlockService:RemoveBlock(data, modelsFolder, blocksFolder)
			else
				warn("Failed to send block break data: " .. tostring(response))
			end
		end)
	end
end

remoteEvent.OnServerEvent:Connect(onBlockInteraction)