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

# Resources

- [bpftrace reference guide](https://github.com/iovisor/bpftrace/blob/master/docs/reference_guide.md)
- [Dtrace aggregation functions reference guide](http://dtrace.org/guide/chp-aggs.html)
