#include once "console_process.bi"

constructor ConsoleProcess(byref exe as string, byref args as string = "")
    '# store executable name for future references

    '# executable with spaces?
    if (instr(exe, " ")) then
        _executable = !"\"" + exe + !"\""
    else
        _executable = exe
    end if

    _arguments = args
    _pid = 0
end constructor

destructor ConsoleProcess()
    '# avoid HANDLE leakage
    if (_process_info.hProcess) then
        CloseHandle(_process_info.hProcess)
    end if
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
    dim cmdline as string
    dim context as STARTUPINFO
    dim proc_sa as SECURITY_ATTRIBUTES = type(sizeof(SECURITY_ATTRIBUTES), NULL, TRUE)

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

        '# build command line (for LpCommandLine)
        cmdline = _executable + " " + _arguments

        success = CreateProcess( _
            NULL, _                 '# LPCTSTR lpApplicationName
            cmdline, _              '# LPTSTR lpCommandLine
            NULL, _                 '# LPSECURITY_ATTRIBUTES lpProcessAttributes
            NULL, _                 '# LPSECURITY_ATTRIBUTES lpThreadAttributes
            TRUE, _                 '# BOOL bInheritHandles
            NORMAL_PRIORITY_CLASS, _'# DWORD dwCreationFlags
            NULL, _                 '# LPVOID lpEnvironment
            NULL, _                 '# LPCTSTR lpCurrentDirectory
            @context, _             '# LPSTARTUPINFO lpStartupInfo
            @_process_info _        '# LPPROCESS_INFORMATION lpProcessInformation
        )
        if (success) then
            '# clean unused handle
            CloseHandle(_process_info.hThread)
            _process_info.hThread = NULL

            _pid = _process_info.dwProcessId
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

function ConsoleProcess.exit_code() as uinteger
    static previous_code as uinteger
    dim result as uinteger
    dim success as integer

    '# do we have a process to work with?
    if (_process_info.hProcess) then
        success = GetExitCodeProcess(_process_info.hProcess, @result)
        if (success) then
            previous_code = result

            '# free handle if not required
            if not (result = STILL_ACTIVE) then
                CloseHandle(_process_info.hProcess)
                _process_info.hProcess = NULL
            end if
        end if
    else
        result = previous_code
    end if

    return result
end function

function ConsoleProcess.running() as integer
    return (exit_code = STILL_ACTIVE)
end function

function ConsoleProcess.terminate(byval default_timeout as integer = 5) as integer
    dim result as integer
    dim success as integer
    dim wait_code as integer
    dim timeout as integer = default_timeout * 1000 '# milliseconds

    if (running) then
        '# hook our handler routine
        success = SetConsoleCtrlHandler(@handler_routine, TRUE)
        if (success) then
            '# send CTRL_C_EVENT and wait for result
            success = GenerateConsoleCtrlEvent(CTRL_C_EVENT, 0)
            if (success) then
                wait_code = WaitForSingleObject(_process_info.hProcess, timeout)
                result = not (wait_code = WAIT_TIMEOUT)
            end if

            '# didn't work? send Ctrl+Break and wait
            if not (result) then
                success = GenerateConsoleCtrlEvent(CTRL_BREAK_EVENT, 0)
                if (success) then
                    wait_code = WaitForSingleObject(_process_info.hProcess, timeout)
                    result = not (wait_code = WAIT_TIMEOUT)
                end if
            end if
        end if

        '# remove to restore functionality
        success = SetConsoleCtrlHandler(@handler_routine, FALSE)
    end if

    return result
end function

function ConsoleProcess.kill() as integer
    dim result as integer

    if (running) then
        result = TerminateProcess(_process_info.hProcess, 0)
    end if

    return result
end function

function ConsoleProcess.redirect(byref redirect_filename as string) as integer
    dim result as integer = 0

    if not (running) then
        if (len(redirect_filename) > 0) then
            _redirect_filename = redirect_filename
            result = not result
        end if
    end if

    return result
end function

function ConsoleProcess.redirected() as integer
    return (len(_redirect_filename) > 0)
end function

function ConsoleProcess.handler_routine(byval dwCtrlType as DWORD) as BOOL
    dim result as BOOL

    '# shall we process dwCtrlType?
    select case dwCtrlType
    case CTRL_C_EVENT, CTRL_BREAK_EVENT:
        result = TRUE
    case else:
        result = FALSE
    end select

    return result
end function
