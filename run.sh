#!/usr/bin/env bash

CONFIG_PATH=/data/options.json
mqtt_host="$(jq --raw-output '.mqtt_host' $CONFIG_PATH)"
mqtt_port="$(jq --raw-output '.mqtt_port' $CONFIG_PATH)"
mqtt_username="$(jq --raw-output '.mqtt_username' $CONFIG_PATH)"
mqtt_password="$(jq --raw-output '.mqtt_password' $CONFIG_PATH)"
mqtt_root_topic="$(jq --raw-output '.mqtt_root_topic' $CONFIG_PATH)"

echo "STARTED"

while true;do
    VALID="FALSE"

    RAW_INPUT="$(echo "OK" | tr -d '\0' | nc -l -p 15002)"
    INPUT=$(tr -cd [:alnum:][:punct:] <<< "$RAW_INPUT")

    EVENT=$(echo ${INPUT} | jq --raw-output .Descrip | cut -d "," -f1)
    CAMERA=$(echo ${INPUT} | jq --raw-output .Descrip | cut -d "," -f2)
    EVENT_TEXT=$(echo ${INPUT} | jq --raw-output .Event)

    STATUS="unknown"

    if [[ ${EVENT_TEXT} = "EventStart" ]] ; then
		STATUS="ON"
		VALID="TRUE"
    fi

    if [[ ${EVENT_TEXT} = "EventStop" ]] ; then
		STATUS="OFF"
		VALID="TRUE"
    fi

    if [[ ${VALID} = "TRUE" ]] ; then
        mosquitto_pub -h ${mqtt_host} -p ${mqtt_port} -u ${mqtt_username} -P ${mqtt_password} -t "$mqtt_root_topic/$CAMERA/$EVENT" -m "$STATUS"
    else
        echo "Unprocessable input:"
        echo ${INPUT}
    fi

    # když pošlu ON, chci poslat po 10 vteřinách poslat OFF pokud nepříjde ON, které dobu prodlouží

    # Při každém ON nastavit čas poslání OFF na t+10
    # Přidat kontrolu timeoutů a posílat OFF

done
