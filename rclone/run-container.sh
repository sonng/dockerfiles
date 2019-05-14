docker run --cap-add SYS_ADMIN --device /dev/fuse \
  -v $(pwd)/config:/config \
  -v $(pwd)/logs:/logs \
  -v $(pwd)/cache:/cache \
  -p 445:445 \
  sonngu/rclone