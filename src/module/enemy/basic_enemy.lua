--[[
	敌人类
--]]

BasicEnemyConst = {}
BasicEnemyConst.SPEED = 5
BasicEnemyConst.BLOCK_TIME = 0.6 -- 通过每个方块所需要的时间

local BasicEnemy = class("BasicEnemy", Player)

BasicEnemy.ctor = function(self, charId)
	BasicEnemy.super.ctor(self, charId)
end

BasicEnemy.generateDestinationPos = function(self)
	local x, y = self:getPosition()
	local blocks = Map.getAroundBlockByPos(x, y, {depth = 20})
	local maxLength, maxDir = 0, "none"

	for k, v in pairs(blocks) do
		if #v > maxLength then
			maxLength = #v
			maxDir = k
		end
	end

	if maxLength == 0 then
		return false
	end

	return true, maxDir, maxLength, blocks[maxDir][maxLength]
end

BasicEnemy.start = function(self)
	local result, dir, length, block = self:generateDestinationPos()
	if not result then
		self:stand()
		return
	end

	self.destination = {
		pos = Map.getPosByRowAndCol(block.row, block.col),
		length = length,
		dir = dir,
	}

	self:move(dir)
end

BasicEnemy.move = function(self, dir)
	-- 播放动画
	if self.curDir ~= AnimationConst.DIRS_MAP[dir] or self.status ~= "move" then
		self.curDir = AnimationConst.DIRS_MAP[dir]
		self.animation:playAction(AnimationConst.ACTION_MOVE, self.curDir, {loop = true})

		self.status = "move"
	end

	-- 移动
	local moveAction = cc.MoveTo:create(self.destination.length * BasicEnemyConst.BLOCK_TIME, self.destination.pos)
	local finalAction = cc.CallFunc:create(function()
		self:start()
	end)
	
	local sequence = transition.sequence({
		moveAction,
		finalAction,
	})

	self:runAction(sequence)
end

-- 函数名有待斟酌，这里实际上并不一定掉头，而是选择剩余3个方向中可走的方向
BasicEnemy.moveOpposite = function(self)
	if self.isMovingOpposite then
		return
	end

	transition.stopTarget(self)
	
	self.isMovingOpposite = true

	local x, y = self:getPosition()
	local blocks = Map.getAroundBlockByPos(x, y, {depth = 20})
	blocks[self.destination.dir] = nil

	for k, v in pairs(blocks) do
		if #v > 0 then
			self.destination = {
				pos = Map.getPosByRowAndCol(v[#v].row, v[#v].col),
				length = #v,
				dir = k,
			}

			self:move(k)

			return
		end
	end

	self:stand()
end

local oldStand = BasicEnemy.stand
BasicEnemy.stand = function(self, params)
	transition.stopTarget(self)
	oldStand(self, params)
end

BasicEnemy.shouldBeOpposite = function(self, mine)
	local mineX, mineY = mine:getPosition()
	local selfX, selfY = self:getPosition()

	if selfX >= mineX and self.destination.dir == "right" then
		return false
	elseif selfX <= mineX and self.destination.dir == "left" then
		return false
	elseif selfY >= mineY and self.destination.dir == "up" then
		return false
	elseif selfY <= mineY and self.destination.dir == "down" then
		return false
	end

	return true
end

BasicEnemy.hasMineAround = function(self, mine)
	if not mine then
		return false
	end

	local selfX, selfY = self:getPosition()
	local blocks = Map.getAroundBlockByPos(selfX, selfY)
	local mineX, mineY = mine:getPosition()
	local mineRow, mineCol = Map.getRowAndColByPos(mineX, mineY)

	for _, v in pairs(blocks) do
		for _, block in pairs(v) do
			if block.row == mineRow and block.col == mineCol then
				return true
			end
		end
	end

	return false
end

BasicEnemy.getMovingOpposite = function(self)
	return self.isMovingOpposite
end

BasicEnemy.resetMovingOpposite = function(self)
	self.isMovingOpposite = false
end

BasicEnemy.attack = function(self, params)
end

return BasicEnemy