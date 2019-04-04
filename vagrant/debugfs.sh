#!/bin/bash
grep -q debugfs /proc/mounts || mount -t debugfs debugfs /sys/kernel/debug/
