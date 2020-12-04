#!/usr/bin/with-contenv bashio
# ==============================================================================
# Init folder & structures
# ==============================================================================
mkdir -p /data/workdir
mkdir -p /data/letsencrypt

# Setup Let's encrypt config
echo -e "dns_cloudxns_api_key = $(bashio::config 'dns.cloudxns_api_key')\n" \
      "dns_cloudxns_secret_key = $(bashio::config 'dns.cloudxns_secret_key')\n" \
 > /data/dnsapikey

chmod 600 /data/dnsapikey
