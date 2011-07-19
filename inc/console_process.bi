#ifndef __CONSOLE_PROCESS__
#define __CONSOLE_PROCESS__

#include once "windows.bi"

type ConsoleProcess
    declare constructor(byref as string, byref as string = "")
    declare destructor()

    '# properties (read-only)
    declare property executable as string
    declare property arguments as string
    declare property pid as integer

    '# methods
    declare function start() as integer
    declare function exit_code() as integer
    declare function running() as integer

private:
    '# hold property values
    _executable as string
    _arguments as string
    _pid as integer
    _process_info as PROCESS_INFORMATION
end type

#endif
