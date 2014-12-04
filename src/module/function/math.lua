--[[
	一些简单的数学函数，扩展math方法
--]]

-- 判断(x, y)是否在以(cx, cy)为圆心，r为半径的园内
math.isInCircle = function(x, y, cx, cy, r)
	local r1 = (x - cx) * (x - cx) + (y - cy) * (y - cy)
	return r1 <= r * r
end

-- 获取两个矩形的相交矩形
math.getIntersectsRect = function(rect1, rect2)

	local rect1MinX, rect1MinY = cc.rectGetMinX(rect1), cc.rectGetMinY(rect1)
	local rect1MaxX, rect1MaxY = cc.rectGetMaxX(rect1), cc.rectGetMaxY(rect1)

	local rect2MinX, rect2MinY = cc.rectGetMinX(rect2), cc.rectGetMinY(rect2)
	local rect2MaxX, rect2MaxY = cc.rectGetMaxX(rect2), cc.rectGetMaxY(rect2)

	local x = rect1MinX > rect2MinX and rect1MinX or rect2MinX
	local y = rect1MinY > rect2MinY and rect1MinY or rect2MinY
	local w = (rect1MaxX < rect2MaxX and rect1MaxX or rect2MaxX) - x
	local h = (rect1MaxY < rect2MaxY and rect1MaxY or rect2MaxY) - y

	return cc.rect(x, y, w, h)	
end