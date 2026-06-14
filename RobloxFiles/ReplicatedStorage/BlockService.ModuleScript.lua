local BlockService = {}

BlockService.Blocks = {}      -- logical world data
BlockService.Rendered = {}    -- rendered models in workspace

BlockService.BlockSize = 3

local function key(x, y, z)
	return x .. "," .. y .. "," .. z
end

function BlockService:_getKey(x, y, z)
	return key(x, y, z)
end

function BlockService:_isSolid(x,y,z)
	local block = self.Blocks[self:_getKey(x,y,z)]

	return block ~= nil
		and block.t ~= "AIR"
end

function BlockService:IsVisible(x, y, z)
	-- visible if ANY neighbor is empty
	if not self:_isSolid(x+1,y,z) then return true end
	if not self:_isSolid(x-1,y,z) then return true end
	if not self:_isSolid(x,y+1,z) then return true end
	if not self:_isSolid(x,y-1,z) then return true end
	if not self:_isSolid(x,y,z+1) then return true end
	if not self:_isSolid(x,y,z-1) then return true end

	return false
end

function BlockService:StoreChunk(chunkData)
	for _, blockData in ipairs(chunkData) do
		local k = self:_getKey(blockData.x, blockData.y, blockData.z)

		self.Blocks[k] = blockData
	end
end

function BlockService:RenderBlock(blockData, templateFolder, workspaceFolder)
	local k = self:_getKey( blockData.x, blockData.y, blockData.z)

	if self.Rendered[k] then
		return
	end

	local template = templateFolder:FindFirstChild(blockData.t)

	if not template then
		return
	end

	local model = template:Clone()

	model:SetPrimaryPartCFrame(
		CFrame.new(blockData.x * self.BlockSize, blockData.y * self.BlockSize, blockData.z * self.BlockSize)
	)

	model.Parent = workspaceFolder

	self.Rendered[k] = model
end

function BlockService:RemoveRendered(x, y, z)
	local k = self:_getKey(x, y, z)

	local model = self.Rendered[k]
	if model then
		model:Destroy()
		self.Rendered[k] = nil
	end
end

function BlockService:UpdateBlock(x, y, z, templateFolder, workspaceFolder)
	local k = self:_getKey(x,y,z)

	local block = self.Blocks[k]

	if not block then
		local rendered = self.Rendered[k]

		if rendered then
			rendered:Destroy()
			self.Rendered[k] = nil
		end

		return
	end

	if self:IsVisible(x,y,z) then

		if not self.Rendered[k] then
			self:RenderBlock(block, templateFolder, workspaceFolder)
		end

	else

		local rendered = self.Rendered[k]

		if rendered then
			rendered:Destroy()
			self.Rendered[k] = nil
		end
	end
end

function BlockService:UpdateNeighbors(x, y, z, templateFolder, workspaceFolder)
	local dirs = {
		{1,0,0},{-1,0,0},
		{0,1,0},{0,-1,0},
		{0,0,1},{0,0,-1}
	}

	for _, d in ipairs(dirs) do
		self:UpdateBlock(x + d[1], y + d[2], z + d[3], templateFolder, workspaceFolder)
	end
end

function BlockService:BuildVisibleWorld(templateFolder, workspaceFolder)
	print("Started building visible World, please wait...")
	local count = 0

	for _, blockData in pairs(self.Blocks) do

		if self:IsVisible(blockData.x, blockData.y, blockData.z) then
			self:RenderBlock(blockData, templateFolder, workspaceFolder)
		end

		count += 1

		if count % 500 == 0 then
			task.wait()
		end
	end

	print("Successfully built visible world ("..count.." blocks)")
end

function BlockService:SetBlock(blockData, templateFolder, workspaceFolder)
	local k = self:_getKey(blockData.x, blockData.y, blockData.z)

	self.Blocks[k] = blockData
	self:RenderBlock(blockData, templateFolder, workspaceFolder)
	self:UpdateNeighbors(blockData.x, blockData.y, blockData.z, templateFolder, workspaceFolder)
end

function BlockService:RemoveBlock(blockData, templateFolder, workspaceFolder)
	local k = self:_getKey(blockData.x, blockData.y, blockData.z)

	self.Blocks[k] = nil
	self:UpdateNeighbors(blockData.x, blockData.y, blockData.z, templateFolder, workspaceFolder)
	self:RemoveRendered(blockData.x, blockData.y, blockData.z)
end

return BlockService