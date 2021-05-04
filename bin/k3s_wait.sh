#!/bin/bash

function sintax
{
    echo "Sintax: $0 <start|end>"
}

function start_summary
{
    sleep 1

    PODS=`sudo kubectl get pods`

    CC=`echo "$PODS" | grep ContainerCreating | wc -l`
    PE=`echo "$PODS" | grep Pending | wc -l`
    EIP=`echo "$PODS" | grep ErrImagePull | wc -l`
    IPBF=`echo "$PODS" | grep ImagePullBackOff | wc -l`
    CLBO=`echo "$PODS" | grep CrashLoopBackOff | wc -l`
    ERR=`echo "$PODS" | grep Error | wc -l`
    RUN=`echo "$PODS" | grep Running | wc -l`

    echo "Summary: ContainerCreating=$CC, Pending=$PE, ErrImagePull=$EIP, ImagePullBackOff=$IPBF, CrashLoopBackOff=$CLBO, Error=$ERR, Running=$RUN"
}

function end_summary
{
    sleep 1
    TE=`sudo kubectl get pods | grep Terminating | wc -l`
    echo "Pods still Terminating: $TE"
}

function wait_start
{
    start_summary

    while [ $CC != '0' -o $PE != '0' ]
    do
        start_summary
    done
}

function wait_end
{
    end_summary

    while [ $TE != '0' ]
    do
        end_summary
    done
}

wait_counter()
{
  N=$1

  if [ "$N" = "" ]; then
    N=3
  fi

  while [ ! $N -le 0 ]
  do
    echo "$N..."
    sleep 1
    N=$(( N - 1 ))
  done
}

TARGET=$1

if [ -z "$TARGET" ]; then
    sintax

elif [ $TARGET == "begin" -o $TARGET == "start" ]; then
    wait_start

elif [ $TARGET == "end" -o $TARGET == "stop" ]; then
    wait_end

elif [ $TARGET == "counter" ]; then
    wait_counter $2

else
    echo "Invalid option: $TARGET"

fi
