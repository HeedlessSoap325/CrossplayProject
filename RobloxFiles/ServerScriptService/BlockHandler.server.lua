local HttpService = game:GetService("HttpService")
local ReplicatedStorage = game:GetService("ReplicatedStorage")

local BlockService = require(ReplicatedStorage:WaitForChild("BlockService"))

local modelsFolder = ReplicatedStorage:WaitForChild("models")
local blocksFolder = workspace:WaitForChild("Blocks")
local updateInterval = 60 / 100 -- 100 requests per minute

local function getChunkBlocks(chunkX, chunkZ)
	local url = string.format("http://%s/blocks?chunkX=%d&chunkZ=%d", ReplicatedStorage.IP.Value, chunkX, chunkZ)

	local ok, res = pcall(function()
		return HttpService:GetAsync(url)
	end)

	if not ok then
		warn("Chunk request failed:", res)
		return nil
	end

	local success, data = pcall(function()
		return HttpService:JSONDecode(res)
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
	
	for x = centerX - half, centerX + half do
		for z = centerZ - half, centerZ + half do
			local chunkData = getChunkBlocks(x,z)
	
			if chunkData then
				BlockService:StoreChunk(chunkData)
			end
	
			task.wait()
		end
	end

	print("Successfully loaded all requested Chuncks")

	BlockService:BuildVisibleWorld(modelsFolder, blocksFolder)
end

local function startUpdatingChunks(centerChunkX, centerChunkY, chunkGridSize)
	--[[
	while true do
		loadChunks(centerChunkX, centerChunkY, chunkGridSize)
		task.wait(updateInterval)
	end
	]]
	loadChunks(centerChunkX, centerChunkY, chunkGridSize)
end

-- First two values are the center chunk. The third one is the chunk radius. Works only for odd numbers. Eg. 3 is going to be a 3x3 grid, 5 is going to be a 5x5 grid.
startUpdatingChunks(0, 0, 3)