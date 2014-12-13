--[[
	地图常量信息
--]]

local MapConst = {}

MapConst.ROWS = 9
MapConst.COLS = 17

MapConst.LEFT_PADDING = 30
MapConst.RIGHT_PADDING = 30
MapConst.TOP_PADDING = 100
MapConst.BOTTOM_PADDING = 30

MapConst.WIDTH = display.width - MapConst.LEFT_PADDING - MapConst.RIGHT_PADDING
MapConst.HEIGHT = display.height - MapConst.TOP_PADDING - MapConst.BOTTOM_PADDING
MapConst.BLOCK_WIDTH = math.ceil(MapConst.WIDTH / MapConst.COLS)
MapConst.BLOCK_HEIGHT = math.ceil(MapConst.HEIGHT / MapConst.ROWS)

return MapConst