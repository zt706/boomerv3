--[[
	层-阻挡和行走方块（炸弹特效不可以穿越）
--]]

local BlockLayer = class("BlockLayer", function()
	return display.newLayer()
end)

BlockLayer.ctor = function(self)
	local blockPassColor = cc.c4f(0, 1, 0, 0.3)		-- 地图中可以行走方块的颜色
	local blockNonPassColor = cc.c4f(1, 0, 0, 0.3)	-- 地图中障碍物方块的颜色
	local blockInfos = Map.getBlockInfo()

	for row = 1, MapConst.ROWS do
		for col = 1, MapConst.COLS do
			local x = (col - 1) * MapConst.BLOCK_WIDTH + MapConst.LEFT_PADDING
			local y = (row - 1) * MapConst.BLOCK_HEIGHT + MapConst.BOTTOM_PADDING
			local color = blockInfos[row][col] == 0 and blockPassColor or blockNonPassColor

			local rectNode = display.newRect(cc.rect(0, 0, MapConst.BLOCK_WIDTH, MapConst.BLOCK_HEIGHT), {fillColor = color, fill = true})
			display.align(rectNode, display.LEFT_BOTTOM, x, y)
			self:addChild(rectNode)

			local text = string.format("(%d,%d)", col, row)
			self:drawText(x + MapConst.BLOCK_WIDTH / 2, y + MapConst.BLOCK_HEIGHT / 2, text)
		end
	end
end

BlockLayer.drawText = function(self, x, y, text)
	local label = display.newTTFLabel({text = text, size = 12, color = display.COLOR_WHITE})
	display.align(label, display.CENTER, x, y)
	self:addChild(label)
end

return BlockLayer