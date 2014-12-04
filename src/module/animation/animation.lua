--[[
	动画处理，仅针对基本的动画加载，播放和停止，实际上各种动画的效果，还是应该由其他类处理
	接受的动画样式格式：参见info_character.lua，这里记录所有动画资源配置表
--]]

local Animation = class("Animation", function()
	return display.newNode()
end)

Animation.ctor = function(self)
	self.actions = {}
end

Animation.loadAnimation = function(self, animationConfig)
	self.partSprites = {}

	local parts = animationConfig.parts or {}
	local actions = animationConfig.actions or {}
	local actionFrames = animationConfig.actionFrames or {}

	for _, part in pairs(parts) do
		MgrUtils.getMgr("res"):loadCharRes(part, "plist")
		
		local sprite = display.newSprite()
		self.partSprites[part] = sprite
		self:addChild(sprite)
		self.actions[part] = {}

		for _, action in pairs(actions) do
			self.actions[part][action] = self.actions[part][action] or {}

			for _, dir in pairs(AnimationConst.DIRS) do
				--!! 临时处理，因为测试的plist中包含，body0101_die.png和body0101_attack_30008.png的样式
				local filename = part .. "_" .. AnimationConst.ActionMapping[action]
				if actionFrames[action] > 1 then
					filename = filename .. "_" .. dir .. "%04d.png"
				else
					filename = filename .. ".png"
				end

				self.actions[part][action][dir] = display.newFrames(filename, 0, actionFrames[action])
			end
		end
	end

	if DEBUG == 1 then
		local debugRect = display.newRect(cc.rect(-MapConst.DEFAULT_BLOCK_WIDTH / 2, -MapConst.DEFAULT_BLOCK_HEIGHT / 2, MapConst.DEFAULT_BLOCK_WIDTH, MapConst.DEFAULT_BLOCK_HEIGHT), {borderColor = cc.c4f(1, 1, 1, 1)})
		self:addChild(debugRect, 100)
	end
end

Animation.stopAction = function(self)
	for _, v in pairs(self.partSprites) do
		transition.stopTarget(v)
	end
end

--[[
	action动画行为，dir动画方向
	可选参数：
		loop，是否循环播放，默认不循环
		removeWhenFinished，仅针对一次性动画，动画播完以后，是否删除动画，默认不删除
		onComplete，仅针对一次性动画的结束后回调
		delay，选择可以延时多长时间播放动画
--]]
Animation.playAction = function(self, action, dir, params)
	self:stopAction()

	local isFlipX = dir > 0 and true or false -- 实际是否转向判断
	dir = math.abs(dir) -- 将负数方向进行转正
	
	params = params or {}
	local loop = params.loop and true or false
	local delay = params.delay or 0

	for k, v in pairs(self.partSprites) do
		if v and self.actions[k] and self.actions[k][action] and self.actions[k][action][dir] then
			local ani = display.newAnimation(self.actions[k][action][dir], AnimationConst.ANIMATION_RATE)
			if loop then
				v:playForever(ani, delay)
			else
				local onComplete = params.onComplete or function() end
				local removeWhenFinished = params.removeWhenFinished and true or false
				
				v:playOnce(ani, removeWhenFinished, onComplete, delay)
			end

			v:setFlippedX(isFlipX)
		end
	end
end

return Animation