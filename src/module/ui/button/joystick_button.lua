--[[
	操纵杆
--]]

local scheduler = require("framework.scheduler")
local socket = require("socket") -- 仅仅是为了获得毫秒级的时间函数而引用

local JoyStickButton = class("JoyStickButton", function()
	return display.newLayer()
end)

JoyStickButton.ctor = function(self)
	self:init()
end

JoyStickButton.init = function(self)
	-- 添加底图
	self.controlWheel = display.newSprite(JoyStickButtonConst.BACKGROUND_PATH)
	self.controlWheel:setContentSize(JoyStickButtonConst.WIDTH, JoyStickButtonConst.HEIGHT)
	self:addChild(self.controlWheel)

	-- 添加光圈，光圈坐标位于地图中央
	self.tinyCircle = display.newSprite(JoyStickButtonConst.CIRCLE_PATH)
	local xScale = JoyStickButtonConst.CIRCLE_WIDTH / self.tinyCircle:getContentSize().width
	local yScale = JoyStickButtonConst.CIRCLE_HEIGHT / self.tinyCircle:getContentSize().height
	self.tinyCircle:setScale(xScale, yScale)
	display.align(self.tinyCircle, display.CENTER)
	self:addChild(self.tinyCircle)

	-- 添加4个方向键
	local directionButtons = {
		{name = "up", degrees = {left = 45, right = 135}}, -- 角度区间 [left, right)
		{name = "down", degrees = {left = -135, right = -45}},
		{name = "right", degrees = {left = -45, right = 45}},
		{name = "left", degrees = {left = 135, right = -135}}, -- 这里原本应该是135～-135之间，不过由于这个区间不好计算，好在这里是最后一个
	}
	
	self.directionButtonInfos = {}
	for _, button in ipairs(directionButtons) do
		self.directionButtonInfos[#self.directionButtonInfos + 1] = {
			button = self:createDirectionButton(button.name),
			degrees = button.degrees,
		}
	end

	self:setTouchEnabled(true)
	-- 默认吞噬事件，地图层不接受点击
	self:swallowEnabled(true)
	self:addNodeEventListener(cc.NODE_TOUCH_EVENT, function(event)
		if event.name == "ended" then
			self:onReleased()
		end

		-- isInBigCircle，在操纵杆圆内，isInSmallCircle，在操纵杆无效圆内
		local isInBigCircle = math.isInCircle(event.x, event.y, JoyStickButtonConst.CENTER_X, JoyStickButtonConst.CENTER_Y, JoyStickButtonConst.RADIUS)
		local isInSmallCircle = math.isInCircle(event.x, event.y, JoyStickButtonConst.CENTER_X, JoyStickButtonConst.CENTER_Y, JoyStickButtonConst.INVALID_RADIUS)
		if  isInBigCircle and not isInSmallCircle then
			if event.name == "began" then
				self:onPressed(event.x, event.y)
			elseif event.name == "moved" then
				self:onMoved(event.x, event.y)
			end
		end

		return true
	end)
end

-- 是否吞噬事件，不再下穿
JoyStickButton.swallowEnabled = function(self, enabled)
	self:setTouchSwallowEnabled(enabled)
end

JoyStickButton.createDirectionButton = function(self, dir)
	local directionButton = {}

	directionButton.onPressed = function()
		if not directionButton.longTouchHander then
			directionButton.startTime = socket.gettime()
			directionButton.longTouchHander = scheduler.scheduleUpdateGlobal(function()
				self:move(dir)
			end)
		end
	end

	directionButton.onReleased = function()
		if directionButton.longTouchHander then
			directionButton.endTime = socket.gettime()
			scheduler.unscheduleGlobal(directionButton.longTouchHander)
			directionButton.longTouchHander = nil
		end

		-- 添加一个延时，解决短按的情况下，控制对象漂移情况，允许做一个move动画的时间
		local time = 0
		if directionButton.endTime - directionButton.startTime < 0.3 then
			time = 0.3
		end

		self:performWithDelay(function()
			self:stand()
		end, time)
	end

	return directionButton
end

-- 设置化控制节点
JoyStickButton.setControlNode = function(self, node)
	self.controlNode = node
end

-- 传递方向事件，由实际控制对象移动
JoyStickButton.move = function(self, dir)
	if not self.controlNode then
		return
	end

	if self.controlNodeMoving then
		return
	end

	self.controlNodeMoving = true
	
	if self.controlNode.move then
		self.controlNode:move(dir)
	else
		Logger.warn("操纵杆对象应该实现move方法！！！")
	end
	
	self.controlNodeMoving = false
end

-- 让操纵的对象执行stand方法
JoyStickButton.stand = function(self)
	if self.controlNode and self.controlNode.stand then
		self.controlNode:stand()
	else
		Logger.warn("操纵杆对象应该实现stand方法！！！")
	end
end

--[[
press
	启动一个定时器
		设置光圈坐标
		记录之前按下的方向键
		检查光圈坐标是否在方向键包围盒内
			存在，启动方向键的press方法，更新方向键
		判断方向键是否不同，不同，则让老的方向键执行release方法
--]]
JoyStickButton.onPressed = function(self, x, y)
	self.tinyCircle.curX = x - JoyStickButtonConst.CENTER_X
	self.tinyCircle.curY = y - JoyStickButtonConst.CENTER_Y

	if not self.tinyCircle.longTouchHander then
		self.tinyCircle.longTouchHander = scheduler.scheduleUpdateGlobal(function()
			self.tinyCircle:setPosition(self.tinyCircle.curX, self.tinyCircle.curY)

			-- 计算该点的角度
			local radians = cc.pToAngleSelf(cc.p(self.tinyCircle.curX, self.tinyCircle.curY)) -- 算出的是弧度
			local degrees = math.radian2angle(radians) -- 这里转换成角度0~180，-180~0

			local oldPressedButton = self.controlWheel.pressedButton
			self.controlWheel.pressedButton = nil

			for i, v in ipairs(self.directionButtonInfos) do
				if i == 4 then
					-- 第四个区间不好处理，直接左右做了，因为不可能大于135，还小于－135
					v.button.onPressed()

					self.controlWheel.pressedButton = v.button
				elseif v.degrees.left <= degrees and degrees < v.degrees.right then
					v.button.onPressed()

					self.controlWheel.pressedButton = v.button
					break
				end
			end

			if oldPressedButton and oldPressedButton ~= self.controlWheel.pressedButton then
				oldPressedButton.onReleased()
			end
		end)
	end
end

--[[
	release
		光圈复位
		关闭定时器
		已经按下的方向键执行release方法
--]]
JoyStickButton.onReleased = function(self)
	if self.tinyCircle.longTouchHander then
		scheduler.unscheduleGlobal(self.tinyCircle.longTouchHander)
		self.tinyCircle.longTouchHander = nil
	end

	self.tinyCircle.curX = 0
	self.tinyCircle.curY = 0
	self.tinyCircle:setPosition(self.tinyCircle.curX, self.tinyCircle.curY)

	if self.controlWheel.pressedButton then
		self.controlWheel.pressedButton.onReleased()
		self.controlWheel.pressedButton = nil
	end
end

--[[
	move
		更新光圈坐标
		其他主要行为，均在定时器中完成
--]]
JoyStickButton.onMoved = function(self, x, y)
	self.tinyCircle.curX = x - JoyStickButtonConst.CENTER_X
	self.tinyCircle.curY = y - JoyStickButtonConst.CENTER_Y
end

return JoyStickButton