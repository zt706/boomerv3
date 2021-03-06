--[[
	层-阻挡和行走方块（炸弹特效不可以穿越）
--]]

local BlockLayer = class("BlockLayer", function()
	return display.newLayer()
end)

BlockLayer.ctor = function(self)
	local blockInfos = Map.getBlockInfo() -- 地图阻挡信息
	
	local blockBatchNode = display.newBatchNode(Map.getBlockRes())
	self:addChild(blockBatchNode)

	local normalBatchNode = display.newBatchNode(Map.getNormalRes())
	self:addChild(normalBatchNode)

	for row = 1, MapConst.ROWS do
		for col = 1, MapConst.COLS do
			local x = (col - 1) * MapConst.BLOCK_WIDTH + MapConst.LEFT_PADDING
			local y = (row - 1) * MapConst.BLOCK_HEIGHT + MapConst.BOTTOM_PADDING

			local path = Map.getNormalRes()
			if blockInfos[row][col] == 1 then
				path = Map.getBlockRes() -- 1为阻挡
			end

			local node = display.newSprite(path)
			local size = node:getContentSize()
			local xScale = MapConst.BLOCK_WIDTH / size.width
			local yScale = MapConst.BLOCK_HEIGHT / size.height
			node:setScale(xScale, yScale)
			node:align(display.LEFT_BOTTOM, x, y)

			if blockInfos[row][col] == 1 then
				blockBatchNode:addChild(node)
			else
				normalBatchNode:addChild(node)
			end

			if DEBUG_MAP then
				local text = string.format("(%d,%d)", col, row)
				self:drawText(x + MapConst.BLOCK_WIDTH / 2, y + MapConst.BLOCK_HEIGHT / 2, text)
			end
		end
	end
end

BlockLayer.drawText = function(self, x, y, text)
	local label = display.newTTFLabel({text = text, size = 12, color = display.COLOR_WHITE})
	label:align(display.CENTER, x, y)
	self:addChild(label)
end

return BlockLayer