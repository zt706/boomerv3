--[[
	寻路辅助函数
--]]

local SearchPathUtils = {}

SearchPathUtils.getAPath = function(map, startPoint, endPoint, four_dir)
	AStar:init(map, startPoint, endPoint, four_dir and true or false)
	local path = AStar:searchPath()
	if not path or #path == 1 then
		return nil
	end

	-- 得到的路径其实需要反转一下才是从起始到终点
	local resultPath = {}
	for i, v in ipairs(path) do
		resultPath[#path - i + 1] = v
	end

	return resultPath
end

return SearchPathUtils