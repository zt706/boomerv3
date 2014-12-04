--[[
	管理器辅助函数类
--]]

local MgrUtils = {}

MgrUtils.resMgrIns = ResMgr:new()

MgrUtils.getMgr = function(type)
	if type == "res" then
		return MgrUtils.resMgrIns
	end
end

return MgrUtils