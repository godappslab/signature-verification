#!/usr/bin/env bash

DIR=$(cd $(dirname $0);pwd)

cd ${DIR}/../docs/sequence-diagram

MMDC_CMD=$DIR/../node_modules/.bin/mmdc

mmd_list=(
    "authentication-by-EIP712-signature"
)

for i in "${mmd_list[@]}"
do
    filename="${i}"
    ${MMDC_CMD} -i ${filename}.mmd -o ${filename}.svg
done

