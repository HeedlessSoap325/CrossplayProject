local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BlockService = require(ReplicatedStorage:WaitForChild("BlockService"))

local modelsFolder = ReplicatedStorage:WaitForChild("models")
local blocksFolder = workspace:WaitForChild("Blocks")
local updateInterval = 60 / 100 -- 100 requests per minute

local function getChunkBlocks(chunkX, chunkZ)
	local url = string.format("http://%s/blocks?chunkX=%d&chunkZ=%d", ReplicatedStorage.IP.Value, chunkX, chunkZ)

	local ok, res = pcall(function()
		return HttpService:RequestAsync({
			Url = url,
			Method = "GET",
			Timeout = 5
		})
	end)

	if not ok or not res or not res.Success then
		warn("Chunk request failed:", chunkX, chunkZ)
		return nil
	end

	local success, data = pcall(function()
		return HttpService:JSONDecode(res.Body)
	end)

	if not success then
		warn("Bad JSON for chunk:", chunkX, chunkZ)
		return nil
	end
	
	return data
end

local function loadChunks(centerX, centerZ, size)
	print("Started loading Chunks")

	local half = math.floor(size / 2)

	local results = {}
	local remaining = 0

	local function fetchChunk(x, z)
		remaining += 1

		task.spawn(function()
			local data = getChunkBlocks(x, z)

			if data then
				results[x .. ":" .. z] = data
			end

			remaining -= 1
		end)
	end

	for x = centerX - half, centerX + half do
		for z = centerZ - half, centerZ + half do
			fetchChunk(x, z)
			task.wait(0.05)
		end
	end

	while remaining > 0 do
		task.wait(0.1)
	end

	for _, chunkData in pairs(results) do
		BlockService:StoreChunk(chunkData)
	end

	print("Successfully loaded all requested Chunks")

	task.spawn(function()
		BlockService:BuildVisibleWorld(modelsFolder, blocksFolder)
	end)
end

local function startUpdatingChunks(centerChunkX, centerChunkY, chunkGridSize)
	--[[
	while true do
		loadChunks(centerChunkX, centerChunkY, chunkGridSize)
		task.wait(updateInterval)
	end
	]]
	task.spawn(function ()
		loadChunks(centerChunkX, centerChunkY, chunkGridSize)
	end)
end

-- First two values are the center chunk. The third one is the chunk radius. Works only for odd numbers. Eg. 3 is going to be a 3x3 grid, 5 is going to be a 5x5 grid.
startUpdatingChunks(0, 0, 3)