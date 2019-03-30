# How this works

In short, this works by creating static tracepoints, dynamically.

To illustrate the point, we'll how we're able to add static tracepoints to python, which is similar to what we'll be doing here with ruby.

# Python example

Examining the [python wrapper](https://github.com/sthima/python-stapsdt), we can see a sample probe program:

```python
from time import sleep

import stapsdt

provider = stapsdt.Provider("pythonapp")
probe = provider.add_probe(
    "firstProbe", stapsdt.ArgTypes.uint64, stapsdt.ArgTypes.int32)
provider.load()


while True:
    if probe.fire("My little probe", 42):
        print("Probe fired!")
    sleep(1)
```

And so, a probe n bpftrace can be constructed using:

* *provider* : `pythonapp`
* *probe name* : `firstProbe`

```
bpftrace -e 'usdt::pythonapp:firstProbe { printf("%s %d\n", str(arg0), arg1) }' -p ${PYTHON_PID}
```

This should cause bpftrace to print `My little probe 42`, and the python program to print `Probe fired!`.

When you stop bpftrace, the python program should stop printing.

# The magic sauce

Normally, static probes should be defined in source code, usually in a C program.

They register a provider (basically a namespace), and a probe name, as well as a description of the data type
for the probe.

This is great for something like the Ruby VM, where probe points can (and are) be built right into the source code.

For the ruby language itself, however, we need to be clever in order to register tracepoints in ruby-land.

In libstapsdt, this is achieved by creating an ELF binary on-the-fly for each provider, and registering tracepoints against this stubbed out shared library.

Any dynamic language just needs to `dlopen` this shared library, and it should be able to expose a number of static tracepoints.

## Shared library stub

Upon registering a provider, we can see that libstapsdt has created a stub library by listing the tracepoints of the process:

```
tplist -p 7371
/tmp/pythonapp-7QYyFE.so pythonapp:firstProbe
```

If we inspect this stub library, we can see that the probe definition is in the ELF notes section:

```
readelf --notes /tmp/pythonapp-7QYyFE.so

Displaying notes found in: .note.stapsdt
  Owner                 Data size       Description
  stapsdt              0x0000003c       NT_STAPSDT (SystemTap probe descriptors)
    Provider: pythonapp
    Name: firstProbe
    Location: 0x0000000000000260, Base: 0x0000000000000318, Semaphore: 0x0000000000000000
    Arguments: 8@%rdi -4@%rsi
```

This contains the provider and probe name, as well as the address of the probe and the arguments it specifies.

The python helper will `dlopen` this library, adding these probes to its process image when it pulls in these stub libraries.

## int3 (0x90) and uprobes

The other bit of magic here is that the probe automatically becomes enabled when it is attached to.

This is pretty hard to track down, as it actually happening inside the kernel when the probe is enabled:

```
 bpftrace -e 'kprobe:is_trap_insn { printf("%s\n", kstack) }'
Attaching 1 probe...

        is_trap_insn+1
        install_breakpoint.isra.12+546
        register_for_each_vma+792
        uprobe_apply+109
        trace_uprobe_register+429
        perf_trace_event_init+95
        perf_uprobe_init+189
        perf_uprobe_event_init+65
        perf_try_init_event+165
        perf_event_alloc+1539
        __se_sys_perf_event_open+401
        do_syscall_64+90
        entry_SYSCALL_64_after_hwframe+73
```

We can see that attaching the uprobe via the perf event is what causes the probe to be enabled, and this is visible to the userspace process.

So long as all calls to fire a probe are wrapped in an (extremely fast) is-enabled check, they should return quickly if disabled.

The above processing is also only done when a probe is enabled / disabled, meaning that it is not overhead that is incurred each time a probe is actually fired.

# Measuring performance of tracing itself

Using bpftrace, we can approximate the overhead of getting the current monoonic time. By examining the C code in ruby, we can see that 
`Process.clock_gettime(Process::CLOCK_MONOTONIC)` is merely a [wrapper around the libc function clock_gettime](https://github.com/ruby/ruby/blob/trunk/process.c#L7882-L7892).

Attaching to a Pry process and calling this function, we can get the nanosecond latency of obtaining this timing value from libc:

```
bpftrace -e 'uprobe:/lib64/libc.so.6:clock_gettime /pid == 16138/ { @start[tid] = nsecs } uretprobe:/lib64/libc.so.6:clock_gettime /@start
[tid]/{ $latns = (nsecs - @start[tid]); printf("%d\n", $latns); delete(@start[tid]);}'
Attaching 2 probes...
11853
5381
5440
4624
3263
```

These are nanosecond values, which correspond to values between 0.005381 and 0.011853 ms. So, getting the before and after time adds on the order of about one hundredth of a millisecond of time spend in the thread.

This means that it would take about one hundred probed methods to add one millisecond to a service an application request. If requests are close to 100ms to begin with, this should make the overhead of tracing nearly negligible.

we must also measure the speed of checking if a probe is enabled to get the full picture, as well as any other in-line logic that is performed.

# Further reading

* http://www.brendangregg.com/blog/2015-07-03/hacking-linux-usdt-ftrace.html
* http://www.joelfernandes.org/linuxinternals/2018/02/10/usdt-notes.html
* https://sourceware.org/systemtap/wiki/UserSpaceProbeImplementation
* https://medium.com/sthima-insights/we-just-got-a-new-super-power-runtime-usdt-comes-to-linux-814dc47e909f
* https://github.com/jav/systemtap/blob/master/runtime/uprobes/uprobes.txt
