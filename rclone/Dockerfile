FROM alpine:3.9

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
    && rm -r /tmp/rclone*

VOLUME ["/config"]