--[[
	动画配置表
	暂定样式如下：
	local animationConfig = {
		["zw1"] = {
			parts = {
				"body0101",
				"head0101",
				"shadow0101",
				"shoulder0101",
				"weapon0103",
			},
			actions = {
				"move",
				"attack",
				"die",
			},
			actionFrames = {
				["move"] = 8,
				["attack"] = 8,
				["die"] = 1,
			}
		}
	}
--]]

local AnimationConfig = {
	["zw1"] = {
		parts = {
			"body0101",
			"head0101",
			"shadow0101",
			"shoulder0101",
			"weapon0101",
		},
		actions = {
			"move",
			"attack",
			"die",
			"stand",
		},
		actionFrames = {
			["move"] = 8,
			["attack"] = 8,
			["die"] = 1,
			["stand"] = 2,
		},
	},
	["guanyu"] = {
		parts = {
			"wj04", -- 像是这一种，就是单独的序列帧，这是关羽武将，由于武将比较唯一，所以无法复用部位
		},
		actions = {
			"attack",
			"move",
			"die",
		},
		actionFrames = {
			["attack"] = 9,
			["move"] = 8,
			["die"] = 1,
		},
	},
}

return AnimationConfig