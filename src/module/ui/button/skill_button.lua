--[[
	技能按钮，主要就是带冷却时间，在战斗中显示
--]]

local SkillButton = class("SkillButton", function()
	return display.newNode()
end)

SkillButton.ctor = function(self, skillId, callback)
	self:init(skillId, callback)
end

SkillButton.init = function(self, skillId, callback)
	if not InfoSkill[skillId] then
		Logger.warn("该技能不存在：", skillId)
		return
	end

	self.skillId = skillId
	self.callback = callback or function() end -- 技能回调
	self.skillInfo = InfoSkill[skillId]

	-- 假设意见从技能表中获取资源了
	self.skillBg = display.newSprite(SkillButtonConst.PATH .. self.skillInfo.res) -- 底图
	self:addChild(self.skillBg)

	-- 这里设置一张技能遮罩，而且必须是从100开始转置的一张图
	-- 因为最后这个技能开始实行冷却时还需要讲动作倒过来，不然就无法达到预期效果
	self.mask = display.newProgressTimer(SkillButtonConst.MASK_PATH, display.PROGRESS_TIMER_RADIAL) -- 技能遮罩
	self.mask:setPosition(self.skillBg:getPosition())
	self.mask:setOpacity(SkillButtonConst.MASK_OPACITY)
	self.mask:setReverseDirection(true)
	self:addChild(self.mask)

	self:setTouchEnabled(true)
	self.isTouching = false -- 设置被点击以后不允许再次被点击
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function()
		if self.isTouching then
			return
		end

		self.isTouching = true -- 不允许被点击

		self.callback() -- 执行回调

		self:startCD() -- 开始冷却
	end)
end

SkillButton.startCD = function(self)
	self.mask:setPercentage(100)

	local action1 = cc.ProgressTo:create(self.skillInfo.duration, 0)
	local action2 = cc.CallFunc:create(function()
		-- 允许技能可以被点击
		self.isTouching = false
	end)
	self.mask:runAction(transition.sequence({action1, action2}))
end

return SkillButton