ARG BUILD_FROM
FROM $BUILD_FROM

# setup base
ARG CERTBOT_VERSION
ARG CERTBOT_DNS_DIRECTADMIN_VERSION
ARG CERTBOT_NETCUP_VERSION
ARG CERTBOT_NJALLA_VERSION
ARG CERTBOT_GANDI_VERSION
ARG CERTBOT_DNS_TRANSIP_VERSION

RUN apk add --no-cache --update \
        libffi \
        musl \
        openssl \
    && apk add --no-cache --virtual .build-dependencies \
        g++ \
        libffi-dev \
        musl-dev \
        openssl-dev \
    && pip3 install --no-cache-dir --find-links \
        "https://wheels.home-assistant.io/alpine-$(cut -d '.' -f 1-2 < /etc/alpine-release)/${BUILD_ARCH}/" \
        certbot==${CERTBOT_VERSION} \
        certbot-dns-cloudflare==${CERTBOT_VERSION} \
    && apk del .build-dependencies

# Copy data
COPY data/*.sh /

CMD [ "/run.sh" ]