--[[
	地图数据，理论上应该由表生成，或者通过地图编辑器生成，目前简单手动生成
		阻挡信息，0：可以行走，1：阻挡
		背景图路径
		方块贴图：0（正常行走方块），1（阻挡方块），2-...（障碍物方块，可能有多种）
--]]

local MapConfig = {
	blockRes = {
		[0] = "module/map/normal.png",
		[1] = "module/map/block.png",
		[2] = "module/map/obstacle.png",
	},
	["1"] = {
		blocks = {
			[1] = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
			[2] = {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
			[3] = {1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1},
			[4] = {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
			[5] = {1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1},
			[6] = {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
			[7] = {1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1, 0, 1},
			[8] = {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
			[9] = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
		},
		backgroundRes = "module/map/map_1.jpg",
	},
	["2"] = {
		blocks = {
			[1] = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
			[2] = {1, 0, 2, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
			[3] = {1, 0, 1, 0, 1, 2, 1, 0, 1, 0, 1, 2, 1, 2, 1, 0, 1},
			[4] = {1, 0, 2, 0, 0, 0, 2, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
			[5] = {1, 0, 1, 0, 1, 2, 1, 0, 1, 0, 1, 2, 1, 2, 1, 0, 1},
			[6] = {1, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 1},
			[7] = {1, 0, 1, 2, 1, 0, 1, 2, 1, 0, 1, 0, 1, 2, 1, 0, 1},
			[8] = {1, 0, 0, 0, 0, 0, 0, 0, 2, 0, 0, 2, 0, 0, 0, 0, 1},
			[9] = {1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1, 1},
		},
		backgroundRes = "module/map/map_1.jpg",
	},
}

return MapConfig