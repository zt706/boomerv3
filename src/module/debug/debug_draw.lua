--[[
	调试绘制api
	主要绘制一些容易识别查看的图像块
--]]

local DebugDrawer = {}

-- 绘制地图的默认参数
DebugDrawer.initDefaultMap = function()
	Map.init("1")

	DebugDrawer.DEFAULT_ROWS = MapConst.DEFAULT_ROWS
	DebugDrawer.DEFAULT_COLS = MapConst.DEFAULT_COLS
	DebugDrawer.DEFAULT_BLOCK_PADDING = MapConst.DEFAULT_BLOCK_PADDING
	DebugDrawer.DEFAULT_BLOCK_WIDTH = MapConst.DEFAULT_BLOCK_WIDTH
	DebugDrawer.DEFAULT_BLOCK_HEIGHT = MapConst.DEFAULT_BLOCK_HEIGHT
	DebugDrawer.DEFAULT_BLOCK_PASS_COLOR = cc.c4f(0, 1, 0, 0.3)		-- 地图中可以行走方块的颜色
	DebugDrawer.DEFAULT_BLOCK_NONPASS_COLOR = cc.c4f(1, 0, 0, 0.3)	-- 地图中障碍物方块的颜色
	DebugDrawer.DEFAULT_MAP = Map.getBlockInfo()
end

DebugDrawer.drawMap = function(params)
	params = params or {}

	local childs = params.childs or DebugDrawer.DEFAULT_MAP
	local rows = params.rows or DebugDrawer.DEFAULT_ROWS
	local cols = params.cols or DebugDrawer.DEFAULT_COLS
	local blockWidth = params.blockWidth or DebugDrawer.DEFAULT_BLOCK_WIDTH
	local blockHeight = params.blockHeight or DebugDrawer.DEFAULT_BLOCK_HEIGHT
	local blockPassColor = params.blockPassColor or DebugDrawer.DEFAULT_BLOCK_PASS_COLOR
	local blockNonPassColor = params.blockNonPassColor or DebugDrawer.DEFAULT_BLOCK_NONPASS_COLOR
	local blockPadding = params.blockPadding or DebugDrawer.DEFAULT_BLOCK_PADDING
	local textOn = params.textOn or true
	local callback = params.callback or function() end

	DebugDrawer.isInMoving = false -- 用于判断是否正在moving中，是则不接受点击

	local mapNode = display.newNode()
	for row = 1, rows do
		for col = 1, cols do
			local x = (col - 1) * (blockWidth + blockPadding)
			local y = (row - 1) * (blockHeight + blockPadding)
			local color = childs[row][col] == 0 and blockPassColor or blockNonPassColor

			local rectNode = display.newRect(cc.rect(0, 0, blockWidth, blockHeight), {fillColor = color, fill = true})
			rectNode:setTouchEnabled(true)
			rectNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
				-- 正在执行动画，则不处理
				if DebugDrawer.isInMoving then
					return
				end

				-- 点中的终点为阻挡，则不处理
				if Map.getBlockByRowAndCol(row, col) ~= 0 then
					return
				end

				DebugDrawer.isInMoving = true

				local astar = SearchPathUtils.getAPath(childs, DebugDrawer.startPoint or {row = 2, col = 2}, {row = row, col = col}, true)
				if astar then
					DebugDrawer.findPath = true
					Logger.info("found a path, path length: ", #astar)

					local randomColor = cc.c4f(math.random(), math.random(), math.random(), 1)
					local timecost = 0.1
					for i = 1, #astar do
						local node = mapNode.childs[astar[i].row][astar[i].col]
						node:setLineColor(randomColor)
						local action1 = CCDelayTime:create(timecost * i)
						local action2 = CCScaleTo:create(0.1, 1.2)
						local action3 = CCDelayTime:create(timecost)
						local action4 = CCScaleTo:create(0.1, 1.0)
						local action5 = CCCallFunc:create(function() node:setLineColor(color) end)
						
 						node:runAction(transition.sequence({action1, action2, action3, action4, action5}))
					end
				else
					DebugDrawer.findPath = false
					Logger.info("not found a path")
				end

				Logger.info("press block row:", row, "col:", col, Map.getBlockByRowAndCol(row, col))
				callback(row, col, function()
					DebugDrawer.isInMoving = false
				end)
			end)

			display.align(rectNode, display.LEFT_BOTTOM, x, y)
			mapNode:addChild(rectNode)
			mapNode.childs = mapNode.childs or {}
			mapNode.childs[row] = mapNode.childs[row] or {}
			mapNode.childs[row][col] = rectNode

			if textOn then
				local text = string.format("(%d,%d)", col, row)
				DebugDrawer.drawText(x + blockWidth / 2, y + blockHeight / 2, text, mapNode)
			end
		end
	end
	
	display.align(mapNode, display.LEFT_BOTTOM, 0, 0)
	return mapNode
end

DebugDrawer.drawText = function(x, y, text, parent, params)
	params = params or {}

	local label = display.newTTFLabel({text = text, size = 12, color = params.color or display.COLOR_WHITE})
	display.align(label, display.CENTER, x, y)
	parent:addChild(label)
end

return DebugDrawer