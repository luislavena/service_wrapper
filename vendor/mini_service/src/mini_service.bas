#include once "mini_service.bi"

constructor MiniService(byref new_name as string)
    trace("setting up new name")
    _name = new_name

    '# initial service values
    trace("initial service status values")
    with status
        .dwServiceType = SERVICE_WIN32_OWN_PROCESS
        .dwCurrentState = SERVICE_STOPPED
        .dwControlsAccepted = (SERVICE_ACCEPT_STOP or SERVICE_ACCEPT_SHUTDOWN)
        .dwWin32ExitCode = NO_ERROR
        .dwServiceSpecificExitCode = NO_ERROR
        .dwCheckPoint = 0
        .dwWaitHint = 0
    end with

    '# Initial state
    trace("assigning an initial state as Stopped")
    _state = Stopped

    '# create condition and mutex for synchronization
    trace("creating stop event")
    stop_event = CreateEvent(0, FALSE, FALSE, 0)
end constructor

destructor MiniService()
    trace("clean up after our party!")
    CloseHandle(stop_event)
end destructor

property MiniService.name() as string
    return _name
end property

property MiniService.command_line() as string
    return _command_line
end property

property MiniService.state() as States
    return _state
end property

function MiniService.singleton(byval new_value as MiniService ptr = 0) as MiniService ptr
    static _singleton as MiniService ptr

    if not (new_value = 0) then
        trace("setting new singleton reference: " + hex(new_value))
        _singleton = new_value
    end if

    return _singleton
end function

sub MiniService.run()
    dim service_table(1) as SERVICE_TABLE_ENTRY

    trace("about to run!")

    '# track this instance as singleton
    MiniService.singleton(@this)

    '# build the service table and references
    trace("setting up first entry in service_table for " + _name + " @ " + hex(@MiniService.control_dispatcher))

    service_table(0) = type<SERVICE_TABLE_ENTRY>( _
        strptr(_name), _
        @MiniService.control_dispatcher _
    )

    '# terminate service table with null information
    service_table(1) = type<SERVICE_TABLE_ENTRY>(0, 0)

    '# start the control dispatcher with the list
    trace("start service dispatcher")
    StartServiceCtrlDispatcher(@service_table(0))

    trace("run() done")
end sub

sub MiniService.control_dispatcher(byval argc as DWORD, byval argv as LPSTR ptr)
    var service = MiniService.singleton()

    '# build the command line for the service
    service->build_command_line()

    '# register service control handler
    service->register_handler()

    '# carry on with all the hooks defined
    service->execute()
end sub

sub MiniService.register_handler()
    trace("register control handler")
    status_handle = RegisterServiceCtrlHandlerEx( _
        strptr(_name), _
        @control_handler_ex, _
        @this _
    )
end sub

sub MiniService.execute()
    dim worker as any ptr

    '# got handle? good, let's proceed
    if not (status_handle = 0) then
        trace("switch state to start pending")
        update_state(SERVICE_START_PENDING)

        '# perform onInit (if present)
        if not (onInit = 0) then
            trace("invoking onInit (sync)")
            onInit(@this)
        end if

        '# we should switch to running state
        update_state(SERVICE_RUNNING)

        if not (onStart = 0) then
            trace("invoking onStart (thread)")
            worker = threadcreate(@MiniService.invoke_onStart, @this)
        end if

        '# now, we wait for our stop signal
        trace("waiting for stop_event signaling")
        do
            '# do nothing...
            '# but not too often!
        loop while (WaitForSingleObject(stop_event, 100) = WAIT_TIMEOUT)

        '# now let's wait for our thread to complete
        trace("now wait for onStart to complete")
        threadwait(worker)

        '# update status, we're done
        trace("done, mark the service as stopped")
        update_state(SERVICE_STOPPED)
    end if
end sub

sub MiniService.invoke_onStart(byval any_service as any ptr)
    var service = cast(MiniService ptr, any_service)
    trace("calling onStart")
    service->onStart(service)
end sub

function MiniService.control_handler_ex(byval dwControl as DWORD, byval dwEventType as DWORD, byval lpEventData as LPVOID, byval lpContext as LPVOID) as DWORD
    dim result as DWORD
    var service = cast(MiniService ptr, lpContext)

    trace("about to process control signal")
    select case dwControl
    case SERVICE_CONTROL_INTERROGATE:
        trace("interrogate signal received")
        result = NO_ERROR

    case SERVICE_CONTROL_SHUTDOWN, SERVICE_CONTROL_STOP:
        trace("stop or shutdown received, invoking perform_stop()")
        service->invoke_stop()

    case else:
        result = NO_ERROR
    end select

    return result
end function

sub MiniService.invoke_stop()
    '# update status to reflect we are stopping
    update_state(SERVICE_STOP_PENDING)

    '# invoke onStop if defined
    if not (onStop = 0) then
        trace("invoking onStop (sync)")
        onStop(@this)
    end if

    '# now trigger stop_event
    trace("triggering stop event")
    SetEvent(stop_event)
end sub

sub MiniService.update_state(byval new_state as DWORD, byval checkpoint as integer = 0, byval waithint as integer = 0)
    trace("adjusting service state")
    select case new_state
    '# disable the option to accept other commands during pending operations
    case SERVICE_START_PENDING, SERVICE_STOP_PENDING:
        trace("disabling commands during pending operations")
        status.dwControlsAccepted = 0

    '# when running a service can accept stop or shutdown events
    case SERVICE_RUNNING:
        trace("accept stop and shutdown when running")
        status.dwControlsAccepted = (SERVICE_ACCEPT_STOP or SERVICE_ACCEPT_SHUTDOWN)
    end select

    '# adjust status structure also with new state and our property
    status.dwCurrentState = new_state
    _state = new_state

    '# set checkpoint and waithint
    status.dwCheckPoint = checkpoint
    status.dwWaitHint = waithint

    '# use our handle to notify the status update
    if not (status_handle = 0) then
        trace("notify Windows using SetServiceStatus API")
        SetServiceStatus(status_handle, @status)
    end if
end sub

sub MiniService.build_command_line()
    dim as string result, token
    dim idx as integer

    trace("commands passed to ImagePath (excluding executable):")
    idx = 1
    token = command(idx)
    do while (len(token) > 0)
        trace("token: " + token)

        if (instr(token, chr(32)) > 0) then
            '# quote around parameter with spaces
            result += """" + token + """"
        else
            result += token
        end if
        result += " "
        idx += 1

        token = command(idx)
    loop

    _command_line = result

    trace("command line: " + _command_line)
end sub

'# TRACE_FILE
#ifdef _MINI_SERVICE_TRACE_FILE

sub MiniService.trace_file(byref msg as string, byref f as string, byval l as integer, byref func as string)
    dim handler as integer

    handler = freefile
    open EXEPATH + "\mini_service.log" for append as #handler
    print #handler, f + ":" + str(l) + " (" + func + ") - " + msg

    close #handler
end sub

#endif
