ARG BUILD_FROM
FROM $BUILD_FROM

# Setup base
ENV LANG C.UTF-8
ARG BUILD_ARCH
RUN apk update \
    && apk add --no-cache jq wget curl

RUN set -x \
    && if [ $BUILD_ARCH == "armhf" ]; then FRP_ARCH="arm"; fi \
    && if [ $BUILD_ARCH == "amd64" ]; then FRP_ARCH="amd64"; fi \
    && if [ $BUILD_ARCH == "aarch64" ]; then FRP_ARCH="arm64"; fi \
    && if [ $BUILD_ARCH == "i386" ]; then FRP_ARCH="386"; fi \
    && if [ $BUILD_ARCH == "armv7" ]; then FRP_ARCH="arm"; fi \
    && URL_VERSION="https://raw.githubusercontent.com/chongkk/custom-addons/main/customfrpc/version.json" \
    && FRP_VERSION=$(curl -s $URL_VERSION | jq -e -r '.frp') \
    && wget https://github.com/fatedier/frp/releases/download/v${FRP_VERSION}/frp_${FRP_VERSION}_linux_${FRP_ARCH}.tar.gz \
    && tar -zxf frp_${FRP_VERSION}_linux_${FRP_ARCH}.tar.gz \
    && mv frp_${FRP_VERSION}_linux_${FRP_ARCH} /var/frp \
    && mkdir -p /var/frp/conf

# Copy data
COPY data/*.sh /

CMD [ "/run.sh" ]
