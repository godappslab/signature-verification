#!/usr/bin/env bash

DIR=$(cd $(dirname $0);pwd)

cd ${DIR}/../docs/flowchart

MMDC_CMD=$DIR/../node_modules/.bin/mmdc

find . -name '*.mmd' -maxdepth 1 -type f | while read file;
do
    ${MMDC_CMD} -i ${file%.mmd}.mmd -o ${file%.mmd}.svg
done

