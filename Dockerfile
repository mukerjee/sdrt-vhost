FROM ubuntu

MAINTAINER Matt Mukerjee "mukerjee@cs.cmu.edu"

RUN apt-get update && apt-get install -y \
                              net-tools \
                              iputils-ping \
			      gcc \
			      cmake \
    && rm -rf /var/lib/apt/lists/*

# Install pipework
ADD https://raw.githubusercontent.com/jpetazzo/pipework/master/pipework /usr/local/bin/pipework
RUN chmod +x /usr/local/bin/pipework

# build SDRT adu-send
ADD https://github.com/mukerjee/sdrt/archive/master.tar.gz /tmp/sdrt.tar.gz
WORKDIR /root
RUN tar xfz /tmp/sdrt.tar.gz && mv sdrt-master sdrt
WORKDIR /root/sdrt/adu-send/lib
RUN make -j install

RUN rm /tmp/*.tar.gz
