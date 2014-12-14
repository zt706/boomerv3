--[[
	事件常来定义
--]]

local EventConst = {}

-- 部分常用常量
EventConst.SCENE_ENTER = "sceneEnter"
EventConst.SCENE_EXIT = "sceneExit"
EventConst.ENTER_MAIN_SCENE = "enterMainScene"
EventConst.SYSTEM_ERROR = "systemError"

-- 事件优先级
EventConst.PRIO_HIGH = 10
EventConst.PRIO_MIDDLE = 5
EventConst.PRIO_LOW = 1

-- 这里用来扩展游戏里自定义的
EventConst.ADD_MINE = "addMine"
EventConst.MINE_BOOM = "mineBoom"
EventConst.OBSTACLE_BOOM = "obstacleBoom"
EventConst.PLAYER_MOVE = "playerMove"

return EventConst