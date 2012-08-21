#include once "service_wrapper.bi"

constructor ServiceWrapper()
    base("ServiceWrapper")

    trace("set callbacks")
    base.onInit = @ServiceWrapper.onInit
    base.onStart = @ServiceWrapper.onStart
    base.onStop = @ServiceWrapper.onStop
end constructor

destructor ServiceWrapper()
    trace("unset everything and delete config and child")
    if (config) then
        delete config
    end if

    if (child) then
        delete child
    end if

    base.onInit = 0
    base.onStart = 0
    base.onStop = 0
end destructor

sub ServiceWrapper.onInit(byval service as MiniService ptr)
    var this = cast(ServiceWrapper ptr, service)

    trace("System PATH: " + Environ("PATH"))

    trace("initialize config with file '" + this->command_line + "'")
    this->config = new ConfigurationFile(this->command_line)
    var config = this->config '# shorthand

    trace("executable: " + config->executable)
    trace("arguments: " + config->arguments)
    trace("directory: " + config->directory)
    trace("logfile: " + config->logfile)

    if not (config->executable = "") then
        trace("prepare and start child process")
        this->child = new ConsoleProcess( _
            this->config->executable, _
            this->config->arguments _
        )
        var child = this->child

        if not (config->directory = "") then
            trace("adjusting child process current directory")
            child->directory = config->directory
        end if

        if not (config->logfile = "") then
            trace("redirecting child process to logfile")
            child->redirect(config->logfile)
        end if

        trace("start child process")
        child->start()
    end if

    trace("done with onInit")
end sub

sub ServiceWrapper.onStart(byval service as MiniService ptr)
    var this = cast(ServiceWrapper ptr, service)

    trace("waiting during the running state")
    do while (this->state = MiniService.States.Running)
        sleep 100
    loop

    if (this->child) then
        '# verify if child is still running
        if (this->child->running) then
            trace("killing child process")
            this->child->kill()
        else
            trace("child process terminated with: " + str(this->child->exit_code))
        end if
    end if

    trace("done with onStart")
end sub

sub ServiceWrapper.onStop(byval service as MiniService ptr)
    var this = cast(ServiceWrapper ptr, service)

    if (this->child) then
        '# FIXME: ping ServiceManager think we are dead...
        trace("attempting to terminate child process")
        this->child->terminate()
        if not (this->child->running) then
            trace("succeed, exit_code: " + str(this->child->exit_code))
        end if
    end if

    trace("done with onStop")
end sub

#ifdef _TRACE_FILE

sub ServiceWrapper.trace_file(byref msg as string, byref f as string, byval l as integer, byref func as string)
    dim handler as integer

    handler = freefile()
    open EXEPATH + "\service_wrapper.log" for append as #handler
    print #handler, f + ":" + str(l) + " (" + func + ") - " + msg

    close #handler
end sub

#endif
