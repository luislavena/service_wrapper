# MiniService

This is a rewrite/rethink of [ServiceFB](https://github.com/luislavena/servicefb).
ServiceFB started as small framework to create services using FreeBASIC language.

It was a proof of concept that powered [mongrel_service](https://github.com/luislavena/mongrel_service)
back in 2006.

By today's standard, that code runs obsolete. New features added to FreeBASIC
over the years could provide a better codebase.

## Making things more simple

This project aims to go back to basic, go to a simple and single purpose
library instead.

This not only **removes** features found in ServiceFB, but changes completely
the way of coding and creating services with it.

What have changed and what you need to know:

### Using proper encapsulation

While FreeBASIC inheritance is still missing, this library uses an OO-like
approach to provide better encapsulation of your service code.

You can find inside _examples/basic.bas_ how this encapsulations works.

### Better thread-safety

ServiceFB, while stable, it was not thread-safe, no way. It was even advised
against playing with multiple services in the same executable due the usage of
global variables (shame on me).

Well, MiniService solves that: there is only one service per executable, no
globals.

### Less garbage... I mean code

MiniService has approximately 250 SLOC, that is just 22% of what ServiceFB
code is (1158 SLOC). Less code means less marging for errors, less cruft to
maintain.

## Info and Support

* [Source Code](http://github.com/luislavena/mini_service)
* [Issue Tracker](http://github.com/luislavena/mini_service/issues)

## License

MiniService is released under the MIT License.
