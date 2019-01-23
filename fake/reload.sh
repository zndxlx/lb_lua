#!/bin/sh
PROJ_DIR=`pwd`
NGINX_BIN_PATH=/usr/local/openresty/nginx/sbin/nginx
NGINX_CONF_PATH=$PROJ_DIR/conf/nginx.conf
$NGINX_BIN_PATH -s reload -p $PROJ_DIR

