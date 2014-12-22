
function __G__TRACKBACK__(errorMessage)
    print("----------------------------------------")
    print("LUA ERROR: " .. tostring(errorMessage) .. "\n")
    print(debug.traceback("", 2))
    print("----------------------------------------")
end

-- 设置查找目录的优先级
-- updates > res
cc.FileUtils:getInstance():setPopupNotify(false)
cc.FileUtils:getInstance():purgeCachedEntries()
cc.FileUtils:getInstance():addSearchPath("updates/")
cc.FileUtils:getInstance():addSearchPath("updates/res")
cc.FileUtils:getInstance():addSearchPath("updates/src")
cc.FileUtils:getInstance():addSearchPath("res/")
cc.FileUtils:getInstance():addSearchPath("src/")

-- package.path = package.path .. ";src/"

cc.LuaLoadChunksFromZIP("updater.zip")
package.loaded["updater.UpdateScene"] = nil
require("updater.UpdateScene")

