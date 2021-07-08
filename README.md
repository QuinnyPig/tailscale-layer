# Tailscale Layer For AWS Lambda

To build:
```
make init
make tailscale
make upload
make publish
```

At the moment this deploys only to us-west-2 for testing purposes. 

## Usage Instructions

Generate [an ephemeral key](https://login.tailscale.com/admin/settings/authkeys) within your Tailscale account.

**Note that this will expire six months after creation.**

Assign that key as the value to a parameter named `TS_KEY` on the Lambda you wish to use with this layer.

There is now a SOCKS5 proxy listening on localhost:1055 that connects to your Tailscale network. Use it as you see fit.
