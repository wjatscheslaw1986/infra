#!/bin/bash

if [[ $# -ne 1 ]]; then
    echo "Error: Please provide path to apache maven archive, as the first parameter."
    exit 1
fi

curl -s https://downloads.apache.org/maven/KEYS | gpg --import \
    && \
    curl -s https://downloads.apache.org/maven/maven-3/3.9.9/binaries/apache-maven-3.9.9-bin.tar.gz.asc | gpg --verify - $1