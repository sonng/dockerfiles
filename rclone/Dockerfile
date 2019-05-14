FROM alpine:3.9

LABEL maintainer="Son Nguyen <anh.s.nguyen@gmail.com>"

ADD crontab /etc/cron.d/rclone-cron

COPY run.sh /
COPY rclone-mount-check.sh /

ENV RCLONE_VERSION=current
ENV ARCH=amd64
ENV RCLONE_OPTS="--config /config/rclone.conf"

# Install rclone
RUN apk -U add ca-certificates fuse wget \
    && rm -rf /var/cache/apk/* \
    && cd /tmp \
    && wget -q http://downloads.rclone.org/rclone-${RCLONE_VERSION}-linux-${ARCH}.zip \
    && unzip /tmp/rclone-${RCLONE_VERSION}-linux-${ARCH}.zip \
    && mv /tmp/rclone-*-linux-${ARCH}/rclone /usr/bin \
    && rm -r /tmp/rclone* \
    && mkdir /drive

# Install Samba
RUN apk add --update \
    samba-common-tools \
    samba-client \
    samba-server \
    && rm -rf /var/cache/apk/*

COPY config/smb.conf /etc/samba/smb.conf

EXPOSE 445/tcp

VOLUME ["/config", "/logs", "/cache"]

ENTRYPOINT [ "sh", "/run.sh" ]

CMD [ "" ]