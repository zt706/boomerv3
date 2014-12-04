--[[
	地图常量信息
--]]

local MapConst = {}

MapConst.DEFAULT_ROWS = 9
MapConst.DEFAULT_COLS = 17
MapConst.DEFAULT_BLOCK_PADDING = 3
MapConst.DEFAULT_BLOCK_WIDTH = math.ceil(display.width / MapConst.DEFAULT_COLS - MapConst.DEFAULT_BLOCK_PADDING)
MapConst.DEFAULT_BLOCK_HEIGHT = math.ceil(display.height / MapConst.DEFAULT_ROWS - MapConst.DEFAULT_BLOCK_PADDING)

MapConst.ROWS = 9
MapConst.COLS = 17
MapConst.BLOCK_PADDING = 3
MapConst.BLOCK_WIDTH = math.ceil(display.width / MapConst.COLS - MapConst.BLOCK_PADDING)
MapConst.BLOCK_HEIGHT = math.ceil(display.height / MapConst.ROWS - MapConst.BLOCK_PADDING)

return MapConst