#include "ZWUtils.h"

#ifdef WIN32
#include "windows.h"
#endif

void ZWUtils::setConsoleColor(int fontColor, int backColor)
{
#ifdef WIN32
	HANDLE hStdout = GetStdHandle(STD_OUTPUT_HANDLE);
	SetConsoleTextAttribute(hStdout, fontColor | backColor);
#endif
}