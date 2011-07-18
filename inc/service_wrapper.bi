#ifndef __SERVICE_WRAPPER__
#define __SERVICE_WRAPPER__

#include once "mini_service.bi"

type ServiceWrapper
    declare constructor()
    declare destructor()

    declare sub run()

private:
    base as MiniService ptr

    '# TODO: onInit and onStop
    declare static sub onInit(byval as MiniService ptr)
    declare static sub onStart(byval as MiniService ptr)
    declare static sub onStop(byval as MiniService ptr)
end type

#endif
