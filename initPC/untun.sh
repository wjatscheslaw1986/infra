#!/bin/bash
ip route del default
ip route add 0/0 via $1
