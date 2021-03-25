#!/bin/sh

# usermod -u $UID fat
# groupmod -g $GID fat

# chown -R fat:fat /firmware-analysis-toolkit

# sudo -i -u fat bash << EOF
cd /firmware-analysis-toolkit/
/firmware-analysis-toolkit/fat.py /firmware/$FIRMWARE_PATH
/bin/bash
# EOF