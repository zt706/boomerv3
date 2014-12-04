--[[
	震屏特效
--]]

local scheduler = require("framework.scheduler")

local Tween = {}

local init = function()
	Tween.stopShakeFuncs = {}
	setmetatable(Tween.stopShakeFuncs, {__mode = "k"})
end

------ 初始化相关 ------------
init()
------------------------------

--------- 震屏效果( 显示对象, 持续时间, 水平振幅, 垂直振幅, 震动次数 ) -----------
Tween.shake = function(node, duration, x, y, numShakes)
	local stopShakeFuncs = Tween.stopShakeFuncs
	local passtime = 0
	local handle = 0
	local initX, initY = node:getPosition()
	local lastOffsetX, lastOffsetY = 0, 0

	local update = function(dt)
		if tolua.isnull(node) then
			scheduler.unscheduleGlobal(handle)
			return
		end

		passtime = passtime +  dt	

		local percent = passtime / duration
		if percent > 1 and stopShakeFuncs[node] then
			stopShakeFuncs[node]()
			return
		end

		local amplitude = math.sin((percent * (2 * math.pi)) * numShakes)
		local decrease = 1 - percent
		local offsetX = (x * amplitude * decrease);
		local offsetY = (y * amplitude * decrease);
		node:setPositionX(node:getPositionX() - lastOffsetX + offsetX)
		node:setPositionY(node:getPositionY() - lastOffsetY + offsetY)
		lastOffsetX = offsetX
		lastOffsetY = offsetY
	end

	handle = scheduler.scheduleGlobal(update, 0)	

	stopShakeFuncs[node] = function()
		scheduler.unscheduleGlobal(handle)
		if not tolua.isnull(node) then
			node:setPosition(initX, initY)	
		end
		stopShakeFuncs[node] = nil
	end

	return handle
end

---- 停止震屏效果( 显示对象 ) ------------
Tween.stopShake = function(node)
	if Tween.stopShakeFuncs[node] then
		Tween.stopShakeFuncs[node]()
	end
end

return Tween