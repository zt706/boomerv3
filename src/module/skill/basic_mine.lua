--[[
	炸弹基类，也是最简单的炸弹
--]]

local BasicMine = class("BasicMine", function()
	return display.newNode()
end)

BasicMine.ctor = function(self, id)
	local skillConfig = InfoSkill[id]
	if not skillConfig then
		Logger.warn("该技能不存在", id)
		return
	end

	local bg = display.newSprite(SkillButtonConst.PATH .. skillConfig.res)
	self.bg = bg
	self:add(bg)
end

BasicMine.boom = function(self)
	-- 暂时用一大一小表示爆炸效果
	local scaleSmallerAction = cc.ScaleTo:create(0.2, 0.6)
	local scaleBiggerAction = cc.ScaleTo:create(0.2, 0.8)

	local sequence = transition.sequence({
		scaleSmallerAction,
		scaleBiggerAction,
	})

	self:runAction(cc.RepeatForever:create(sequence))

	--!! 这里需要注册一个事件监听，监听主角移动的特效，如果主角移动以后，当完全离开这个方块，方块的阻挡就会变为1
	-- 当爆炸以后，这个方块阻挡会再次清零
	local callback = handler(self, self.montiorPlayerMove)
	EventMgr.registerEvent(EventConst.PLAYER_MOVE, callback)

	self:performWithDelay(function()
		transition.stopTarget(self)

		self:removeChild(self.bg)

		-- 这里会有一个很短的爆炸特效，这里获取周围包括自己的不是阻挡的方块
		local blocks = Map.getAroundBlockByPos(self:getPosition())
		local rectNodes = {}
		-- 给这几个方向添加一个黄色的方块，作为爆炸特效
		for _, v in pairs(blocks) do
			local rectNode = display.newRect(cc.rect(-20, -20, 40, 40), {fillColor = cc.c4f(1, 1, 0, 0.4)})
			local pos = Map.getPosByRowAndCol(v.row, v.col)
			rectNode:setPosition(pos.x, pos.y)
			self:getParent():addChild(rectNode)

			rectNodes[#rectNodes + 1] = rectNode
		end

		self:getParent():performWithDelay(function()
			for _, v in pairs(rectNodes) do
				self:getParent():removeChild(v)
			end
		end, 0.2)

		-- 这里需要结算下爆炸的结果
		-- 需要统计这几个方块上的角色和障碍物，然后对他们施加伤害
		-- 角色就直接挂掉
		EventMgr.triggerEvent(EventConst.MINE_BOOM, blocks)
		-- 障碍物就清楚掉
		EventMgr.triggerEvent(EventConst.OBSTACLE_BOOM, blocks)

		--!! 反注册监听事件
		EventMgr.unregisterEvent(EventConst.PLAYER_MOVE, callback)

		-- 方块阻挡全部清零
		Map.resetBlocksByRowsAndCols(blocks)
	end, 2)
end

-- 监听玩家移动，以判断是否需要重置炸弹方块为阻挡
-- 传入玩家的包围盒，和该炸弹的包围盒一起进行比较，当两者没有相交，即表示玩家离开炸弹范围
BasicMine.montiorPlayerMove = function(self, playerBoundingBox)
	local mineRow, mineCol = Map.getRowAndColByPos(self:getPosition())
	local mineRect = Map.getRectByRowAndCol(mineRow, mineCol)

	if cc.rectIntersectsRect(mineRect, playerBoundingBox) then
		return
	end

	print("玩家离开包围盒")
	-- 玩家一旦离开这个炸弹方块，炸弹方块设置阻挡为1
	Map.setBlockByRowAndCol(mineRow, mineCol)
end

return BasicMine