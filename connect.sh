#!/bin/bash

tailscaled --tun=userspace-networking --socks5-server=localhost:1055 &
until tailscale up --authkey=$KEY
do
    sleep 0.1
done
