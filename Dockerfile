FROM alpine:latest
COPY os /root/os
COPY *.ini *.yaml /root/
RUN  apk add --no-cache ansible  \
     && apk add --no-cache openssh
