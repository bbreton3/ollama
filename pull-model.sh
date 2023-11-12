#!/bin/sh
set -e

# Start the ollama server in the background
/bin/ollama serve &
OLLA_PID=$!

# Wait for the server to be ready
sleep 5

# Execute the pull command
/bin/ollama pull zephyr

# Kill the server
kill $OLLA_PID
wait $OLLA_PID

# Exit
exit 0
