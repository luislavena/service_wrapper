#include once "console_process.bi"

constructor ConsoleProcess(byref exe as string, byref args as string = "")
    '# store executable name for future references
    _executable = exe
    _arguments = args
end constructor

destructor ConsoleProcess()
end destructor

property ConsoleProcess.executable() as string
    return _executable
end property

property ConsoleProcess.arguments() as string
    return _arguments
end property
