FROM alpine:latest
COPY os /root/os
COPY *.ini *.yaml /root/
RUN apk update \
        && apk add ansible \
        && apk add openssh