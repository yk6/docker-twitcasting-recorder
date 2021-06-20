FROM alpine

RUN apk --update add --no-cache bash docker curl ffmpeg dumb-init

WORKDIR /
COPY record_twitcast.sh .

ENTRYPOINT [ "/usr/bin/dumb-init", "--", "/bin/bash", "record_twitcast.sh" ]