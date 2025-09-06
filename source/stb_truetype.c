#ifdef WIN32
#define __EXPORT __declspec(dllexport)
#else
#define __EXPORT
#endif

#define STB_TRUETYPE_IMPLEMENTATION
#include "stb_truetype.h"
