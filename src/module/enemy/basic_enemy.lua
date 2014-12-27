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
	local blocks = Map.getAroundBlockByPos(x, y, false, 20)
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

		-- 这里还需做些事
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
	local x, y = self:getPosition()
	
	if dir == "left" then
		x = x - BasicEnemyConst.SPEED
	elseif dir == "right" then
		x = x + BasicEnemyConst.SPEED
	elseif dir == "up" then
		y = y + BasicEnemyConst.SPEED
	elseif dir == "down" then
		y = y - BasicEnemyConst.SPEED
	end

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

BasicEnemy.attack = function(self, params)
end

return BasicEnemy