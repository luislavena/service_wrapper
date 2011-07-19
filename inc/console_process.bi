#ifndef __CONSOLE_PROCESS__
#define __CONSOLE_PROCESS__

type ConsoleProcess
    declare constructor(byref as string, byref as string = "")
    declare destructor()

    '# properties (read-only)
    declare property executable as string
    declare property arguments as string

    '# methods
    declare function start() as integer

private:
    '# hold property values
    _executable as string
    _arguments as string
end type

#endif
