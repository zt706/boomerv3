--[[
	为动画需求提供一些辅助函数
--]]

local AnimationUtils = {}

-- 四方向游戏
AnimationUtils.getDir = function(startPoint, endPoint)
	if startPoint.col == endPoint.col and startPoint.row == endPoint.row then
		return nil
	end

	if startPoint.col > endPoint.col then
		return AnimationConst.DIR_LEFT
	elseif startPoint.col < endPoint.col then
		return AnimationConst.DIR_RIGHT
	elseif startPoint.row > endPoint.row then
		return AnimationConst.DIR_DOWN
	elseif startPoint.row < endPoint.row then
		return AnimationConst.DIR_UP
	else
		return nil
	end
end

return AnimationUtils