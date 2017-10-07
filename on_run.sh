#!bin/bash

NUM_HOSTS=8
DATA_NET=1

SWITCH=10.10.1.9
printf "$SWITCH\tswitch\n" >> /etc/hosts

ping router -c1

for i in `seq 1 $NUM_HOSTS`
do
    for j in `seq 1 $NUM_HOSTS`
    do
	    printf "10.10.$DATA_NET.$i$j\th$i$j\n" >> /etc/hosts
        arp -s h$i$j `arp | grep switch | tr -s ' ' | cut -d' ' -f3`
    done
done
