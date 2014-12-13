--[[
	调试绘制api
	主要绘制一些容易识别查看的图像块
--]]

local DebugDrawer = {}

-- 绘制地图的默认参数
DebugDrawer.initDefaultMap = function()
	Map.init("2")

	DebugDrawer.DEFAULT_ROWS = MapConst.ROWS
	DebugDrawer.DEFAULT_COLS = MapConst.COLS
	DebugDrawer.DEFAULT_BLOCK_WIDTH = MapConst.BLOCK_WIDTH
	DebugDrawer.DEFAULT_BLOCK_HEIGHT = MapConst.BLOCK_HEIGHT
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
	local textOn = params.textOn or true
	local callback = params.callback or function() end

	DebugDrawer.isInMoving = false -- 用于判断是否正在moving中，是则不接受点击

	local mapNode = display.newNode()
	for row = 1, rows do
		for col = 1, cols do
			local x = (col - 1) * blockWidth + MapConst.LEFT_PADDING
			local y = (row - 1) * blockHeight + MapConst.BOTTOM_PADDING
			local color = childs[row][col] == 0 and blockPassColor or blockNonPassColor

			local touchNode = display.newNode()
			touchNode:setContentSize(cc.size(blockWidth, blockHeight))
			touchNode:setTouchEnabled(true)
			touchNode:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
				Logger.info("点中区域：", event.x, event.y)
				-- 正在执行动画，则不处理
				if DebugDrawer.isInMoving then
					return
				end

				-- 点中的终点为阻挡，则不处理
				if Map.getBlockByRowAndCol(row, col) then
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
						local action1 = cc.DelayTime:create(timecost * i)
						local action2 = cc.ScaleTo:create(0.1, 1.2)
						local action3 = cc.DelayTime:create(timecost)
						local action4 = cc.ScaleTo:create(0.1, 1.0)
						local action5 = cc.CallFunc:create(function() node:setLineColor(color) end)
						
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

			local rectNode = display.newRect(cc.rect(0, 0, blockWidth, blockHeight), {fillColor = color, fill = true})
			touchNode:addChild(rectNode)

			touchNode:align(display.LEFT_BOTTOM, x, y)
			mapNode:addChild(touchNode)
			mapNode.childs = mapNode.childs or {}
			mapNode.childs[row] = mapNode.childs[row] or {}
			mapNode.childs[row][col] = rectNode

			if textOn then
				local text = string.format("(%d,%d)", col, row)
				DebugDrawer.drawText(x + blockWidth / 2, y + blockHeight / 2, text, mapNode)
			end
		end
	end
	
	mapNode:align(display.LEFT_BOTTOM, 0, 0)
	return mapNode
end

DebugDrawer.drawText = function(x, y, text, parent, params)
	params = params or {}

	local label = display.newTTFLabel({text = text, size = 12, color = params.color or display.COLOR_WHITE})
	label:align(display.CENTER, x, y)
	parent:addChild(label)
end

return DebugDrawer