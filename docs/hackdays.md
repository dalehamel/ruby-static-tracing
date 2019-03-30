# Hackdays tasks

## Presentations and demos

Hackdays will need a 2 minute demo, so we should screen capture the functionality in gif format, showing its use.

[DRAFT of presentation](https://docs.google.com/presentation/d/1TmD0WrEp0vmItoxBeGKJfNTJ_4Y0UINXyWp4ZdGbO-A/edit#slide=id.g23dc7fe4e1_2_175)

## Rubyland hacking

Tracepoints are useless if they aren't accessible.

We need to implement helpers to make using a tracepoint as lightweight as possible.

This means that we should implement a ruby API that makes it easy to add tracepoints in bulk. While 
we don't want to trace every function, tracing every function in a ruby class or module of business logic
is a reasonable thing to expect and implement.

So, after implementing all of the necessary ruby code for basic tracepoint functionality, we sholud create helper modules and classes.
This means specialized probe types of different types, each specialized with the arguments already defined instead of accepting just
`*vargs`. 

* [ ] Finishing the implementation of rubyland basics
* [ ] Special probe types, such as LatencyProbe, HeaderProbe, and anything else we can think of that might be useful, contextual to rails.
* [ ] The exact logic of how tracepoints and providers are loaded and unloaded on receiving SIGTRAP needs to be determined.

## Stress and Perf Testing 

As probe functionality is written, we should have E2E tests that verify the functionality using bpftrace (or dtrace if we get to BSD support).

* [ ] Tests for tracepoints to ensure they behave as expected.
* [ ] Stress testing, registering and fireing a large number of tracepoints to ensure that this scales and to try and expose memory leaks.
* [ ] Performance testing, testing that static tracepoints themselves are efficient, and to what degree - especially as compared to ruby tracing api

# C coding

The headers have been defined, but all methods ar stubbed out except the basic constructors and destructors.

* [ ] Wrap remaining methods of libstapsdt
* [ ] OS X support, so that developers can easily use the same tracepoint on OS X. 
* [ ] Combing through existing code for memory leaks and other time bombs
* [ ] Patches into libbcc and bpftrace

## OS X support

This can be done by using ruby-usdt, or wrapping libusdt directly.

It is probably cleaner to use ruby-usdt for inspiration, and implement the same headers as the linux interface.
The source code will need to be restructured to pull the headers out to a separate directory, and have C files for
BSD / Solaris support separately. 

As ruby-usdt seems to be abandonware, it is probably better to pull wrap libusdt directly for maintenance purposes.

It would also be great to add eBPF support to the Railgun kernel, so that testing can be done locally via docker.
