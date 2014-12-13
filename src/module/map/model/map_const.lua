--[[
	地图常量信息
--]]

local MapConst = {}

MapConst.DEFAULT_ROWS = 9
MapConst.DEFAULT_COLS = 17
MapConst.DEFAULT_BLOCK_PADDING = 3
MapConst.DEFAULT_BLOCK_HEIGHT = math.ceil(display.height / MapConst.DEFAULT_ROWS - MapConst.DEFAULT_BLOCK_PADDING)
MapConst.DEFAULT_BLOCK_WIDTH = math.ceil(display.width / MapConst.DEFAULT_COLS - MapConst.DEFAULT_BLOCK_PADDING)

MapConst.ROWS = 9
MapConst.COLS = 17

MapConst.LEFT_PADDING = 30
MapConst.RIGHT_PADDING = 30
MapConst.TOP_PADDING = 30
MapConst.BOTTOM_PADDING = 30

MapConst.WIDTH = display.width - MapConst.LEFT_PADDING - MapConst.RIGHT_PADDING
MapConst.HEIGHT = display.height - MapConst.TOP_PADDING - MapConst.BOTTOM_PADDING
MapConst.BLOCK_WIDTH = math.ceil(MapConst.WIDTH / MapConst.COLS)
MapConst.BLOCK_HEIGHT = math.ceil(MapConst.HEIGHT / MapConst.ROWS)

return MapConst