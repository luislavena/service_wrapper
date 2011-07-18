#include once "helper.bi"

sub custom_assert(byref f as string, byval l as integer, byref func as string, byref expr as string)
    dim handle as integer

    handle = freefile()
    open err for output as #handle
    print #handle, using "&(&): assertion failed at &: &"; f, l, func, expr
    close #handle
end sub
