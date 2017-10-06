###############
## Base image
###############
FROM ubuntu AS sdrt-base

MAINTAINER Matt Mukerjee "mukerjee@cs.cmu.edu"

RUN apt-get update && apt-get install -y \
                              gcc \
                              cmake \
                              wget \
    && rm -rf /var/lib/apt/lists/*

# Install pipework
WORKDIR /usr/local/bin
RUN wget https://raw.githubusercontent.com/jpetazzo/pipework/master/pipework \
    && chmod +x pipework

# build SDRT adu-send
WORKDIR /root
RUN wget https://github.com/mukerjee/sdrt/archive/master.tar.gz \
    && tar xfvz master.tar.gz \
    && cd sdrt-master/adu-send/lib \
    && make -j install \
    && cd /root \
    && rm -rf sdrt-master master.tar.gz


###############
## flowgrindd
###############
FROM ubuntu AS sdrt-flowgrindd
COPY --from=sdrt-base /usr/local/bin/pipework /usr/local/bin/pipework
COPY --from=sdrt-base /usr/local/lib/adu-send.so /usr/local/lib/adu-send.so
RUN apt-get update && apt-get install -y \
			      flowgrind \
    && rm -rf /var/lib/apt/lists/*

CMD pipework --wait && pipework --wait -i eth2 && flowgrindd -d


###############
## iperf
###############
FROM ubuntu AS sdrt-iperf
COPY --from=sdrt-base /usr/local/bin/pipework /usr/local/bin/pipework
COPY --from=sdrt-base /usr/local/lib/adu-send.so /usr/local/lib/adu-send.so
RUN apt-get update && apt-get install -y \
			      iperf \
    && rm -rf /var/lib/apt/lists/*

CMD pipework --wait && pipework --wait -i eth2 && iperf -s


###############
## iperf3
###############
FROM ubuntu AS sdrt-iperf3
COPY --from=sdrt-base /usr/local/bin/pipework /usr/local/bin/pipework
COPY --from=sdrt-base /usr/local/lib/adu-send.so /usr/local/lib/adu-send.so
RUN apt-get update && apt-get install -y \
			      iperf3 \
    && rm -rf /var/lib/apt/lists/*

CMD pipework --wait && pipework --wait -i eth2 && iperf3 -s


###############
## hadoop
###############
FROM ubuntu AS sdrt-hadoop
COPY --from=sdrt-base /usr/local/bin/pipework /usr/local/bin/pipework
COPY --from=sdrt-base /usr/local/lib/adu-send.so /usr/local/lib/adu-send.so
RUN apt-get update && apt-get install -y \
                              software-properties-common
RUN add-apt-repository ppa:openjdk-r/ppa 
RUN apt-get update && apt-get install -y \
                              openjdk-7-jdk \
                              maven \
                              wget \
    && rm -rf /var/lib/apt/lists/*

WORKDIR /root
RUN wget https://github.com/intel-hadoop/HiBench/archive/master.tar.gz \
    && tar xfz master.tar.gz \
    && mv HiBench-master HiBench \
    && rm master.tar.gz

CMD pipework --wait && pipework --wait -i eth2
