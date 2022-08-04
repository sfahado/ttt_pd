#!/bin/bash
set -e

echo "Required Docker-compose installed"

# Remove a potentially pre-existing server.pid for Rails.
rm -f /ttt_pd/tmp/pids/server.pid

# Then exec the container's main process (what's set as CMD in the Dockerfile).
exec "$@"
