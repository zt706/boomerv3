--[[
	角色，目前主要处理动画和特效等效果
--]]

local Character = class("Character", function()
	return display.newNode()
end)

Character.ctor = function(self, charId)
	self:init(charId)
end

Character.init = function(self, charId)
	self.charId = charId

	local animationConfig = InfoCharacter[charId]
	if not animationConfig then
		Logger.error("角色动画配置出错，不存在！！！")
		return
	end

	self.animation = Animation.new()
	self.animation:loadAnimation(animationConfig)
	self:addChild(self.animation)

	self.curDir = AnimationConst.DEFAULT_DIR
end

-- 准确来说这里应该传入的是两个点，然后由A*算法得到一个路径
Character.move = function(self, startPoint, endPoint, params)
	params = params or {}
	self.moveOnComplete = params.onComplete or function() end

	-- 通过起点和终点生成一条路径
	local path = SearchPathUtils.getAPath(Map.getBlockInfo(), startPoint, endPoint, true)
	if not path then
		self.moveOnComplete()
		return
	end

	local moveStep
	moveStep = function(path, curStep)
		if curStep >= #path then
			self.moveOnComplete()
			self:stand()
			return
		end

		local oldStep = curStep
		curStep = curStep + 1

		-- 播放动画
		local dir = AnimationUtils.getDir(path[oldStep], path[curStep])
		self.animation:playAction(AnimationConst.ACTION_MOVE, dir, {loop = true})
		self.curDir = dir

		-- 这里才是真正移动
		local startPoint = Map.getPosByRowAndCol(path[oldStep].row, path[oldStep].col)
		local endPoint = Map.getPosByRowAndCol(path[curStep].row, path[curStep].col)
		local xDis = endPoint.x - startPoint.x
		local yDis = endPoint.y - startPoint.y

		local actionMove = CCMoveBy:create(AnimationConst.ACTION_COST, ccp(xDis, yDis))
		local actionMoveEnd = CCCallFunc:create(function()
			self.animation:stopAction()
			moveStep(path, curStep)
		end)

		self:runAction(transition.sequence({actionMove, actionMoveEnd}))
	end

	moveStep(path, 1)
end

--!! 应该传入一个target
--!! 考虑到炸弹人中，实际上是没有攻击动画，这个动画应该当做放炸弹动画
Character.attack = function(self, params)
	params = params or {}
	self.attackOnComplete = params.onComplete or function() end
	self.curDir = self.curDir or AnimationConst.DEFAULT_DIR

	self.animation:playAction(AnimationConst.ACTION_ATTACK, self.curDir, {onComplete = self.attackOnComplete})
end

Character.die = function(self, params)
	params = params or {}
	self.dieOnComplete = params.onComplete or function() end
	self.curDir = self.curDir or AnimationConst.DEFAULT_DIR

	self.animation:playAction(AnimationConst.ACTION_DIE, self.curDir, {onComplete = self.dieOnComplete})
end

-- 站立就取攻击的第一张图
Character.stand = function(self, params)
	params = params or {}
	self.standOnComplete = params.onComplete or function() end
	self.curDir = self.curDir or AnimationConst.DEFAULT_DIR

	self.animation:playAction(AnimationConst.ACTION_STAND, self.curDir, {onComplete = self.standOnComplete})
end

return Character