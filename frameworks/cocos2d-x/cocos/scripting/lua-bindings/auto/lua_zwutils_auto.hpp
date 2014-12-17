#include "base/ccConfig.h"
#ifndef __zwutils_h__
#define __zwutils_h__

#ifdef __cplusplus
extern "C" {
#endif
#include "tolua++.h"
#ifdef __cplusplus
}
#endif

int register_all_zwutils(lua_State* tolua_S);



#endif // __zwutils_h__
