# Configuration

The gem should store these in a config object, that it will check to determine its behavior.

Any 'magic numbers', tuneables, or other values that could be useful to be configurable should live here.

To override behavior, a user just needs to redefine the constants they want to tune after importing.

Eg, possible implementation could look like this:
```ruby
StaticTracing::Configuration.some_config = "My Awesome Value"
```

## Method overriding

```ruby
StaticTracing::Configuration.mode = StaticTracing::Configuration::Modes::SIGNAL
StaticTracing::Configuration.signal = StaticTracing::Configuration::Modes::SIGNALS::SIGPROF
```

Where a tracepoint accepts a method as an argument, there are three options:
- "ON": Immediately replace the definition of the original method with a wrapped version that adds the tracepoint.
- "OFF": Require manually toggling tracepoints on and off within source code
- "SIGNAL": Activate behavior of "ON" upon receiving `SIGPROF`, or a user-defined signal to replace this with a configuration value. Upon receiving the signal again, it will be toggled back to "OFF".

SIGNAL should be the default behavior. `SIGPROF` seems to be unused (and uncaught) by either ruby or unicorn, so it *should* be fine to trap it. SIGPROF seems like the proper signal to trap on.

The extra processing overhead added by "ON" should always be limited to checking if a probe is enabled, and the cost of returning from a wrapper methed - both of which should be known and low overhead.

# Tracing providers

## Registering a tracing provider

```
provider = StaticTracing::Provider.register(namespace_name)
```

A provider corresponds to a probe namespace, and a stub library for systemtap USDT probe points will be generated for each provider that is declared.

The provider handle is what will be used to register tracepoints against a particular namespace.

In is impossible to have provider conflicts, as all providers are singletons. Attempting to create a conflicting provider will fail, and return the original.
All providers registered are accessible via global map of registered providers:

```
provider = StaticTracing.providers[namespace_name] # This should get a handle to an existing registered provider, or throw an error if none exists
```

```
StaticTracing::Provider.load(namespace_name) # loads a provider, attaching the tracepoints to the ruby process for a single namespace. Returns the provider.
provider.load # if a handle to the provider is aready known, load it directly
```

This should unregister a provider, disabling any tracepoints that it provided.

If a provider name is not specified, the default name of `global` should be used.

# Tracepoints

## Creating a single tracepoint

## Adding to a provider directly
```
tracepoint = provider.add_tracepoint(method_name, *vargs) (vargs should be a list of basic types)
```

## Implicitly create a tracepoint against a provider

Since providers are globally unique, the initializer can find or build a provider by, accepting the provider name as a parameter to the initializer.
If a provider of that name already exists, it should be registered against that. If no provider by that name is found, a new one should be registered.

```
tracepoint = StaticTracing::Tracepoint.new(provider_name, name, *vargs)
tracepoint.fire(*vargs)
```

Resulting in the following tracepoints upon inspecting the ELF notes of the process for tracepoints:

```
usdt:/tmp/XXXX.so:provider_name:name
```

Tracepoints can also be directly registered against the global provider by omitting the provider name:

```
usdt:/tmp/XXXX.so:global:name
```

* `provider_name`: string or symbol identifier of a provider
* `name`: string or symbol name to use for this tracepoint. If it is a symbol of a method that exists, this method may be wrapped in a tracepoint
* `*vargs`: List of basic C Enum types for the tracepoint's argument signature.

## Tracepoint API

The tracepoint will have some basic methods:

```ruby
tracepoint.fire(*vargs) # verify that they match the types and order match what was given when the tracepoint was registered
                        # a tracepoint wil only fire if both it and its provider are enabled, and it is attached to by a tracer.
tracepoint.load         # this will replace the method or block to be probed with a wrapped version. If the probe is attached to, it will fire.
tracepoint.unload       # this will remove a probe from the request flow, replacing wrapped methods or blocks with their original implementations

tracepoint.enabled?     # used to check if a tracepoint is currently attached to by a tracer.
```

For `tracepoint.fire` `*vargs` *must* match the argument signature that was specified when the tracepoint was initialized.

## Firing a tracepoint

"Firing" is emitting data to be traced/probed by an external observer such as bpftrace or dtrace.

Firing a tracepoint will cause execution to switch to kernel space if the tracepoint is attached. The kernel will then be able to copy
the arguments specified in the tracepoint into kernel space, such as with `perf` or an eBPF program generated by `bpftrace`.

Once the arguments have been copied, execution is handed back to the ruby userspace code and continues as normal.

Firing a probe briefly causes the kernel to steal time from the userspace ruby code.

If nothing is attached to a tracepoint, then a probe won't and cannot be fired, and is basically a no-op.

### Argument types

Only basic data types can be fired off to a tracepoint, such as integers and strings.

Under the hood, arguments are stored in at most a 64 bit type. Integers and basic data types
can be stored as-is.

Integers are most likely to be useful for latency measurements. Floating point should also be possible to support within the same 64 bit storage class, though the convention does not appear standardized.

Strings are supported by passing a pointer to a byte array, but must be interpreted by the tracing program.
In bpftrace, this is achieved with the `str()` built-in function. It should be usable for printing userspace
stack traces, which could be used for flamegraph generation and stack analysis.

It should also be possible to introspect request metadata in some cases, and use a probe to emit span-tagged
data that could be attached to existing trace data aggregation sources and analyzed. This could be used to
augment distributed tracing data, providing deeper insight into existing trace flows.


# Built-in Tracers

## Tracers

A tracer is an abstraction one level up from a tracepoint, providing

A library of built-in tracers should wrap the basic tracepoint object, so that the user will not have to write tracepoints themselves directly.

### Internal latency

It behooves us to keep trace of the overhead we are introducing by tracing.

As a best practice, all built-in tracers should fire an integer value corresponding to the number of nanoseconds spent in the tracer itself. This will allow for us to attempt to keep trace of what the total ruby/cruby overhead of our tracepoints are. It will not show time stolen by the kernel while the uprobe is attached, that must be calculated or traced separately. For each USDT tracepoint created then, the argument signature should at minimum look like this:

Argument signature:
```C
(long long internal_latency, ...)
```
* arg0 - `internal_latency`: 64 bit integer holding nsecs spent in execution, calculated against a monotonic source.

Followed by any other arguments. `long long` here refers to the C storage class, and is important to specify this way in order to understand how the available 8 bytes for each argument are used.

## Latency probes

Block format:

```ruby
StaticTracing::Latency.register(name: my_awesome_block) do
  ...
  # Some existing application code that we want to wrap in a one-off
  ...
end
```

Method format:

```ruby
def my_func
  sleep 1
end

StaticTracing.Latency.register(:my_func)
```

This should generate a probe using the existing class/module as a provider (and accept an optional parameter to specify it explicitly).

Registering a tracepoint against an existing method name should cause the original name to be replaced by the traced version depending on configuration.

Argument signature:

```C
(long long internal_latency, long long run_latency)
```
* arg0 - `internal_latency`: 64 bit integer holding nsecs spent in executing this probe, calculated against a monotonic source.
* arg1 - `run_latency`: 64 bit integer holding nsecs spent executing the tracepoint's target method or block.

It may be possible to for us to user Latency tracers for our own debugging purposes around other `fire` events, as this should show us the time that the kernel has stolen when the uprobe is executed. It may also be possible

## Stack probes

Method format:

```ruby
StaticTracing::Stacktracer.register(:my_func)
```

Manually specified name:
```ruby
t = StaticTracing::Stack.register(name: my_awesome_block)

t.fire
```
* arg0 - `internal_latency`: 64 bit integer holding nsecs spent in executing this probe, calculated against a monotonic source.
* arg1 - `run_latency`: 64 bit integer holding nsecs spent executing the tracepoint's target method or block.

These tracers would fire the stack trace when the symbol for a method is entered or block would be executed.

It would be great to be able to fire off the current call stack, eg by wrapping [code from vm\_backtrace](https://github.com/ruby/ruby/blob/a8695d5022d7afbf004765bfb86457fbb9d56457/vm_backtrace.c#L987)

This could provide something like “StaticTracing::Stack”, but we would need to be very conscious of the overhead of grabbing these stack traces, and profile the underlying ruby C code for this. This is certain to be more expensive than just calculating latency.

The overhead here seems to all be in `ec_backtrace_to_ary` which does same processing of the execution context pointer from `GET_EC`. We should profile this function a lot to see if it results in observable overhead, and examine the implementation closely to determine the worst case runtime complexity.

This functionality could allow for building flamegraphs and doing stack profiling, but only for those methods who are participating in tracing, so this is an incomplete view as compared to other profiling techniques already available.

## MRI probes

This is a general term for a suite of possible tools that could provide deeper insight into MRI.

Especially if the tracers are written in C, they can be used to analyze a number of ruby internals directly at the source-code level.

This could provide deaper insight into heap and stack usage, as well as object allocations and garbage collection.

These could be tailored to a particular function, and then placing a Tracepoint would allow reading the desired
internal state at a particular point of execution.

Eg, placing a `Heaptracer` at the start and end of a request could give insight into how a given request may have caused the characteristics of the heap to change.

## Custom probes

This is a general catch-all for defining new tracepoints on-the-fly.

Defining custom probes in a block format will require that the block return the values to be fired.

This is probably the most robust usage of the custom tracepoint, and potentially the most dangerous.


```ruby
StaticTracing.tracepoint(:my_provider, :my_custom_probe, Float, String) do
  start = StaticTracing.nsec
  string_value = get_value
  finish = StaticTracing.nsec
  (finish-start, string_value)
end
```

# Usage

## Including on a class or module

For each type of built-in tracer, a helper module should exist to trivially wrap all methods defined directly on (not inheriton on) a class
or module that includes the tracer to have a tracepoint automatically wrap each method.

For example:

```ruby

class MyController
  include StaticTracing::Helper::Latency
  def index; end
  def create; end
  def default_url_options; end
  def current_user; end
end
```

This should result in the following tracepoints being added to the process:

```
usdt:/tmp/XXXX.so:my_controller:show
usdt:/tmp/XXXX.so:my_controller:index
usdt:/tmp/XXXX.so:my_controller:create
usdt:/tmp/XXXX.so:my_controller:default_url_options
usdt:/tmp/XXXX.so:my_controller:current_user
```

And, using `bpftrace`, we can attach to each of these and summarize the total time in nanoseconds spent executing each:

```
bpftrace -e 'usdt::my_controller:* { @[probe] = sum(arg1); }' -p ${UNICORN_PID}
Attaching 1 probe...
^C

@[usdt:my_controller:current_user]: 51
@[usdt:my_controller:index]: 355
@[usdt:my_controller:create]: 5043
```
