--[[
	层-障碍物（可以被炸毁）
--]]

local ObstacleLayer = class("ObstacleLayer", function()
	return display.newLayer()
end)

ObstacleLayer.ctor = function(self)
	local blockInfos = Map.getBlockInfo() -- 地图阻挡信息
	
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
			end
		end
	end
end

return ObstacleLayer