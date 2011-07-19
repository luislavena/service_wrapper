#include once "console_process.bi"

constructor ConsoleProcess(byref exe as string, byref args as string = "")
    '# store executable name for future references
    _executable = exe
    _arguments = args
    _pid = 0
end constructor

destructor ConsoleProcess()
end destructor

property ConsoleProcess.executable() as string
    return _executable
end property

property ConsoleProcess.arguments() as string
    return _arguments
end property

property ConsoleProcess.pid() as integer
    return _pid
end property

function ConsoleProcess.start() as integer
    '# assume nothing worked
    dim result as integer = 0
    dim success as integer = 0

    '# Process Information and context
    dim context as STARTUPINFO
    dim proc_sa as SECURITY_ATTRIBUTES = type(sizeof(SECURITY_ATTRIBUTES), NULL, TRUE)
    dim process_info as PROCESS_INFORMATION

    '# Std* pipes redirection
    dim as HANDLE StdInRd, StdOutRd, StdErrRd
    dim as HANDLE StdInWr, StdOutWr, StdErrWr

    '# create pipes for SdtIn and ensure is not inherited (Write)
    success = CreatePipe(@StdInRd, @StdInWr, @proc_sa, 0)
    if (success) then
        success = SetHandleInformation(StdInWr, HANDLE_FLAG_INHERIT, 0)
    end if

    '# create pipes for StdOut and ensure is not inherited (Read)
    success = CreatePipe(@StdOutRd, @StdOutWr, @proc_sa, 0)
    if (success) then
        success = SetHandleInformation(StdOutRd, HANDLE_FLAG_INHERIT, 0)
    end if

    '# create pipes for StdErr and ensure is not inherited (Read)
    success = CreatePipe(@StdErrRd, @StdOutWr, @proc_sa, 0)
    if (success) then
        success = SetHandleInformation(StdErrRd, HANDLE_FLAG_INHERIT, 0)
    end if

    '# assume we have the pipes
    if (success) then
        '# set Std* for context
        with context
            .cb         = sizeof(context)
            .hStdInput  = StdInRd
            .hStdOutput = StdOutWr
            .hStdError  = StdErrWr
            .dwFlags    = STARTF_USESTDHANDLES
        end with

        success = CreateProcess( _
            _executable, _          '# LPCTSTR lpApplicationName
            _arguments, _           '# LPTSTR lpCommandLine
            NULL, _                 '# LPSECURITY_ATTRIBUTES lpProcessAttributes
            NULL, _                 '# LPSECURITY_ATTRIBUTES lpThreadAttributes
            TRUE, _                 '# BOOL bInheritHandles
            NORMAL_PRIORITY_CLASS, _'# DWORD dwCreationFlags
            NULL, _                 '# LPVOID lpEnvironment
            NULL, _                 '# LPCTSTR lpCurrentDirectory
            @context, _             '# LPSTARTUPINFO lpStartupInfo
            @process_info _         '# LPPROCESS_INFORMATION lpProcessInformation
        )
        if (success) then
            _pid = process_info.dwProcessId
            result = success
        else
        end if
    end if

    '# cleanup
    CloseHandle(StdInRd)
    CloseHandle(StdInWr)
    CloseHandle(StdOutRd)
    CloseHandle(StdOutWr)
    CloseHandle(StdErrRd)
    CloseHandle(StdErrWr)

    return result
end function
