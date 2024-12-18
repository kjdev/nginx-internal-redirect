nginx-internal-redirect
=======================

The `ngx_http_internal_redirect`_module module allows making
an internal redirect. In contrast to [rewriting URIs][],
the redirection is made after checking [request][] and [connection][]
processing limits, and [access][] limits.

> This module is heavily inspired by the nginx original
> [ngx_http_internal_redirect_module][].

[rewriting URIs]: http://nginx.org/en/docs/http/ngx_http_rewrite_module.html
[request]: http://nginx.org/en/docs/http/ngx_http_limit_req_module.html
[connection]: http://nginx.org/en/docs/http/ngx_http_limit_conn_module.html
[access]: http://nginx.org/en/docs/http/ngx_http_access_module.html
[ngx_http_internal_redirect_module]: http://nginx.org/en/docs/http/ngx_http_internal_redirect_module.html

Installation
------------

### Build install

``` sh
$ : "clone repository"
$ git clone https://github.com/kjdev/nginx-internal-redirect
$ cd nginx-internal-redirect
$ : "get nginx source"
$ NGINX_VERSION=1.x.x # specify nginx version
$ wget http://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
$ tar -zxf nginx-${NGINX_VERSION}.tar.gz
$ cd nginx-${NGINX_VERSION}
$ : "build module"
$ ./configure --add-dynamic-module=..
$ make && make install
```

### Docker

``` sh
$ docker build -t nginx-internal-redirect .
$ : "app.conf: Create nginx configuration"
$ docker run -p 80:80 -v $PWD/app.conf:/etc/nginx/http.d/default.conf nginx-internal-redirect
```

> GitHub package: ghcr.io/kjdev/nginx-internal-redirect/nginx

Configuration
-------------

### Example

```
limit_req_zone $jwt_claim_sub zone=jwt_sub:10m rate=1r/s;

server {
  location / {
    auth_jwt "realm";
    auth_jwt_key_file key.jwk;

    internal_redirect @rate_limited;
  }

  location @rate_limited {
    internal;

    limit_req  zone=jwt_sub burst=10;
    proxy_pass http://backend;
  }
}
```

The example implements [per-user][] [rate limiting][].
Implementation without [internal_redirect][] is vulnerable to DoS attacks by
unsigned JWTs, as normally the [limit_req][] check is performed
[before][] [auth_jwt][] check. Using [internal_redirect][] allows reordering
these checks.

[per-user]: https://datatracker.ietf.org/doc/html/rfc7519#section-4.1.2

[rate limiting]: http://nginx.org/en/docs/http/ngx_http_limit_req_module.html
[internal_redirect]: #internal_redirect
[limit_req]: http://nginx.org/en/docs/http/ngx_http_limit_req_module.html#limit_req
[before]: http://nginx.org/en/docs/dev/development_guide.html#http_phases
[auth_jwt]: https://github.com/kjdev/nginx-auth-jwt?#auth_jwt

### Directives

- [internal_redirect][]

<a name="internal_redirect"></a>
```
Syntax: internal_redirect uri;
Default: —
Context: server, location
```

Sets the URI for internal redirection of the request. It is also possible to
use a [named location][] instead of the URI. The `uri` value can contain
variables. If the `uri` value is empty, then the redirect will not be made.

[named location]: http://nginx.org/en/docs/http/ngx_http_core_module.html#location_named
