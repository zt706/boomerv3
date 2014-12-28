--[[
	层-障碍物（可以被炸毁）
--]]

local ObstacleLayer = class("ObstacleLayer", function()
	return display.newLayer()
end)

ObstacleLayer.ctor = function(self)
	local blockInfos = Map.getBlockInfo() -- 地图阻挡信息
	
	self.obstacleInfos = {}
	for row = 1, MapConst.ROWS do
		for col = 1, MapConst.COLS do
			if blockInfos[row][col] > 1 then
				-- 障碍物信息最低从2开始
				local x = (col - 1) * MapConst.BLOCK_WIDTH + MapConst.LEFT_PADDING
				local y = (row - 1) * MapConst.BLOCK_HEIGHT + MapConst.BOTTOM_PADDING
				
				local node = display.newSprite(Map.getObstacleRes())
				local size = node:getContentSize()
				local xScale = MapConst.BLOCK_WIDTH / size.width
				local yScale = MapConst.BLOCK_HEIGHT / size.height
				node:setScale(xScale, yScale)

				node:align(display.LEFT_BOTTOM, x, y)

				self:addChild(node)

				self.obstacleInfos[#self.obstacleInfos + 1] = {
					row = row,
					col = col,
					node = node,
				}
			end
		end
	end

	-- 添加爆炸事件处理
	EventMgr.registerEvent(EventConst.MINE_BOOM, handler(self, self.mineBoom))
end

ObstacleLayer.mineBoom = function(self, blocks)
	-- 获取所有的障碍物，结算障碍物，如果障碍物被炸到，那么就清空它，然后置该处阻挡为0
	for _, v in pairs(blocks) do
		for _, block in pairs(v) do
			for k, obstacle in pairs(self.obstacleInfos) do
				if block.row == obstacle.row and block.col == obstacle.col then
					Logger.info("障碍物被炸了")
					self:removeChild(obstacle.node)

					-- 重置这里的阻挡信息
					Map.resetBlockByRowAndCol(obstacle.row, obstacle.col)

					self.obstacleInfos[k] = nil
				end
			end
		end
	end

	-- 清空掉那些为nil的障碍物信息
	self.obstacleInfos = table.removeAllNilValue(self.obstacleInfos)
end

return ObstacleLayer