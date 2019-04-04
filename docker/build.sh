#!/bin/bash

docker build -f Dockerfile.ci . -t static-tracing-test:latest
