#!/bin/bash

docker run -ti -e UID=$(id -u) -e GID=$(id -g) -e FIRMWARE_PATH="$1" -v $(pwd):/firmware thelastbilly:fat-contained