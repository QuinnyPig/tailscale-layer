#!/bin/bash
# Copyright Amazon.com, Inc. or its affiliates. All Rights Reserved.
# SPDX-License-Identifier: MIT-0

set -euo pipefail
set -x

OWN_FILENAME="$(basename $0)"
LAMBDA_EXTENSION_NAME="$OWN_FILENAME" # (external) extension name has to match the filename
TMPFILE=/tmp/$OWN_FILENAME

# Graceful Shutdown
_term() {
  echo "[${LAMBDA_EXTENSION_NAME}] Received SIGTERM"
  # forward SIGTERM to child procs and exit
  kill -TERM "$PID" 2>/dev/null
  echo "[${LAMBDA_EXTENSION_NAME}] Exiting"
  exit 0
}

forward_sigterm_and_wait() {
  trap _term SIGTERM
  wait "$PID"
  trap - SIGTERM
}

# Registration
HEADERS="$(mktemp)"
echo "[${LAMBDA_EXTENSION_NAME}] Registering at http://${AWS_LAMBDA_RUNTIME_API}/2020-01-01/extension/register"
/opt/bin/curl -sS -LD "$HEADERS" -XPOST "http://${AWS_LAMBDA_RUNTIME_API}/2020-01-01/extension/register" --header "Lambda-Extension-Name: ${LAMBDA_EXTENSION_NAME}" -d "{ \"events\": [\"SHUTDOWN\", \"INVOKE\"]}" > $TMPFILE

RESPONSE=$(<$TMPFILE)
HEADINFO=$(<$HEADERS)
# Extract Extension ID from response headers
EXTENSION_ID=$(grep -Fi Lambda-Extension-Identifier "$HEADERS" | tr -d '[:space:]' | cut -d: -f2)
echo "[${LAMBDA_EXTENSION_NAME}] Registration response: ${RESPONSE} with EXTENSION_ID $(grep -Fi Lambda-Extension-Identifier "$HEADERS" | tr -d '[:space:]' | cut -d: -f2)"


#Start the Tailscale process
/opt/bin/tailscaled --tun=userspace-networking --socks5-server=localhost:1055 --socket=/tmp/tailscale.sock --state /tmp/tailscale &
until /opt/bin/tailscale --socket=/tmp/tailscale.sock up --authkey=$KEY
do
    sleep 0.1
done


# Event processing
while true
do
  echo "[${LAMBDA_EXTENSION_NAME}] Waiting for event. Get /next event from http://${AWS_LAMBDA_RUNTIME_API}/2020-01-01/extension/event/next"
  # Get an event. The HTTP request will block until one is received
  curl -sS -L -XGET "http://${AWS_LAMBDA_RUNTIME_API}/2020-01-01/extension/event/next" --header "Lambda-Extension-Identifier: ${EXTENSION_ID}" > $TMPFILE &
  PID=$!
  forward_sigterm_and_wait

  EVENT_DATA=$(<$TMPFILE)
  if [[ $EVENT_DATA == *"SHUTDOWN"* ]]; then
    echo "[extension: ${LAMBDA_EXTENSION_NAME}] Received SHUTDOWN event. Exiting."  1>&2;
    # Cleanly shut down the Tailscale process
    exit 0 # Exit if we receive a SHUTDOWN event
  fi

  echo "[${LAMBDA_EXTENSION_NAME}] Received event: ${EVENT_DATA}" 
  sleep 1

done
