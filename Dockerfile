FROM ubuntu:18.04

# This dockerfile is multi-purpose, to serve as a complete development environment for the projcet.
# It will set up an environment te build against ruby 2.4, with dtrace probes enabled for some functional tests.
# To actually run USDT probes, this container will probably need to be run privileged in CI.

# Add the repository
RUN apt-get update && apt-get install -y wget gnupg && gpg --keyserver keyserver.ubuntu.com --recv ED0AF6FB72C51845 && rm -rf /var/lib/apt/lists/*  && apt-get clean
RUN gpg --export --armor ED0AF6FB72C51845 | apt-key add -
RUN echo 'deb http://ppa.launchpad.net/sthima/oss/ubuntu xenial main' >> /etc/apt/sources.list.d/libstapsdt.list

# Install dependencies
# systemtap-sdt-dev is to have stubs for ruby dtrace probes
# libstapsdt is sfor wrapping for gem
RUN apt-get update && apt-get install -y systemtap-sdt-dev libstapsdt0 libstapsdt-dev && rm -rf /var/lib/apt/lists/*  && apt-get clean

# Install ruby build deps FIXME - abstract this away into builder?
RUN apt-get update && apt-get install -y build-essential \
                                         bison \
                                         zlib1g-dev \
                                         libyaml-dev \
                                         libssl-dev \
                                         libgdbm-dev \
                                         libreadline-dev \
                                         libncurses5-dev \
                                         libffi-dev && rm -rf /var/lib/apt/lists/*  && apt-get clean

# Install a ruby with dtrace probes enabled
# this is to ensure that we have a fully-featured ruby
RUN wget -O ruby-install-0.7.0.tar.gz https://github.com/postmodern/ruby-install/archive/v0.7.0.tar.gz && \
    tar -xzvf ruby-install-0.7.0.tar.gz && \
    cd ruby-install-0.7.0 && \
    make install && rm -rf /ruby-install*
RUN ruby-install ruby 2.5.5 -- --enable-dtrace && rm -rf /usr/local/src/ruby*
ENV PATH=${PATH}:/opt/rubies/ruby-2.5.5/bin/
RUN echo 'PATH=${PATH}:/opt/rubies/ruby-2.5.5/bin/' >> /etc/bash.bashrc
RUN gem install bundler
WORKDIR /app
