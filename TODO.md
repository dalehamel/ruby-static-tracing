# Immediate todo:

- Read up on how to create and store a dict on C object in ruby
- Ruby allocation types for provider and tracepoint

- How will tracepoints be added to and stored on provider?
 - Tracepoint constructor to accept provider name, lookup or construct provider.
  * Constructor works by calling `provider.add_tracepoint`, passing vargs
 - Provider to have `add_tracepoint` function as alternative means of instantiating a tracepoint object directly, accepts vargs
  - Adds the tracepoint to dictionary on provider object

- Providers to exist globally as a singlen in a dict directly on StaticTracing as StaticTracing::Providers
- TracePoints to exist as a dict on a provider instance.

- Try and run stubs

- On hackdays, will just have to implement the C definitions

# Immediate / current TODO

- [ ] Define Ruby stubs for tracepoint object (interface exposed to ruby)
- [ ] Define Ruby stubs for provider
- [ ] Initial stub implementation of libstapsdt as provider for linux platform
 - [ ] Use the right-most part of canonicalized module name (eg, Ruby::Object::Type, provider is Type, lowercased to 'type')

Prove that a static tracepoint can be registered on ruby

# Hack days prep

- [ ] Document design and intended behavior from rubyspace
- [ ] Mocks for ruby space objects
- [ ] Minimal working scaffold proving that this can even be done in ruby
 - [ ] Done on a linux vm image without process memory protection
- [ ] Production machine to test on, with memory protection disabled
 - [ ] Using custom container OS image with kernel that disables cos memory protection
- [ ] Prepare scaffolding for unit tests

# Other things to fix:

## Ruby type handling

libstapsdt passes up to 8 byte values directly. This can correspond to literal values (ints, enums), or memory addresses corresponding to pointers. Any data that can be encoded in 64 bits can be passed by a probe.

For pointers, if the value stored at the pointer is a byte array corresponding to a C-style string, the string value should be able to be read directly
by BCC / bpftrace's handling, such as through the `str()` function of bpftrace.

Most use cases will involve either ints (latency values) or strings (symbols / trace metadata or stack traces).

## Wildcards in bpftrace

When trying to probe without specifying the path, I get an error with bpftrace:

```

bpftrace -e 'usdt::ruby:method__entry { @[probe]++}' -p 1271
Wildcard matches aren't available on probe type 'usdt'
No probes to attach
```

This can likely be fixed, or else other helpers added to access the probe and provider fired by a USDT probe, which is the desired behavior.

We should generally support wildcard behavior for USDT probes.

https://github.com/iovisor/bpftrace/issues/493

## Namespace collisions upstream

https://github.com/iovisor/bcc/blob/master/src/cc/usdt/usdt.cc#L296-L320 
https://github.com/iovisor/bcc/issues/1527
https://github.com/iovisor/bcc/issues/2275

There is a bug in libbcc/bpftrace that will result in namespaces to be ignored, eg:
if you have two providers with the same `show`, they will shadow each other.
We want `module_a:show` and `module_b:show` to be namespaced by their provider name and not colide.

- Add support for namespaced providers in lib bcc, upstream this
 - It's a known bug, find the bug id
  - Leave the current interface (accepting only 3 params)
   - Add deprecation warning? Can always remove this in PR.
  - Create a new interface (accepting 4 params)
   - check if the 4th param is null and use original 3 param implementation if so
   - Otherwise, use the 4th param (provider) instead of defaulting to path name
- Modify bpftrace to wrap this function using new interface (specifying provider)
 - Upstream this once 

## Semaphore incrementing

https://github.com/iovisor/bcc/issues/2230

We need to disable container OS memory protection in order to use this.

In Kernel 4.20+, we should be able to use a kernel facility to increment the semaphore, rather
than relying on opening and writing to the processess memory image at the semaphore offset.

Once support for this is added to bcc, it should be ported into bpftrace so that enabling
a probe in bpftrace increments the semaphore in the usdt probe through bcc, and the kernel,
rather than by writing to the processess memory image directly from userspace.

This is needed for access to ruby's general USDT probes, which require a sempahore to implement is-enabled

## Semaphore support in libstapsdt

While not strictly needed, this would be nice to stay consistent.

It would be good to see if there is any performance benefit to using the semaphore based approach over just
relying no the uprobe trap point.

# Further work

## Contextual tracepoint helpres

Tracepoint helpers, to add contextually-specific tracepoints.

Eg, a `StaticTracing::Helpers::Latency` instance should register a probe that checks the latency of a function call.

More specific helpers for cases in rails where a request is to be probed, or active record wrappers.

These would wrap the creation of the provider and tracepoint by inferring what is desired based on application context,
trying to make adding a tracepoint as simple as possible.

## Future support for non-linux platforms

For development and testing locally on a Mac, we should leverage the existing dtrace.

Just wrappinng libusdt should provide this, as ruby-usdt did. If we preserve the exact same interface,
then this should allow developers to effectively test out usdt probes against local ruby processes on a mac.

We should also support environments (such as, probably, CI) where dtrace/bpftrace won't be able to work.

Since the value is providing tracing in production environments, we'll work on linux support first.

## Minimizing overhead

Rather than using a signal handler, it would be awesome if we could detect the USDT probe in libstabsdt
has been enabled by bpftrace, and *only then* override the method definiton. This would be absolutely no overhead
until the probe is enabled, which is ideal.

Until then, checking if a probe is enabled should be very low overhead, as it only incurs:

- An extra ruby method call/return due to wrapping
- An `if` check for if the probe is enabled

Once a probe is enabled, the overhead of gathering the data needed before firing the probe needs to be considered
in order to prevent degrading application performance.

## Measure probe overhead for any automatic / builtin probe helpers

As a convention, the first argument of any generated probe can be an integer representing the approximate total real usertime time spent executing the probe, subtracting time at exit from entry. This convention could be encouraged to attempt to capture and monitor probe overhead for optimization of probes that adversely increase overhead.
