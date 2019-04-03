# Getting going quickly

## Prerequisites

You must have a docker host running on your computer. This can be acheived by
following the following steps, assuming you're running macOS.

```
# install docker machine & the xhyve hypervisor
brew install docker docker-machine-driver-xhyve

# docker-machine-driver-xhyve need root owner and uid
sudo chown root:wheel $(brew --prefix)/opt/docker-machine-driver-xhyve/bin/docker-machine-driver-xhyve
sudo chmod u+s $(brew --prefix)/opt/docker-machine-driver-xhyve/bin/docker-machine-driver-xhyve

# create your docker host
docker-machine create -d xhyve host

# set up your shell environment to use that host
eval $(docker-machine env host)
```

Then you can run these commands, from within this gems root directory:

```
bundle install
rake docker:build
rake docker:run
```

This should build you a container with suitable deps to get going to be able to build the gem and run unit tests.

FIXME - can we do this in dev?

FIXME - tag images and do additional setup in them

FIXME - get this to be something that will work in CI

# Development libraries

If you use the Dockerfile, you can skip this.

This gem can be easily developed and packaged in an ubuntu container.

You'll need `libstapsdt`, you can install this in ubuntu using the xenial (16.04) repository:

```
sudo add-apt-repository ppa:sthima/oss
sudo apt-get update
sudo apt-get install libstapsdt0 libstapsdt-dev
```

Or build it yourself from source.

From there, you will be able to package the gem and test it on a compatibily linux host.

```
rake build
```

# Running

You will need a fairly modern linux kernel to test out development. 4.8 should work, but 4.14 or higher is recommended for the necessary eBPF features.

The easiest way to do this might be in a cloud server, or by spinning up a VM in vmware (easy) or xhyve (advanced) on OS X.

If you have linux locally, you can use kvm or ideally run against your existing setup.

All of the kernel requirements of github.com/iovisor/bcc are required in order for this to work.

At Shopify, you can use the `shopify-toolbox` command to enter an environment that should work fine for development and general testing of this gem.

# Testing

## Library testing

Tests wrapping functionality in `libstapsdt` should be able to run in a local ubuntu image running in docker.

## E2E testing

Due to the need to access low-level kernel capabilities in a privileged context, this may be a difficult gem to end-to-end test.

If the testing environment provides root access and has a suitable kernel, then it should be possible to run E2E tests.

The test harness will need to be able to set up two processes, and will need a copy of bpftrace available.

Tests will probably take the form of checking output against fixtures, writing simple ruby programs that demonstrate the use of a tracepoint use-case, and then running a wrapper around `bpftrace` to execute a script to check that the probes are able to fire and give predicted output, and show up as registered against the process.

## Performance testing

Following on from the E2E tests, performance testing can be done in the same environment.

This sort of end-to-end testing can also be done to repeatedly register tracepoints and push edge cases to try and find performance issues.

This should allow for measuring the overhead of tracepoints, by calling traced functions with a high frequency and collecting lots of samples of a traced vs untraced version.
