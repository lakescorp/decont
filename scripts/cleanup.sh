#!/bin/bash

DATA=0
RESOURCES=0
OUTPUT=0
LOGS=0

if [ $# -eq 0 ]; then
    DATA=1
    RESOURCES=1
    OUTPUT=1
    LOGS=1
else
    for arg in "$@"; do
        if [[ "$arg" == "data" ]]; then
            DATA=1
        elif [[ "$arg" == "res" ]]; then
            RESOURCES=1
        elif [[ "$arg" == "out" ]]; then
            OUTPUT=1
        elif [[ "$arg" == "log" ]]; then
            LOGS=1
        fi
    done
fi


if [ "$DATA" -eq 1 ]; then
    echo "Removing data files..."
    rm -rf data/*.fastq.gz
fi

if [ "$RESOURCES" -eq 1 ]; then
    echo "Removing resource files..."
    rm -rf res/*
fi

if [ "$OUTPUT" -eq 1 ]; then
    echo "Removing output files..."
    rm -rf out/*
fi

if [ "$LOGS" -eq 1 ]; then
    echo "Removing log files..."
    rm -rf log/*
fi