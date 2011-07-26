#ifndef __CONFIGURATION_FILE__
#define __CONFIGURATION_FILE__

#include once "windows.bi"

type ConfigurationFile
    declare constructor(byref as string)
    declare destructor()

    '# properties (read-only)
    declare property executable as string
    declare property arguments as string
    declare property directory as string

private:
    _filename as string

    '# internal helpers
    declare function retrieve(byref as string) as string
end type

#endif
