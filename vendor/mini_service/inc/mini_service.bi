#ifndef __MINI_SERVICE_BI__
#define __MINI_SERVICE_BI__

#include once "windows.bi"
#inclib "advapi32"

#ifdef _MINI_SERVICE_TRACE_FILE
    #define trace(msg) MiniService.trace_file(msg, __FILE__, __LINE__, __FUNCTION__)
#else
    #define trace(msg)
#endif

type MiniService
    '# possible service states
    enum States
        Running = SERVICE_RUNNING
        Paused  = SERVICE_PAUSED
        Stopped = SERVICE_STOPPED
    end enum

    declare constructor()
    declare constructor(byref as string)
    declare destructor()

    '# methods
    declare sub run()
    declare sub ping(byval as integer)

    '# properties (read-only)
    declare property name           as string
    declare property command_line   as string
    declare property state          as States

    '# event callbacks
    '# required:
    onStart   as sub(byval as MiniService ptr)

    '# optional:
    onInit    as sub(byval as MiniService ptr)
    onStop    as sub(byval as MiniService ptr)

    '# use this to store any extra reference (pseudo inheritance)
    extra     as any ptr

private:
    '# singleton pattern
    declare static function singleton(byval as MiniService ptr = 0) as MiniService ptr

    '# Used by StartServiceCtrlDispatcher and SERVICE_TABLE_ENTRY
    declare static sub control_dispatcher(byval as DWORD, byval as LPSTR ptr)
    declare static function control_handler_ex(byval as DWORD, byval as DWORD, byval as LPVOID, byval as LPVOID) as DWORD

#ifdef _MINI_SERVICE_TRACE_FILE
    declare static sub trace_file(byref as string, byref as string, byval as integer, byref as string)
#endif

    '# internal helpers
    declare sub execute()
    declare sub invoke_stop()
    declare sub build_command_line()
    declare sub register_handler()
    declare sub update_state(byval as DWORD, byval as integer = 0, byval as integer = 0)

    '# internal thread helper (to confrom with threadcreate signature)
    declare static sub invoke_onStart(byval as any ptr)

    '# hold property values
    _name as string
    _state as States
    _command_line as string

    '# hold Service internals
    status as SERVICE_STATUS
    status_handle as SERVICE_STATUS_HANDLE
    stop_event as HANDLE
end type

#endif
