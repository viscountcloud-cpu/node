#!/bin/bash
cd /home/container || exit 1


MODIFIED_STARTUP=$(echo -e ${CMD_RUN} | sed -e 's/{{/${/g' -e 's/}}/}/g')


    
if [[ -z "${PM2_LIMIT_START}" ]]; then
    PM2_LIMIT=3
else
    if [[ "${PM2_LIMIT_START}" == "0" ]]; then
        PM2_LIMIT=0
    elif [[ "${PM2_LIMIT_START}" == "1" ]]; then
        PM2_LIMIT=1
    elif [[ "${PM2_LIMIT_START}" == "2" ]]; then
        PM2_LIMIT=2
    elif [[ "${PM2_LIMIT_START}" == "3" ]]; then
        PM2_LIMIT=3
    elif [[ "${PM2_LIMIT_START}" == "4" ]]; then
        PM2_LIMIT=4
    elif [[ "${PM2_LIMIT_START}" == "5" ]]; then
        PM2_LIMIT=5
    else
        PM2_LIMIT=3
    fi
fi

export PM2_LIMIT


eval ${MODIFIED_STARTUP}
