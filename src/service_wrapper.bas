#include once "service_wrapper.bi"

constructor ServiceWrapper()
    base = new MiniService("ServiceWrapper")
    base->onStart = @ServiceWrapper.onStart
    base->extra = @this
end constructor

destructor ServiceWrapper()
    base->onStart = 0
    base->extra = 0
    delete base
end destructor

sub ServiceWrapper.run()
    base->run()
end sub

sub ServiceWrapper.onStart(byval base as MiniService ptr)
    var this = cast(ServiceWrapper ptr, base->extra)

    do while (base->state = MiniService.States.Running)
        sleep 100
    loop
end sub

sub main()
    dim service as ServiceWrapper
    service.run()
end sub

main()
