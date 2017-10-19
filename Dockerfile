###############
## Base image
###############
FROM ubuntu AS base

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
    && tar xfz master.tar.gz \
    && cd sdrt-master/adu-send/lib \
    && make -j install \
    && cd /root \
    && wget https://github.com/mukerjee/libVT/archive/master.tar.gz \
    && tar xfz master.tar.gz.1 \
    && cd libVT-master \
    && make install \
    && cd /root \
    && rm -rf sdrt-master libVT-master master.tar.gz master.tar.gz.1


###############
## flowgrindd
###############
FROM ubuntu AS flowgrindd
COPY --from=base /usr/local/bin/pipework /usr/local/bin/pipework
COPY --from=base /usr/lib/adu-send.so /usr/lib/adu-send.so
COPY --from=base /usr/lib/libVT.so /usr/lib/libVT.so
COPY on_run.sh /root/
RUN chmod +x /root/on_run.sh
RUN apt-get update && apt-get install -y \
                              flowgrind \
    && rm -rf /var/lib/apt/lists/*

CMD pipework --wait \
    && pipework --wait -i eth2 \
    && /root/on_run.sh \
    && LD_PRELOAD=libVT.so flowgrindd -d


###############
## iperf
###############
FROM ubuntu AS iperf
COPY --from=base /usr/local/bin/pipework /usr/local/bin/pipework
COPY --from=base /usr/lib/adu-send.so /usr/lib/adu-send.so
COPY --from=base /usr/lib/libVT.so /usr/lib/libVT.so
COPY on_run.sh /root/
RUN chmod +x /root/on_run.sh
RUN apt-get update && apt-get install -y \
                              iperf \
    && rm -rf /var/lib/apt/lists/*

CMD pipework --wait \
    && pipework --wait -i eth2 \
    && /root/on_run.sh \
    && LD_PRELOAD=libVT.so iperf -s


###############
## iperf3
###############
FROM ubuntu AS iperf3
COPY --from=base /usr/local/bin/pipework /usr/local/bin/pipework
COPY --from=base /usr/lib/adu-send.so /usr/lib/adu-send.so
COPY --from=base /usr/lib/libVT.so /usr/lib/libVT.so
COPY on_run.sh /root/
RUN chmod +x /root/on_run.sh
RUN apt-get update && apt-get install -y \
                              iperf3 \
    && rm -rf /var/lib/apt/lists/*

CMD pipework --wait \
    && pipework --wait -i eth2 \
    && /root/on_run.sh \
    && LD_PRELOAD=libVT.so iperf3 -s


###############
## netperf
###############
FROM ubuntu AS netperf
COPY --from=base /usr/local/bin/pipework /usr/local/bin/pipework
COPY --from=base /usr/lib/adu-send.so /usr/lib/adu-send.so
COPY --from=base /usr/lib/libVT.so /usr/lib/libVT.so
COPY on_run.sh /root/
RUN chmod +x /root/on_run.sh
RUN echo deb http://us.archive.ubuntu.com/ubuntu/ xenial multiverse | tee -a /etc/apt/sources.list \
    && echo deb http://us.archive.ubuntu.com/ubuntu/ xenial-updates multiverse | tee -a /etc/apt/sources.list
RUN apt-get update && apt-get install -y \
                              netperf \
    && rm -rf /var/lib/apt/lists/*

CMD pipework --wait \
    && pipework --wait -i eth2 \
    && /root/on_run.sh \
    && pgrep netserver | xargs sudo kill \
    && sudo LD_PRELOAD=libVT.so netserver


###############
## hadoop
###############
FROM ubuntu AS hadoop
COPY --from=base /usr/local/bin/pipework /usr/local/bin/pipework
COPY --from=base /usr/lib/adu-send.so /usr/lib/adu-send.so
COPY --from=base /usr/lib/libVT.so /usr/lib/libVT.so
COPY on_run.sh /root/
RUN chmod +x /root/on_run.sh
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

CMD pipework --wait \
    && pipework --wait -i eth2 \
    && /root/on_run.sh
