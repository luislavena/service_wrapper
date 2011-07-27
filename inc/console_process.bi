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
    declare function exit_code() as uinteger
    declare function running() as integer
    declare function terminate(byval as integer = 5) as integer
    declare function kill() as integer
    declare function redirect(byref as string) as integer
    declare function redirected() as integer

private:
    '# used by SetConsoleCtrlHandler
    declare static function handler_routine(byval as DWORD) as BOOL

    '# hold property values
    _executable as string
    _arguments as string
    _pid as integer
    _process_info as PROCESS_INFORMATION
    _redirect_filename as string
end type

#endif
