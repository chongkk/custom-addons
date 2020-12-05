#!/usr/bin/with-contenv bashio
# ==============================================================================
# Start sshd service if enabled
# ==============================================================================
CERT_DIR=/data/letsencrypt
WORK_DIR=/data/workdir
PROVIDER_ARGUMENTS=()
ACME_CUSTOM_SERVER_ARGUMENTS=()

EMAIL=$(bashio::config 'email')
DOMAINS=$(bashio::config 'domains')
KEYFILE=$(bashio::config 'keyfile')
CERTFILE=$(bashio::config 'certfile')
CHALLENGE=$(bashio::config 'challenge')
DNS_PROVIDER=$(bashio::config 'dns.provider')
ACME_SERVER=$(bashio::config 'acme_server')
ACME_ROOT_CA=$(bashio::config 'acme_root_ca_cert')
WAIT_TIME=$(bashio::config 'seconds')

LE_UPDATE="0"

function le_renew() {

cp "/ssl/$KEYFILE" "$CERT_DIR/live/$DOMAINS/privkey.pem"
cp "/ssl/$CERTFILE" "$CERT_DIR/live/$DOMAINS/fullchain.pem"

if [ "${CHALLENGE}" == "dns" ]; then
    bashio::log.info "Selected DNS Provider: ${DNS_PROVIDER}"

    PROPAGATION_SECONDS=60
    if bashio::config.exists 'dns.propagation_seconds'; then
        PROPAGATION_SECONDS="$(bashio::config 'dns.propagation_seconds')" 
    fi
    bashio::log.info "Use propagation seconds: ${PROPAGATION_SECONDS}"
else
    bashio::log.info "Selected http verification"
fi

# CloudFlare
if [ "${DNS_PROVIDER}" == "dns-cloudflare" ]; then
    if bashio::config.exists 'dns.cloudflare_api_token'; then
        bashio::log.info "Use CloudFlare token"
        echo "dns_cloudflare_api_token = $(bashio::config 'dns.cloudflare_api_token')" >> /data/dnsapikey
    else
        bashio::log.warning "Use CloudFlare global key (not recommended!)"
        echo -e "dns_cloudflare_email = $(bashio::config 'dns.cloudflare_email')\n" \
            "dns_cloudflare_api_key = $(bashio::config 'dns.cloudflare_api_key')\n" >> /data/dnsapikey
    fi

    PROVIDER_ARGUMENTS+=("--${DNS_PROVIDER}" "--${DNS_PROVIDER}-credentials" /data/dnsapikey "--dns-cloudflare-propagation-seconds" "${PROPAGATION_SECONDS}")
fi

if bashio::config.has_value 'acme_server' ; then
    ACME_CUSTOM_SERVER_ARGUMENTS+=("--server" "${ACME_SERVER}")

    if bashio::config.has_value 'acme_root_ca_cert'; then
      echo "${ACME_ROOT_CA}" > /tmp/root-ca-cert.crt
      # Certbot will automatically open the filepath contained in REQUESTS_CA_BUNDLE for extra CA cert
      export REQUESTS_CA_BUNDLE=/tmp/root-ca-cert.crt
    fi
fi

# Gather all domains into a plaintext file
DOMAIN_ARR=()
for line in $DOMAINS; do
    DOMAIN_ARR+=(-d "$line")
done
echo "$DOMAINS" > /data/domains.gen

# Generate a new certificate if necessary or expand a previous certificate if domains has changed
if [ "$CHALLENGE" == "dns" ]; then
    certbot renew
fi

# Get the last modified cert directory and copy the cert and private key to store
# shellcheck disable=SC2012
CERT_DIR_LATEST="$(ls -td $CERT_DIR/live/*/ | head -1)"
cp "${CERT_DIR_LATEST}privkey.pem" "/ssl/$KEYFILE"
cp "${CERT_DIR_LATEST}fullchain.pem" "/ssl/$CERTFILE"

LE_UPDATE="$(date +%s)"
}

function le_new() {
if [ "${CHALLENGE}" == "dns" ]; then
    bashio::log.info "Selected DNS Provider: ${DNS_PROVIDER}"

    PROPAGATION_SECONDS=60
    if bashio::config.exists 'dns.propagation_seconds'; then
        PROPAGATION_SECONDS="$(bashio::config 'dns.propagation_seconds')" 
    fi
    bashio::log.info "Use propagation seconds: ${PROPAGATION_SECONDS}"
else
    bashio::log.info "Selected http verification"
fi

# CloudFlare
if [ "${DNS_PROVIDER}" == "dns-cloudflare" ]; then
    if bashio::config.exists 'dns.cloudflare_api_token'; then
        bashio::log.info "Use CloudFlare token"
        echo "dns_cloudflare_api_token = $(bashio::config 'dns.cloudflare_api_token')" >> /data/dnsapikey
    else
        bashio::log.warning "Use CloudFlare global key (not recommended!)"
        echo -e "dns_cloudflare_email = $(bashio::config 'dns.cloudflare_email')\n" \
            "dns_cloudflare_api_key = $(bashio::config 'dns.cloudflare_api_key')\n" >> /data/dnsapikey
    fi

    PROVIDER_ARGUMENTS+=("--${DNS_PROVIDER}" "--${DNS_PROVIDER}-credentials" /data/dnsapikey "--dns-cloudflare-propagation-seconds" "${PROPAGATION_SECONDS}")
fi

if bashio::config.has_value 'acme_server' ; then
    ACME_CUSTOM_SERVER_ARGUMENTS+=("--server" "${ACME_SERVER}")

    if bashio::config.has_value 'acme_root_ca_cert'; then
      echo "${ACME_ROOT_CA}" > /tmp/root-ca-cert.crt
      # Certbot will automatically open the filepath contained in REQUESTS_CA_BUNDLE for extra CA cert
      export REQUESTS_CA_BUNDLE=/tmp/root-ca-cert.crt
    fi
fi

# Gather all domains into a plaintext file
DOMAIN_ARR=()
for line in $DOMAINS; do
    DOMAIN_ARR+=(-d "$line")
done
echo "$DOMAINS" > /data/domains.gen

# Generate a new certificate if necessary or expand a previous certificate if domains has changed
if [ "$CHALLENGE" == "dns" ]; then
    certbot certonly --non-interactive --keep-until-expiring --expand \
        --email "$EMAIL" --agree-tos \
        --config-dir "$CERT_DIR" --work-dir "$WORK_DIR" \
        --preferred-challenges "$CHALLENGE" "${DOMAIN_ARR[@]}" "${PROVIDER_ARGUMENTS[@]}"
fi

# Get the last modified cert directory and copy the cert and private key to store
# shellcheck disable=SC2012
CERT_DIR_LATEST="$(ls -td $CERT_DIR/live/*/ | head -1)"
cp "${CERT_DIR_LATEST}privkey.pem" "/ssl/$KEYFILE"
cp "${CERT_DIR_LATEST}fullchain.pem" "/ssl/$CERTFILE"

LE_UPDATE="$(date +%s)"
}

while true; do
    if [ ! -f "/ssl/$KEYFILE" ]; then
      le_new
      bashio::log.info "Register new certificate"
    else
        now="$(date +%s)"
        if [ $((now - LE_UPDATE)) -ge ${WAIT_TIME} ]; then
            le_renew
        fi
        bashio::log.info "Cron Check every ${WAIT_TIME} seconds"
        sleep "${WAIT_TIME}"
    fi
done
