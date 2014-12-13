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
Map.getBlockByRowAndCol = function(row, col)
	return Map.blockInfo[row][col]
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
Map.getBlockByPos = function(x, y)
	local row, col = Map.getRowAndColByPos(x, y)
	return Map.getBlockByRowAndCol(row, col)
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

return Map