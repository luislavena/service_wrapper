#ifndef __SERVICE_WRAPPER__
#define __SERVICE_WRAPPER__

#include once "mini_service.bi"
#include once "configuration_file.bi"
#include once "console_process.bi"

#undef trace
#ifdef _TRACE_FILE
    #define trace(msg) ServiceWrapper.trace_file(msg, __FILE__, __LINE__, __FUNCTION__)
#else
    #define trace(msg)
#endif

type ServiceWrapper
    declare constructor()
    declare destructor()

    declare sub run()

private:
    base as MiniService ptr
    config as ConfigurationFile ptr
    child as ConsoleProcess ptr

    '# TODO: onInit and onStop
    declare static sub onInit(byval as MiniService ptr)
    declare static sub onStart(byval as MiniService ptr)
    declare static sub onStop(byval as MiniService ptr)

#ifdef _TRACE_FILE
    declare static sub trace_file(byref as string, byref as string, byval as integer, byref as string)
#endif

end type

#endif
