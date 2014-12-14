--[[
	玩家类
		和character最大的不同在于，不能自动寻路，由操纵杆控制移动
--]]

local PlayerConst = {}
PlayerConst.SPEED = 2 -- 移动速度，目前水平和竖直方向移动速度为一样的

local Player = class("Player", function()
	return display.newNode()
end)

Player.ctor = function(self, charId)
	self:init(charId)
end

Player.init = function(self, charId)
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

	self.size = {width = MapConst.BLOCK_WIDTH - AnimationConst.PADDING, height = MapConst.BLOCK_HEIGHT - AnimationConst.PADDING}
end

--[[
	根据方向获取移动到的新的坐标，获取新的包围盒
	新的包围盒是否与阻挡地图块相交
		有相交，不可前行，stand
		无相交，移动到新的坐标去
--]]
Player.move = function(self, dir)
	if self.isMoving then
		return
	end

	local x, y = self:getPosition()
	
	if dir == "left" then
		x = x - PlayerConst.SPEED
	elseif dir == "right" then
		x = x + PlayerConst.SPEED
	elseif dir == "up" then
		y = y + PlayerConst.SPEED
	elseif dir == "down" then
		y = y - PlayerConst.SPEED
	end

	local getPlayerBoundingBox = function(x, y)
		return cc.rect(x - self.size.width / 2, y - self.size.height / 2, self.size.width, self.size.height)
	end

	local newBox = getPlayerBoundingBox(x, y)
	local row, col = Map.getRowAndColByPos(self:getPosition())

	-- 任何一个前行的方向其实只有4个地图块与其相关
	local intersectsRects = {}
	for i = row - 1, row + 1 do
		for j = col - 1, col + 1 do
			local blockRect = Map.getRectByRowAndCol(i, j)
			if blockRect and cc.rectIntersectsRect(blockRect, newBox) then
				local isBlock = Map.getBlockByRowAndCol(i, j)
				table.insert(intersectsRects, {row = i, col = j, rect = blockRect, isBlock = isBlock})
			end
		end
	end

	--[[
		只有1个块相交：完全到达另外一个可以行走的方块
		两个块非阻挡的块相交：正在前往另一个可以行走的方块的路上
		两个块，一个阻挡一个非阻挡，这是一个不可前行的方向
		三个块那是不可能滴
		四个块，3个非阻挡，一个阻挡块，这就需要视情况，1/3宽度以内存在于非block区域的话，视作可以行走
	--]]
	if #intersectsRects == 2 then
		if intersectsRects[1].isBlock or intersectsRects[2].isBlock then
			Logger.warn("前方是阻挡地图块，不可前行")

			self:stand()
			return
		end
	elseif #intersectsRects == 3 then
		assert(false, "这是不可能滴，相交3个块")
	elseif #intersectsRects == 4 then
		local blockRects = {}
		for i = 1, 4 do
			if intersectsRects[i].isBlock then
				table.insert(blockRects, intersectsRects[i])
			end
		end

		if #blockRects ~= 1 then
			Logger.warn("超出相交区域1/3，不可能通过")

			self:stand()
			return
		end

		local blockRect = blockRects[1]

		-- 获取相交矩形，判断相交矩形的长宽只要一项大于玩家包围盒的1/3则判断不可以通过
		local rect = math.getIntersectsRect(blockRect.rect, newBox)
		if rect.width > self.size.width / 2 or rect.height > self.size.height / 2 then
			Logger.warn("超出相交区域1/3，不可能通过")

			self:stand()
			return
		end

		local oppoRect
		for i = 1, 4 do
			if blockRect.row ~= intersectsRects[i].row and blockRect.col ~= intersectsRects[i].col then
				oppoRect = intersectsRects[i]
				break
			end
		end

		if dir == "left" then
			x = x + PlayerConst.SPEED - self.size.width / 2
			y = cc.rectGetMidY(oppoRect.rect)
		elseif dir == "right" then
			x = x - PlayerConst.SPEED + self.size.width / 2
			y = cc.rectGetMidY(oppoRect.rect)
		elseif dir == "up" then
			x = cc.rectGetMidX(oppoRect.rect)
			y = y - PlayerConst.SPEED + self.size.height / 2
		elseif dir == "down" then
			x = cc.rectGetMidX(oppoRect.rect)
			y = y + PlayerConst.SPEED - self.size.height / 2
		end

		self.isMoving = true
		local action = cc.MoveTo:create(0.2, cc.p(x, y))
		local action2 = cc.CallFunc:create(function()
			self.isMoving = false
		end)
		self:runAction(transition.sequence({action, action2}))
		
		return
	end

	-- 播放动画
	if self.curDir ~= AnimationConst.DIRS_MAP[dir] or self.status ~= "move" then
		self.curDir = AnimationConst.DIRS_MAP[dir]
		self.animation:playAction(AnimationConst.ACTION_MOVE, self.curDir, {loop = true})

		self.status = "move"
	end

	-- 移动
	self:setPosition(x, y)
	
	-- 发射事件，玩家移动
	EventMgr.triggerEvent(EventConst.PLAYER_MOVE, newBox)
end

--!! 应该传入一个target
--!! 考虑到炸弹人中，实际上是没有攻击动画，这个动画应该当做放炸弹动画
Player.attack = function(self, params)
	params = params or {}
	self.attackOnComplete = params.onComplete or function() end
	self.curDir = self.curDir or AnimationConst.DEFAULT_DIR

	self.animation:playAction(AnimationConst.ACTION_ATTACK, self.curDir, {onComplete = self.attackOnComplete})

	self.status = "attack"
end

Player.die = function(self, params)
	params = params or {}
	self.dieOnComplete = params.onComplete or function() end
	self.curDir = self.curDir or AnimationConst.DEFAULT_DIR

	self.animation:playAction(AnimationConst.ACTION_DIE, self.curDir, {onComplete = self.dieOnComplete})

	self.status = "die"
end

-- 站立就取攻击的第一张图
Player.stand = function(self, params)
	params = params or {}
	self.standOnComplete = params.onComplete or function() end
	self.curDir = self.curDir or AnimationConst.DEFAULT_DIR

	self.animation:playAction(AnimationConst.ACTION_STAND, self.curDir, {onComplete = self.standOnComplete})

	self.status = "stand"
end

return Player