--[[
	地图信息，地图结构，要能获取每个block的阻挡信息和坐标信息
--]]

local Map = {}

Map.init = function(mapId)
	mapId = mapId or "1" -- 默认就是第一张地图

	Map.mapId = mapId
	Map.blockRes = InfoMap.blockRes -- 方块贴图信息
	Map.mapConfig = InfoMap[mapId]
	Map.blockInfo = InfoMap[mapId].blocks -- 地图阻挡信息

	Map.createMapPointsInfo() -- 这个其实应该生成一次就好了，坐标是固定的
end

-- 生成地图的坐标点，这个其实自动处理就好了
Map.createMapPointsInfo = function()
	if Map.curMapPoints then
		return
	end

	Map.curMapPoints = {}

	local startPoint = {x = MapConst.BLOCK_WIDTH / 2, y = MapConst.BLOCK_HEIGHT}
	for row = 1, MapConst.ROWS do
		Map.curMapPoints[row] = {}
		for col = 1, MapConst.COLS do
			local x = (col - 1) * MapConst.BLOCK_WIDTH + MapConst.LEFT_PADDING
			local y = (row - 1) * MapConst.BLOCK_HEIGHT + MapConst.BOTTOM_PADDING

			Map.curMapPoints[row][col] = {}
			Map.curMapPoints[row][col].leftBottomPoint = {x = x, y = y}
			Map.curMapPoints[row][col].centerPoint = {x = x + MapConst.BLOCK_WIDTH / 2, y = y + MapConst.BLOCK_HEIGHT / 2}
		end
	end
end

-- 传入指定行列，返回该地图块的中心点
Map.getPosByRowAndCol = function(row, col)
	if not Map.curMapPoints then
		Map.createMapPointsInfo()
	end

	return Map.curMapPoints[row][col].centerPoint
end

-- 传入指定行列，返回该地图块的左下点
Map.getLeftBottomPosByRowAndCol = function(row, col)
	if not Map.curMapPoints then
		Map.createMapPointsInfo()
	end

	return Map.curMapPoints[row][col].leftBottomPoint
end

-- 传入指定行列，返回该方块的阻挡信息
-- needObstacle默认为false，表示障碍物也是阻挡，为true表示忽略障碍物
Map.getBlockByRowAndCol = function(row, col, needObstacle)
	if not Map.checkRowAndCol(row, col) then
		return false
	end

	if needObstacle then
		return (Map.blockInfo[row][col] == 1)
	else
		return (Map.blockInfo[row][col] ~= 0)
	end
end

-- 传入坐标，返回该方块的行列
Map.getRowAndColByPos = function(x, y)
	local child0 = Map.getLeftBottomPosByRowAndCol(1, 1)
	local row = math.floor((y - child0.y) / MapConst.BLOCK_HEIGHT) + 1
	local col = math.floor((x - child0.x) / MapConst.BLOCK_WIDTH) + 1

	if not Map.checkRowAndCol(row, col) then
		return nil
	end

	return row, col
end

-- 传入坐标，返回该方块的阻挡信息
-- needObstacle默认为false，表示障碍物也是阻挡，为true表示忽略障碍物
Map.getBlockByPos = function(x, y, needObstacle)
	local row, col = Map.getRowAndColByPos(x, y)
	return Map.getBlockByRowAndCol(row, col, needObstacle)
end

-- 传入指定的行列，返回该方块的包围盒
Map.getRectByRowAndCol = function(row, col)
	return cc.rect(Map.curMapPoints[row][col].leftBottomPoint.x, Map.curMapPoints[row][col].leftBottomPoint.y, MapConst.BLOCK_WIDTH, MapConst.BLOCK_HEIGHT)
end

-- 检查是否地图行列值是否有效
Map.checkRowAndCol = function(row, col)
	if 1 <= row and row <= MapConst.ROWS and 1 <= col and col <= MapConst.COLS then
		return true
	end

	return false
end

-- 获取地图阻挡信息
Map.getBlockInfo = function()
	return Map.blockInfo
end

-- 获取地图背景图路径
Map.getBackgroundRes = function()
	return Map.mapConfig.backgroundRes
end

-- 获取正常行走方块贴图的路径
Map.getNormalRes = function()
	return Map.blockRes[0]
end

-- 获取阻挡方块贴图的路径
Map.getBlockRes = function()
	return Map.blockRes[1]
end

-- 获取障碍物方块贴图的路径，由于障碍物可能有多种，这里就通过传入 id 处理，这个 id 可以通过地图阻挡信息得到
Map.getObstacleRes = function(id)
	id = id or 2
	return Map.blockRes[id]
end

--[[
	获取指定坐标周围上下左右和自己5个方块
	needSelf表示是否需要返回阻挡方块，默认不返回
	needObstacle表示是否需要返回障碍物方块，默认不反悔
	depth表示深度，默认为1，表示取上下左右几个方块（2为各取2个），即一共返回最多9个方块
	这里一定会返回自己那个方块，无论是不是阻挡
--]]
Map.getAroundBlockByPos = function(x, y, params)
	params = params or {}
	local needSelf = params.needSelf and true or false
	local needObstacle = params.needObstacle and true or false
	local depth = params.depth or 1

	local blocks = {}
	local row, col = Map.getRowAndColByPos(x, y)
	
	if needSelf then
		-- middle表示自己，本来打算用self，觉得不妥当，还是用中间算了
		blocks["middle"] = {
			{row = row, col = col}
		}
	end

	local getBlocks = function(row, col, rowInc, colInc)
		local tmpBlocks = {}
		local tmpRow, tmpCol = row, col

		for i = 1, depth do
			tmpRow = tmpRow + rowInc
			tmpCol = tmpCol + colInc

			if not Map.getBlockByRowAndCol(tmpRow, tmpCol, needObstacle) then
				tmpBlocks[#tmpBlocks + 1] = {row = tmpRow, col = tmpCol}
			else
				break
			end
		end

		return tmpBlocks
	end

	blocks["up"] = getBlocks(row, col, 1, 0)
	blocks["down"] = getBlocks(row, col, -1, 0)
	blocks["right"] = getBlocks(row, col, 0, 1)
	blocks["left"] = getBlocks(row, col, 0, -1)

	return blocks
end

-- 重置这里的阻挡信息
Map.resetBlockByRowAndCol = function(row, col)
	Map.blockInfo[row][col] = 0
end

-- 重置指定方块群的阻挡信息
Map.resetBlocksByRowsAndCols = function(blocks)
	for _, v in pairs(blocks) do
		for _, block in pairs(v) do
			Map.blockInfo[block.row][block.col] = 0
		end
	end
end

-- 设置指定方块为阻挡
Map.setBlockByRowAndCol = function(row, col)
	Map.blockInfo[row][col] = 1
end

return Map