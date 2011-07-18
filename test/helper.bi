#ifndef __TEST_HELPER__
#define __TEST_HELPER__

#undef assert
#define assert(expression) if (expression) = 0 then : custom_assert(__FILE__, __LINE__, __FUNCTION__, #expression)

declare sub custom_assert(byref as string, byval as integer, byref as string, byref as string)

#endif
