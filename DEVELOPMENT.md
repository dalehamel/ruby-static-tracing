# Prerequisites

This functionality depends on having both a linux machine, and a recent linux kernel (4.18+ ideally).

This means we must set up a virtual machine to run linux for us.

## Vagrant

We'll use vagrant to get a VM up and running. To provision the vagrant VM, you should just need to:

* Install vagrant for mac from https://www.vagrantup.com/downloads.html
* Install virtualbox for mac from https://www.virtualbox.org/wiki/Downloads

If you've previously installed vagrant, blow away any old gems if you need to.

Once vagrant is installed, calling `vagrant up` from inside this repository should get everything set up.

You must run `vagrant ssh` to connect from your laptop to tho development VM.

Vagrant will share you application source directory at /vagrant, so you can use a local editor and the changes should be reflected in the VM.

Vagrant is just used to get us access to:

* A modern kernel (ubuntu cosmic ships with 4.18)
* A working docker daemon

## Docker

The development environment is packaged up as a docker container, which you can access from vagrant.

`vagrant up` should already have set up the docker container for you, so you should just be able to run:

```
bundle exec rake docker:shell
```

To get access to a shell.

Or, individually:

```
bundle exec rake docker:build
bundle exec rake docker:run
bundle exec rake docker:shell
```

From within this shell, you will now be running with your current working directory mounted within a linux environment.

This should build you a container with suitable deps to get going to be able to build the gem and run unit tests.

# Tock example

In one shell, start ruby:

```
bundle exec ruby ./test/tock.rb
```

In another shell, you should be able to probe this with bpftrace:

Get the pid:
```
ps -auxf | grep tock.rb | grep -v grep
```

Trace the function defined in tock.rb
```
bpftrace -e 'usdt::global:hello_nsec { printf("%lld %s\n", arg0, str(arg1))}' -p ${PID_OF_RUBY}
```

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
