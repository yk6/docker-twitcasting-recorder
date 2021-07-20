FROM python:alpine

RUN apk --update add --no-cache bash docker curl ffmpeg dumb-init

WORKDIR /
COPY record_twitcast.sh .

COPY twitcasting-recorder/requirements.txt .
COPY twitcasting-recorder/main.py .
RUN pip3 install -r requirements.txt

ENTRYPOINT [ "/usr/bin/dumb-init", "--", "/bin/bash", "record_twitcast.sh" ]