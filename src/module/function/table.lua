--[[
	table的扩展
--]]

-- desciption 输出内容前的描述，默认为"table"
-- nesting 嵌套层次，默认为20
-- 返回table，存储需要打印table的每行信息
-- 之所以不进行table.concat，是因为quick打印的时候有前缀信息，会不美观
table.getTableStr = function(t, desciption, nesting)
	if type(t) ~= "table" then
		return {}
	end

	nesting = nesting or 20
	desciption = desciption or "<table>"
	
	local lookupTable = {}
	local result = {}

	local _v = function(v)
		if type(v) == "string" then
			v = "\"" .. v .. "\""
		end
		return tostring(v)
	end

	local _dump
	_dump = function(value, desciption, indent, nest, keylen)
		desciption = desciption or "<table>"
		spc = ""
		if type(keylen) == "number" then
			spc = string.rep(" ", keylen - string.len(_v(desciption)))
		end
		if type(value) ~= "table" then
			result[#result +1 ] = string.format("%s%s%s = %s", indent, _v(desciption), spc, _v(value))
		elseif lookupTable[value] then
			result[#result +1 ] = string.format("%s%s%s = *REF*", indent, desciption, spc)
		else
			lookupTable[value] = true
			if nest > nesting then
				result[#result +1 ] = string.format("%s%s = *MAX NESTING*", indent, desciption)
			else
				result[#result +1 ] = string.format("%s%s = {", indent, _v(desciption))
				local indent2 = indent.."    "
				local keys = {}
				local keylen = 0
				local values = {}
				for k, v in pairs(value) do
					keys[#keys + 1] = k
					local vk = _v(k)
					local vkl = string.len(vk)
					if vkl > keylen then keylen = vkl end
					values[k] = v
				end
				table.sort(keys, function(a, b)
					if type(a) == "number" and type(b) == "number" then
						return a < b
					else
						return tostring(a) < tostring(b)
					end
				end)
				for i, k in ipairs(keys) do
					_dump(values[k], k, indent2, nest + 1, keylen)
				end
				result[#result +1] = string.format("%s}", indent)
			end
		end
	end
	_dump(t, desciption, "- ", 1)

	return result
end

table.print = function(t, desciption, nesting)
	if type(t) ~= "table" then
		return
	end

	local result = table.getTableStr(t, desciption, nesting)
	for i, line in ipairs(result) do
		Logger.old_print(line)
	end
end

-- 将一张表保存到一个指定的文件里去
table.save = function(t, filename)
	if type(t) ~= "table" then
		Logger.error("请确保传入的是table")
		return
	end

	Logger.warn("尚未实现")
end

-- 清空table表格中所有value为nil的键值对
table.removeAllNilValue = function(t)
	local new = {}
	for _, v in pairs(t) do
		if v then
			new[#new + 1] = v
		end
	end

	return new
end