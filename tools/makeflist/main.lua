require("framework.init")
require("makeFlist")

if device.platform == "windows" then
	-- 休眠3秒
	os.execute("ping -n 1 127.0.0.1>nul")
	-- 关闭此进程
	os.execute("tskill player3")
end