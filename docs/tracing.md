# tracing tools

To get real value out of this gem, you're going to want to familiarize yourself with a traceing tool that it works with. There are a lot of resources available (see below) for these if you want to know more about them, but we'll demonstrate some basic uses here.

## dtrace

In development, dtrace comes with OS X and can be used out-of-the-box.

When you run dtrace, it will complain about system integrity protection (SIP), which is an important security feature of OS X. Luckily, it doesn't get in the way of how we implement probes here so the warning can be ignored.

You do, still, need to run dtrace as root, so have your `sudo` password ready.

dtrace can run commands specified by a string with the `-n` flag, or run script files (conventionally ending in `.dt`), with the `-s` flag.

## bpftrace

bpftrace is an emerging new tool that is based on eBPF support added to version 4.1 of the linux kernel. While rapidly under development, it already supports much of dtrace's functionality.

You can use bpftrace in production systems to attach to and summarize data from trace points similarly to with dtrace.

Like dtrace, you can run bpftrace programs by specifying a string with the `-e` flag, or by running a bpftrace script (conventionally ending in `.bt`) directly.

dtrace scripts can often be easily converted to bpftrace scripts (see [this cheatsheet](http://www.brendangregg.com/blog/2018-10-08/dtrace-for-linux-2018.html)).

# Examples

For most examples, we'll assume you have two terminals side-by-side:

- One to run the program you want to trace (referred to as tracee).
- One to run your tracing program and observe the output (bpftrace or dtrace).

We'll give examples of both bpftrace and dtrace invocations that you should be able to paste into a terminal yourself, as well as show you the output.

The source and all of these scripts are available in the [examples folder](../examples) of this repository.

## Listing tracepoints

To list tracepoints that you can trace:

On Darwin/OSX:

```
dtrace -l -P "${PROVIDER}${PID}"
```

Using bpftrace: (upstream issue in progress to add similary functionality to above)
```
tplist -p ${PROCESS}
```

## Simple hello world

This example prints a 64 bit timestamp representing nanosecond time from a monotonic source, as well as a "hello world" statement, as is tradition.

This is a simplified version of the full [tock.rb script](../examples/tock.rb):

```ruby
t = StaticTracing::Tracepoint.new('global', 'hello_nsec', Integer, String)
p = StaticTracing::Provider.fetch(t.provider)
p.enable

while true do
  if t.enabled?
    t.fire(StaticTracing.nsec, "Hello world")
  else
    puts "Not enabled"
  end
  sleep 1
end
```

This example:

* Creates a provider implicitly through it's reference to 'global', and indicates that it will be firing off an Integer and a String to the tracepoint.
* Registering the tracepoint is like a function declaration - when you fire the tracepoint later, the fire call must match the signature declared by the tracepoint.
* We fetch the the provider that we created, and enable it.
* Enabling the provider loads it into memory, but the tracepoint isn't enabled until it's attached to.

Then, in an infinite loop, we check to see if our tracepoint is enabled, and fire it if it is.

When we run `tock.rb`, it will loop and print:

> Not enabled
> Not enabled
> Not enabled

One line about every second. Not very interesting, right?

When we run our tracing program though:

With dtrace

```
dtrace -q -n 'global*:::hello_nsec { printf("%lld %s\n", arg0, copyinstr(arg1)) }'
```

With dtrace and a script:

```
dtrace -q -s tock.dt
```

With bpftrace (in production, or in vagrant):

```
bpftrace -e 'usdt::global:hello_nsec { printf("%lld %s\n", arg0, str(arg1))}' -p $(pgrep -f ./tock.rb)
```

With bpftrace, using a script:
```
bpftrace ./tock.bt -p $(pgrep -f ./tock.rb)
```

We'll notice that the output changes to indicate that the probe has been fired:

> Not enabled
> Probe fired!
> Probe fired!
> Probe fired!

And, from our tracing program we see:

```
Attaching 1 probe...
55369896776138 Hello world
55370897337512 Hello world
55371897691043 Hello world
```

Upon interrupting our tracing program with Control+C, the probes continue to fire.

This demonstrates:

* How to get data from ruby into our tracing program using a tracepoint.
* That probes are only enabled when they are attached to.
* How to read integer and string arguments.
* Basic usage of bpftrace and dtrace with this gem.

In subsequent examples, none of these concepts are covered again.

## Aggregation functions

While the hello world sample above is powerful for debugging, it's basically just a log statement.

To do something a little more interesting, we can use an aggregation function.

Both bpftrace and dtrace support generating both linear and log2 histograms. linear histograms show the same
data that is used to construct an ApDex. This type of tracing is good for problems like understanding
request latency.

For this example, we'll use [randist.rb](../examples/randist.rb) to analyze a pseudo-random distribution of data.

The example should fire out random integers between 0 and 100. We'll see how random it actually is with a linear histogram,
bucketing the results into steps of 10:

```
bpftrace -e 'usdt::global:randist {@ = lhist(arg0, 0, 100, 10)}' -p $(pgrep -f ./randist.rb)
Attaching 1 probe...
^C

@:
[0, 10)           817142 |@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@|
[10, 20)          815076 |@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ |
[20, 30)          815205 |@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ |
[30, 40)          814752 |@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ |
[40, 50)          815183 |@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ |
[50, 60)          816676 |@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ |
[60, 70)          816470 |@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ |
[70, 80)          815448 |@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ |
[80, 90)          816913 |@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ |
[90, 100)         814970 |@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@ |

```

It's actually pretty evenly distributed, that's a good sign or a random number generator!

And the results are similar on Darwin:

```
 sudo dtrace -q -n 'global*:::randist { @ = lquantize(arg0, 0, 100, 10) }'
Password:
dtrace: system integrity protection is on, some features will not be available

^C


           value  ------------- Distribution ------------- count    
             < 0 |                                         0        
               0 |@@@@                                     145456   
              10 |@@@@                                     145094   
              20 |@@@@                                     145901   
              30 |@@@@                                     145617   
              40 |@@@@                                     145792   
              50 |@@@@                                     145086   
              60 |@@@@                                     146287   
              70 |@@@@                                     146041   
              80 |@@@@                                     145331   
              90 |@@@@                                     145217   
          >= 100 |                                         0        

```

Though note the histogram's format and scale are a little different.

There are similar aggregation functions for max, mean, count, etc that can be used to summarize large data sets - check them out!

## Latency distributions

This example will profile the function call that we use for getting the current monotonic time in nanoseconds:

```
StaticTracing.nsec
```

Under the hood, this is just calling a libc function to get the current time against a monotonic source. This is how
we calculate the latency in wall-clock time. Since we will be potentially running this quite a lot, we want it to be fast!

The [nsec.rb](../examples/nsec.rb) script computes the latency of this call and fires it off in a probe.

Attaching to it with a log2 histogram, we can see that it clusters within a particular latency range:

```
bpftrace -e 'usdt::global:nsec_latency {@ = hist(arg0)}' -p $(pgrep -f ./nsec.rb)
Attaching 1 probe...
^C

@:
[256, 512)            65 |                                                    |
[512, 1K)            162 |@@                                                  |
[1K, 2K)            3647 |@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@|
[2K, 4K)            3250 |@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@      |
[4K, 8K)               6 |                                                    |
[8K, 16K)              0 |                                                    |
[16K, 32K)            12 |                                                    |
[32K, 64K)             2 |                                                    |

```

Let's zoom in on that with a linear histogram to get a better idea of the latency distribution:

```
bpftrace -e 'usdt::global:nsec_latency {@ = lhist(arg0, 0, 3000, 100)}' -p $(pgrep -f ./nsec.rb)
Attaching 1 probe...
^C

@:
[300, 400)             1 |                                                    |
[400, 500)            33 |@                                                   |
[500, 600)            50 |@@                                                  |
[600, 700)            49 |@@                                                  |
[700, 800)            42 |@@                                                  |
[800, 900)            21 |@                                                   |
[900, 1000)           15 |                                                    |
[1000, 1100)           9 |                                                    |
[1100, 1200)          11 |                                                    |
[1200, 1300)           4 |                                                    |
[1300, 1400)          16 |                                                    |
[1400, 1500)           9 |                                                    |
[1500, 1600)           7 |                                                    |
[1600, 1700)           8 |                                                    |
[1700, 1800)          70 |@@@                                                 |
[1800, 1900)         419 |@@@@@@@@@@@@@@@@@@@@@                               |
[1900, 2000)         997 |@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@@|
[2000, 2100)         564 |@@@@@@@@@@@@@@@@@@@@@@@@@@@@@                       |
[2100, 2200)          98 |@@@@@                                               |
[2200, 2300)          37 |@                                                   |
[2300, 2400)          30 |@                                                   |
[2400, 2500)          36 |@                                                   |
[2500, 2600)          46 |@@                                                  |
[2600, 2700)          86 |@@@@                                                |
[2700, 2800)          74 |@@@                                                 |
[2800, 2900)          42 |@@                                                  |
[2900, 3000)          26 |@                                                   |
[3000, ...)           35 |@                                                   |

```

We can see that most of the calls are happening within 1700-2200 nanoseconds, which is pretty blazing fast, around 1-2 microseconds.
Some are faster, and some are slower, representing the long-tails of this distribution, but this can give us confidence that this call will complete quickly.

# Resources

- [bpftrace reference guide](https://github.com/iovisor/bpftrace/blob/master/docs/reference_guide.md)
- [Dtrace aggregation functions reference guide](http://dtrace.org/guide/chp-aggs.html)
