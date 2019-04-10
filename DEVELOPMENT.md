# Linux

On linux, we depend on eBPF.

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

# Darwin

On darwin, you use dtrace. 

# Testing

We use minitest for this gem's tests.

## Unit tests

We have unit tests, they can be run with:

```
bundle exec rake test
```

## Integration tests

We have integration tests, they can be run with:

```
bundle exec rake integration
```

You will need a system that can actually support probes (new enough kernel/eBPF support, dtrace) in order to run integration tests.

The integration tests are [described further in their README](./test/integration/README.md)

# Dependencies

## Linux

To build libstapsdt, you must have libelf. Install it for your system, along with related development packages.
