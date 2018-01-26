FROM deployable/acng:latest

ENV ACNG_LOCALE="us"

RUN set -uex; \
    if [ -n "$ACNG_LOCALE" ]; then \
      cp /etc/apt-cacher-ng/acng.conf.$ACNG_LOCALE /etc/apt-cacher-ng/acng.conf; \
    fi; \
