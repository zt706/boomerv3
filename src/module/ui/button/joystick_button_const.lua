--[[
	操纵杆常量
--]]

local JoyStickButtonConst = {}

JoyStickButtonConst.DEBUG_NORMAL_COLOR = cc.c3b(255, 0, 0)
JoyStickButtonConst.DEBUG_HIGHLIGHT_COLOR = cc.c3b(255, 255, 0)

-- 操纵杆上的四个小方向键的大小
JoyStickButtonConst.DIRECTION_BUTTON_WIDTH = 60
JoyStickButtonConst.DIRECTION_BUTTON_HEIGHT = 60

-- 操纵杆本身的大小
JoyStickButtonConst.WIDTH = 260
JoyStickButtonConst.HEIGHT = 260
JoyStickButtonConst.RADIUS = JoyStickButtonConst.WIDTH / 2 -- 操纵杆中心设置为圆

-- 操纵杆中心
JoyStickButtonConst.CENTER_X = JoyStickButtonConst.WIDTH / 2
JoyStickButtonConst.CENTER_Y = JoyStickButtonConst.HEIGHT / 2
JoyStickButtonConst.CENTER_POS = cc.p(JoyStickButtonConst.CENTER_X, JoyStickButtonConst.CENTER_Y)

-- 光圈大小
JoyStickButtonConst.CIRCLE_WIDTH = 114
JoyStickButtonConst.CIRCLE_HEIGHT = 114

-- 滑动无效区域，只有在半径的2/4到半径才是滑动有效区域
JoyStickButtonConst.INVALID_RADIUS = JoyStickButtonConst.RADIUS * 0

-- 操纵杆资源
JoyStickButtonConst.BACKGROUND_PATH = "module/ui/button/ControlWheel.png" -- 底图
JoyStickButtonConst.CIRCLE_PATH = "module/ui/button/TinyCircle.png" -- 光圈

return JoyStickButtonConst