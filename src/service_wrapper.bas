#include once "service_wrapper.bi"

constructor ServiceWrapper()
    trace("initialize base and set callbacks")
    base = new MiniService("ServiceWrapper")
    base->onInit = @ServiceWrapper.onInit
    base->onStart = @ServiceWrapper.onStart
    base->extra = @this
end constructor

destructor ServiceWrapper()
    trace("unset everything and delete base and config")
    if (config) then
        delete config
    end if
    base->onStart = 0
    base->extra = 0
    delete base
end destructor

sub ServiceWrapper.run()
    trace("base->run()")
    base->run()
end sub

sub ServiceWrapper.onInit(byval base as MiniService ptr)
    var this = cast(ServiceWrapper ptr, base->extra)

    trace("initialize config with file '" + base->command_line + "'")
    this->config = new ConfigurationFile(base->command_line)

    trace("executable: " + this->config->executable)
    trace("arguments: " + this->config->arguments)
    trace("directory: " + this->config->directory)
end sub

sub ServiceWrapper.onStart(byval base as MiniService ptr)
    var this = cast(ServiceWrapper ptr, base->extra)

    trace("waiting during the running state")
    do while (base->state = MiniService.States.Running)
        sleep 100
    loop
    trace("done with running")
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