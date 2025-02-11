# syntax=docker/dockerfile:1

ARG ALPINE_VERSION=3.21

FROM alpine:${ALPINE_VERSION} AS nginx

### builder ###
FROM nginx AS builder

WORKDIR /build
RUN <<\EOS sh -ex
apk --no-cache upgrade
apk --no-cache add \
  curl \
  gcc \
  gd-dev \
  geoip-dev \
  jansson-dev \
  libxslt-dev \
  linux-headers \
  make \
  musl-dev \
  nginx \
  openssl-dev \
  pcre-dev \
  perl-dev \
  zlib-dev
nginx_version=$(nginx -v 2>&1 | sed 's/^[^0-9]*//')
curl -sL -o nginx-${nginx_version}.tar.gz http://nginx.org/download/nginx-${nginx_version}.tar.gz
tar -xf nginx-${nginx_version}.tar.gz
mv nginx-${nginx_version} nginx
EOS

COPY config /build/
COPY src/ /build/src/

WORKDIR /build/nginx
RUN <<\EOS sh -ex
nginx_opt=$(nginx -V 2>&1 | tail -1 | sed -e "s/configure arguments://" -e "s| --add-dynamic-module=[^ ]*||g")
./configure \
  ${nginx_opt} \
  --add-dynamic-module=.. \
  --with-cc-opt='-DNGX_HTTP_HEADERS'
make
mkdir -p /usr/lib/nginx/modules
cp objs/ngx_http_internal_redirect_module.so /usr/lib/nginx/modules/
mkdir -p /etc/nginx/modules
echo 'load_module "/usr/lib/nginx/modules/ngx_http_internal_redirect_module.so";' > /etc/nginx/modules/internal_redirect.conf
nginx -t
EOS


### nginx ###
FROM nginx

RUN <<\EOS sh -ex
apk --no-cache upgrade
apk --no-cache add \
  jansson \
  nginx
sed \
  -e 's/^user /#user /' \
  -e 's@^error_log .*$@error_log /dev/stderr warn;@' \
  -e 's@access_log .*;$@access_log /dev/stdout main;@' \
  -i /etc/nginx/nginx.conf
EOS

COPY --from=builder /usr/lib/nginx/modules/ngx_http_internal_redirect_module.so /usr/lib/nginx/modules/ngx_http_internal_redirect_module.so
COPY --from=builder /etc/nginx/modules/internal_redirect.conf /etc/nginx/modules/internal_redirect.conf

USER nginx
CMD ["nginx", "-g", "daemon off;"]
