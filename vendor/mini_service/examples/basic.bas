#include once "mini_service.bi"

type BasicService extends MiniService
    declare constructor()
    declare destructor()

private:
    declare static sub onInit(byval as MiniService ptr)
    declare static sub onStart(byval as MiniService ptr)

end type

constructor BasicService()
    base("BasicService")

    base.onInit = @BasicService.onInit
    base.onStart = @BasicService.onStart
end constructor

destructor BasicService()
    base.onInit = 0
    base.onStart = 0
end destructor

sub BasicService.onInit(byval service as MiniService ptr)
    var this = cast(BasicService ptr, service)

    '# here you can grab service name and command_line for your own purposes.
    '# this->name
    '# this->command_line
end sub

sub BasicService.onStart(byval service as MiniService ptr)
    var this = cast(BasicService ptr, service)

    do while (this->state = MiniService.States.Running)
        sleep 100
    loop
end sub

sub main()
    dim myservice as BasicService
    myservice.run()
end sub

main()
