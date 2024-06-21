#!/bin/bash

# Directory to save tar files
EXPORT_DIR="exported-container"

# Check if the export directory exists, if not, create it
if [ ! -d "$EXPORT_DIR" ]; then
  mkdir -p "$EXPORT_DIR"
  echo "Created directory $EXPORT_DIR"
else
  echo "Directory $EXPORT_DIR already exists"
fi

# List all containers
containers=$(docker ps -a -q)

# Export all containers
for container in $containers; do
  container_name=$(docker inspect --format='{{.Name}}' $container | cut -c2-)
  docker export $container -o $EXPORT_DIR/container_${container_name}_$container.tar
  echo "Exported container $container_name to $EXPORT_DIR/container_${container_name}_$container.tar" >> export.log
done
