--[[
	几个不规则图片分离和聚合的特效
--]]

local DividedEffectConst = {}
DividedEffectConst.RES_PATH = "module/effect/transit_pic.plist"
DividedEffectConst.RES_URL_LEFT = "#transit_left.png"
DividedEffectConst.RES_URL_BOTTOM = "#transit_bottom.png"
DividedEffectConst.RES_URL_UP = "#transit_up.png"

DividedEffectConst.QUIT_EFFECT_TIME = 0.5
DividedEffectConst.QUIT_TIME = 0.5
DividedEffectConst.ENTER_EFFECT_TIME = 0.5
DividedEffectConst.ENTER_TIME = 0.5
DividedEffectConst.ENTER_DELAY_TIME = 0.1

local DividedEffect = class("DividedEffect", function()
	return display.newNode()
end)

DividedEffect.ctor = function(self)
	self:init()	
end

DividedEffect.init = function(self)
	-- 预先加载图片
	MgrUtils.getMgr("res"):loadPlist(DividedEffectConst.RES_PATH)

	self.picture_left = display.newSprite(DividedEffectConst.RES_URL_LEFT)
	self:addChild(self.picture_left)

	self.picture_bottom = display.newSprite(DividedEffectConst.RES_URL_BOTTOM)
	self:addChild(self.picture_bottom)

	self.picture_up =  display.newSprite(DividedEffectConst.RES_URL_UP)
	self:addChild(self.picture_up)

	local size = self.picture_up:getContentSize()
	self.scaleX = display.width / size.width
	self.scaleY = display.height / size.height

	if self.scaleX > 1 then
		self.picture_left:setScaleX(self.scaleX)
		self.picture_up:setScaleX(self.scaleX)
		self.picture_bottom:setScaleX(self.scaleX)
	end
	
	if self.scaleY > 1 then
		self.picture_left:setScaleY(self.scaleY)
		self.picture_up:setScaleY(self.scaleY)
		self.picture_bottom:setScaleY(self.scaleY)
	end
end

-- 分开状态
DividedEffect.alginToDivided = function(self)
	self.picture_left:setPosition(cc.p(-display.cx, display.cy))
	self.picture_up:setPosition(cc.p(display.cx, 3 * display.cy))
	self.picture_bottom:setPosition(cc.p(display.cx, -display.cy))
end

-- 聚合状态
DividedEffect.alginToConverged = function(self)
	self.picture_left:setPosition(cc.p(display.cx, display.cy))
	self.picture_up:setPosition(cc.p(display.cx, display.cy))
	self.picture_bottom:setPosition(cc.p(display.cx, display.cy))
end

DividedEffect.gotoConverged = function(self, params)
	params = params or {}
	local onComplete = params.onComplete or function() end
	local needEffect = params.needEffect or true -- 默认播放聚合特效

	local actionLeft = cc.MoveTo:create(DividedEffectConst.QUIT_EFFECT_TIME, cc.p(display.cx, display.cy))
	local actionUp = cc.MoveTo:create(DividedEffectConst.QUIT_EFFECT_TIME, cc.p(display.cx, display.cy))
	local actionBottom = cc.MoveTo:create(DividedEffectConst.QUIT_EFFECT_TIME, cc.p(display.cx, display.cy))
	local actionEnd =  cc.CallFunc:create(onComplete)
	
	if needEffect then
		self.picture_up:runAction(actionUp)
		self.picture_left:runAction(actionLeft)
		self.picture_bottom:runAction(actionBottom)
		self.picture_bottom:runAction(transition.sequence({actionBottom, cc.DelayTime:create(DividedEffectConst.ENTER_DELAY_TIME), actionEnd}) )
	else
		onComplete()
	end
end

DividedEffect.gotoDivided = function(self, params)
	params = params or {}
	local onComplete = params.onComplete or function() end

	local actionLeft = cc.MoveTo:create(DividedEffectConst.ENTER_EFFECT_TIME, cc.p(-display.cx, display.cy))
	local actionUp = cc.MoveTo:create(DividedEffectConst.ENTER_EFFECT_TIME, cc.p(display.cx, 3 * display.cy))
	local actionBottom = cc.MoveTo:create(DividedEffectConst.ENTER_EFFECT_TIME, cc.p(display.cx, -display.cy))
	local actionEnd =  cc.CallFunc:create(onComplete)

	self.picture_up:runAction(actionUp)
	self.picture_left:runAction(actionLeft)
	self.picture_bottom:runAction(actionBottom)
	self.picture_bottom:runAction(transition.sequence({actionBottom, cc.DelayTime:create(DividedEffectConst.ENTER_DELAY_TIME), actionEnd}))
end

return DividedEffect