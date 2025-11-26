#!/bin/bash
set -e

# Remove a potentially pre-existing server.pid for Rails.
rm -f /opt/app/tmp/pids/server.pid

# Wait for database to be ready
echo "Waiting for database..."
until pg_isready -h ${DATABASE_HOST:-db} -U ${DATABASE_USERNAME:-schools}; do
  echo "Database is unavailable - sleeping"
  sleep 1
done

echo "Database is up - executing command"

# Create database if it doesn't exist
echo "Creating database if it doesn't exist..."
bundle exec rake db:create || true

# Run migrations
echo "Running migrations..."
bundle exec rake db:migrate

# Execute the main command
exec "$@"
