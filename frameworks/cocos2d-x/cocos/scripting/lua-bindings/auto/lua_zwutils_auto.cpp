#include "lua_zwutils_auto.hpp"
#include "ZWUtils.h"
#include "tolua_fix.h"
#include "LuaBasicConversions.h"



int lua_zwutils_ZWUtils_setConsoleColor(lua_State* tolua_S)
{
    int argc = 0;
    bool ok  = true;

#if COCOS2D_DEBUG >= 1
    tolua_Error tolua_err;
#endif

#if COCOS2D_DEBUG >= 1
    if (!tolua_isusertable(tolua_S,1,"ZWUtils",0,&tolua_err)) goto tolua_lerror;
#endif

    argc = lua_gettop(tolua_S) - 1;

    if (argc == 2)
    {
        int arg0;
        int arg1;
        ok &= luaval_to_int32(tolua_S, 2,(int *)&arg0, "ZWUtils:setConsoleColor");
        ok &= luaval_to_int32(tolua_S, 3,(int *)&arg1, "ZWUtils:setConsoleColor");
        if(!ok)
        {
            tolua_error(tolua_S,"invalid arguments in function 'lua_zwutils_ZWUtils_setConsoleColor'", nullptr);
            return 0;
        }
        ZWUtils::setConsoleColor(arg0, arg1);
        return 0;
    }
    luaL_error(tolua_S, "%s has wrong number of arguments: %d, was expecting %d\n ", "ZWUtils:setConsoleColor",argc, 2);
    return 0;
#if COCOS2D_DEBUG >= 1
    tolua_lerror:
    tolua_error(tolua_S,"#ferror in function 'lua_zwutils_ZWUtils_setConsoleColor'.",&tolua_err);
#endif
    return 0;
}
static int lua_zwutils_ZWUtils_finalize(lua_State* tolua_S)
{
    printf("luabindings: finalizing LUA object (ZWUtils)");
    return 0;
}

int lua_register_zwutils_ZWUtils(lua_State* tolua_S)
{
    tolua_usertype(tolua_S,"ZWUtils");
    tolua_cclass(tolua_S,"ZWUtils","ZWUtils","",nullptr);

    tolua_beginmodule(tolua_S,"ZWUtils");
        tolua_function(tolua_S,"setConsoleColor", lua_zwutils_ZWUtils_setConsoleColor);
    tolua_endmodule(tolua_S);
    std::string typeName = typeid(ZWUtils).name();
    g_luaType[typeName] = "ZWUtils";
    g_typeCast["ZWUtils"] = "ZWUtils";
    return 1;
}
TOLUA_API int register_all_zwutils(lua_State* tolua_S)
{
	tolua_open(tolua_S);
	
	tolua_module(tolua_S,"zw",0);
	tolua_beginmodule(tolua_S,"zw");

	lua_register_zwutils_ZWUtils(tolua_S);

	tolua_endmodule(tolua_S);
	return 1;
}

