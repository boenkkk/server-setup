#!/bin/bash

# Source server details
SRC_SERVER="source_server"
SRC_USER="source_user"

# Destination server details
DST_SERVER="destination_server"
DST_USER="destination_user"

# Directory to save tar files
EXPORT_DIR="/path/to/export"
IMPORT_DIR="/path/to/import"

# List all containers
containers=$(ssh $SRC_USER@$SRC_SERVER "docker ps -a -q")

# Export all containers
for container in $containers; do
  ssh $SRC_USER@$SRC_SERVER "docker export $container -o $EXPORT_DIR/container_$container.tar"
  scp $SRC_USER@$SRC_SERVER:$EXPORT_DIR/container_$container.tar $DST_USER@$DST_SERVER:$IMPORT_DIR
  ssh $DST_USER@$DST_SERVER "docker import $IMPORT_DIR/container_$container.tar imported_image_$container"
  ssh $DST_USER@$DST_SERVER "docker run -d --name new_container_$container imported_image_$container"
done
