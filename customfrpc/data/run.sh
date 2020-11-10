#!/bin/bash
set -e

CONFIG_PATH=/data/options.json

SERVER_IP=$(jq --raw-output '.server_ip' $CONFIG_PATH)
TOKEN=$(jq --raw-output '.token // empty' $CONFIG_PATH)
SERVER_PORT=$(jq --raw-output '.server_port' $CONFIG_PATH)
LOCAL_PORT=$(jq --raw-output '.local_port' $CONFIG_PATH)
REMOTE_PORT=$(jq --raw-output '.remote_port' $CONFIG_PATH)
PROXY_NAME=$(jq --raw-output '.proxy_name // empty' $CONFIG_PATH)
CUSTOM_DOMAIN=$(jq --raw-output '.custom_domain // empty' $CONFIG_PATH)
TYPE=$(jq --raw-output '.type // empty' $CONFIG_PATH)
LOCAL_IP=$(jq --raw-output '.local_ip // empty' $CONFIG_PATH)

FRP_PATH=/var/frp
FRPC_CONF=$FRP_PATH/conf/frpc.ini

if [ -f $FRPC_CONF ]; then
  rm $FRPC_CONF
fi

echo "[common]" >> $FRPC_CONF
echo "server_addr = $SERVER_IP" >> $FRPC_CONF
echo "server_port = $SERVER_PORT" >> $FRPC_CONF
if [ $TOKEN ]; then
  echo "token = $TOKEN" >> $FRPC_CONF
fi
echo "[proxy_name = $CUSTOM_DOMAIN]" >> $FRPC_CONF
echo "subdomain = $CUSTOM_DOMAIN" >> $FRPC_CONF
echo "type = $TYPE" >> $FRPC_CONF
echo "local_ip = $LOCAL_IP" >> $FRPC_CONF
echo "local_port = $LOCAL_PORT" >> $FRPC_CONF
echo "remote_port = $REMOTE_PORT" >> $FRPC_CONF

echo Start frp as client

exec $FRP_PATH/frpc -c $FRPC_CONF < /dev/null
