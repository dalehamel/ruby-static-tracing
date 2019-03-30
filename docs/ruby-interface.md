# Configuration

The gem should store these in a config object, that it will check to determine its behavior.

This will allow the user to override the default behavior, eg:

```ruby
StaticTracing::Configuration.some_config = "My Awesome Value"
```

## Method overriding

```ruby
StaticTracing::Configuration.mode = StaticTracing::Configuration::Modes::SIGNAL
StaticTracing::Configuration.signal = StaticTracing::Configuration::Modes::SIGNALS::SIGTRAP
```

Where a tracepoint accepts a method as an argument, there are three options:
- "ON": Immediately replace the definition of the original method with a wrapped version that adds the tracepoint.
- "OFF": Require manually toggling tracepoints on and off within source code
- "SIGNAL": Activate behavior of "ON" upon receiving `SIGTRAP`, or a user-defined signal to replace this with a configuration value. Upon receiving the signal again, it will be toggled back to "OFF".

SIGNAL should be the default behavior.

The extra processing overhead added by "ON" should always be limited to checking if a probe is enabled, and the cost of returning from a wrapper methed - both of which should be known and low overhead.

# Ruby API

## Registering a provider

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

## Manually create a single probe

```
tracepoint = provider.add_tracepoint(method_name, *vargs) (vargs should be a list of basic types)
```

The tracepoint will have some basic methods:

```ruby
tracepoint.fire(*vargs) # verify that they match the types and order match what was given when the tracepoint was registered
                        # a tracepoint wil only fire if both it and its provider are enabled, and it is attached to by a tracer.
tracepoint.load         # this will replace the method or block to be probed with a wrapped version. If the probe is attached to, it will fire.
tracepoint.unload       # this will remove a probe from the request flow, replacing wrapped methods or blocks with their original implementations

tracepoint.enabled?     # used to check if a tracepoint is currently attached to by a tracer.
```

## Implicitly create a tracepoint

Tracepoints should also be able to be declared directly, accepting the provider name as a parameter to the initializer.

If a provider of that name already exists, it should be registered against that.

If there is no provider of that name yet, then a new provider will be created to register the probe against.

```
tracepoint = StaticTracing::Tracepoint.new(provider, name, *vargs)
tracepoint.fire(*vargs)
```

## Firing a tracepoint

"Firing" is emitting data to be traced/probed by an external observer such as bpftrace or dtrace.


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


# Built-in Probes

## Latency probes

Block format:

```ruby
StaticTracing.latency(name: my_awesome_block) do
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
StaticTracing.latency(my_func)
```

This should generate a probe using the existing class/module as a provider (and accept an optional parameter to specify it explicitly).

Registering a tracepoint against an existing method name should cause the original name to be replaced by the traced version depending on configuration.

# Custom probes

## Block format

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

Simply including static tracing no a class or module should result in tracepoints being created for each method of in that namespace.

```ruby

class MyController
  include StaticTracing::LatencyTracer
  def index; end
  def create; end
  def default_url_options; end
  def current_user; end
end
```

This should result in the following tracepoints being added to the process:

```
usdt::my_controller:show
usdt::my_controller:index
usdt::my_controller:create
usdt::my_controller:default_url_options
usdt::my_controller:current_user
```
And it should be possible, without any other modifications, to simply count the number of times that a probe has been fired:

```
bpftrace -e 'usdt:*:my_controller:* { @[probe] = hist(arg0); }' -p ${UNICORN_PID}
Attaching 1 probe...
^C

@[test]: 10
@[index]: 3
@[create]: 1

```

