--[[
	动画常量
--]]

local AnimationConst = {}

AnimationConst.ACTION_MOVE = "move"
AnimationConst.ACTION_ATTACK = "attack"
AnimationConst.ACTION_DIE = "die"
AnimationConst.ACTION_STAND = "stand"

AnimationConst.ACTION_COST = 0.4

-- 动作映射表
-- 减少某些动作，例如stand行为就是取attck的第一张图
--!! 目前可能从简，应该就直接是另外取一张stand图片，而不是为了压缩内存
AnimationConst.ActionMapping = {
	["move"] = "move",
	["attack"] = "attack",
	["die"] = "die",
	["stand"] = "attack",
}

AnimationConst.DIR_UP = 3
AnimationConst.DIR_DOWN = -1
AnimationConst.DIR_LEFT = 2
AnimationConst.DIR_RIGHT = -2

--!! 映射处理，目前不规范，先简略一下，谁叫咱没资源
AnimationConst.DIRS = {
	AnimationConst.DIR_UP,
	-AnimationConst.DIR_DOWN,
	AnimationConst.DIR_LEFT,
	-AnimationConst.DIR_RIGHT,
}

AnimationConst.DIRS_MAP = {
	["up"] = AnimationConst.DIR_UP,
	["down"] = AnimationConst.DIR_DOWN,
	["left"] = AnimationConst.DIR_LEFT,
	["right"] = AnimationConst.DIR_RIGHT,
}

AnimationConst.DEFAULT_DIR = AnimationConst.DIR_RIGHT

AnimationConst.ANIMATION_RATE = 1 / 8

return AnimationConst