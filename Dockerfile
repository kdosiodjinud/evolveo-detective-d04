ARG BUILD_FROM
FROM $BUILD_FROM

ENV LANG C.UTF-8

RUN apk add --no-cache mosquitto-clients jq

WORKDIR /data

COPY run.sh /

RUN chmod a+x /run.sh

CMD [ "/run.sh" ]
