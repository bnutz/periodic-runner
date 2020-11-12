#!/bin/bash
if [ -z $REMOTE_ADDRESS ]; then 
    HOST_ADDRESS=`route -n | awk '$4 == "UG" {print $2}'`
else
    HOST_ADDRESS=$REMOTE_ADDRESS    
fi

if [ -z $HOST_ADDRESS ]; then 
    echo "Host gateway address not found."; 
elif [ -z ${HOST_USERNAME} ]; then 
    echo "Missing username: HOST_USERNAME"; 
else 
    ssh-copy-id $HOST_USERNAME@$HOST_ADDRESS
fi