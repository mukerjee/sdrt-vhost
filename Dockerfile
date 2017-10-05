FROM ubuntu

MAINTAINER Matt Mukerjee "mukerjee@cs.cmu.edu"

RUN apt-get update && apt-get install -y \
                              software-properties-common
RUN add-apt-repository ppa:openjdk-r/ppa 
RUN apt-get update && apt-get install -y \
                              net-tools \
                              iputils-ping \
			      autoconf \
			      gcc \
			      cmake \
                              openjdk-7-jdk \
                              maven \			    
                              iperf \
                              iperf3 \
			      flowgrind \
    && rm -rf /var/lib/apt/lists/*

ADD https://github.com/intel-hadoop/HiBench/archive/master.tar.gz /tmp/HiBench.tar.gz
WORKDIR /root
RUN tar xfz /tmp/HiBench.tar.gz && mv HiBench-master HiBench

ADD https://github.com/mukerjee/sdrt/archive/master.tar.gz /tmp/sdrt.tar.gz
WORKDIR /root
RUN tar xfz /tmp/sdrt.tar.gz && mv sdrt-master sdrt
WORKDIR /root/sdrt/adu-send/lib
RUN make -j install

RUN rm /tmp/*.tar.gz

WORKDIR /root/
ENTRYPOINT ["flowgrindd"]
CMD ["-d"]