FROM debian:buster-slim

ENV UID=1000
ENV GID=1000
ENV FIRMWARE_PATH="dump.bin"

RUN apt update -y && apt install -y git wget sudo
RUN git clone https://github.com/TheLastBilly/firmware-analysis-toolkit

WORKDIR /firmware-analysis-toolkit 

# firmware-analysis-toolkit's installation steps were taken from 
# https://github.com/attify/firmware-analysis-toolkit/blob/master/setup.sh

ENV DEBIAN_FRONTEND noninteractive
RUN mkdir -p /usr/share/man/man1mkdir -p /usr/share/man/man1
RUN apt update -y && apt install -y \
    python-pip \
    python3-pip \
    python3-pexpect \
    unzip \
    busybox-static \
    fakeroot \
    kpartx \
    snmp \
    uml-utilities \
    util-linux \
    vlan \
    qemu-system-arm \
    qemu-system-mips \
    qemu-system-x86 \
    qemu-utils \
    openjdk-11-jre-headless:amd64 \
    openjdk-11-jre:amd64 \
    openjdk-11-jdk-headless:amd64 \
    default-jre \
    default-jdk-headless \
    openjdk-11-jdk:amd64 \
    default-jdk

# Installing binwalk
RUN git clone --depth=1 https://github.com/devttys0/binwalk.git
WORKDIR /firmware-analysis-toolkit/binwalk
RUN chmod +x ./deps.sh && ./deps.sh --yes
RUN python3 ./setup.py install
RUN pip3 install git+https://github.com/ahupp/python-magic
RUN pip install git+https://github.com/sviehb/jefferson
WORKDIR /firmware-analysis-toolkit

# Installing firmadyne
RUN git clone --recursive https://github.com/firmadyne/firmadyne.git
WORKDIR /firmware-analysis-toolkit/firmadyne
RUN ./download.sh

# Set FIRMWARE_DIR in firmadyne.config
RUN sed -i "/FIRMWARE_DIR=/c\FIRMWARE_DIR=/firmware-analysis-toolkit/firmadyne" firmadyne.config

# Comment out psql -d firmware ... in getArch.sh
RUN sed -i 's/psql/#psql/' ./scripts/getArch.sh

# Change interpretor in extractor.py to python3
RUN sed -i 's/env python/env python3/' ./sources/extractor/extractor.py
WORKDIR /firmware-analysis-toolkit/

# Setting up firmware analysis toolkit
RUN chmod +x fat.py
RUN chmod +x reset.py

# Set firmadyne_path in fat.config
# RUN sed -i "/firmadyne_path=/c\firmadyne_path=/firmware-analysis-toolkit/firmadyne" fat.config

WORKDIR /firmware-analysis-toolkit/qemu-builds
RUN wget -O qemu-system-static-2.5.0.zip "https://github.com/attify/firmware-analysis-toolkit/files/4244529/qemu-system-static-2.5.0.zip"
RUN unzip -qq qemu-system-static-2.5.0.zip && rm qemu-system-static-2.5.0.zip

RUN echo "[DEFAULT]" > /firmware-analysis-toolkit/fat.config
RUN echo 'sudo_password="rootpass"' >> /firmware-analysis-toolkit/fat.config
RUN echo 'firmadyne_path=/firmware-analysis-toolkit/firmadyne/' >> /firmware-analysis-toolkit/fat.config

COPY ./entrypoint.sh /entrypoint.sh
RUN mkdir /firmware
WORKDIR /firmware-analysis-toolkit

# RUN useradd -m fat --uid=${UID}
# RUN usermod -aG sudo fat
# RUN echo 'fat:rootpass' | chpasswd
# RUN echo 'fat ALL=(ALL) NOPASSWD: ALL' | sudo EDITOR='tee -a' visudo

CMD ["/entrypoint.sh"]