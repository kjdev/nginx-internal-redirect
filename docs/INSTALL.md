# Installation Guide

This document describes how to install the nginx-internal-redirect module.

## Requirements

No additional dependencies are required. Only the nginx source code is needed.

## Build

```bash
# Clone the repository
git clone https://github.com/kjdev/nginx-internal-redirect.git
cd nginx-internal-redirect

# Get the nginx source
NGINX_VERSION=x.y.z
wget https://nginx.org/download/nginx-${NGINX_VERSION}.tar.gz
tar xzf nginx-${NGINX_VERSION}.tar.gz

# Configure and make
cd nginx-${NGINX_VERSION}
./configure --add-dynamic-module=..
make
```

After a successful build, the following module file is generated in the `objs/` directory:

- `ngx_http_internal_redirect_module.so` — for HTTP context

## Installation

### Placing the Module File

Copy the generated `.so` file to the nginx modules directory.

```bash
cp objs/ngx_http_internal_redirect_module.so /usr/lib/nginx/modules/
```

### Loading the Module

Load the module at the top of the nginx configuration file (before the `events` block).

```nginx
load_module modules/ngx_http_internal_redirect_module.so;
```

### Verification

A minimal configuration to verify that the module loads correctly:

```nginx
load_module modules/ngx_http_internal_redirect_module.so;

events {
    worker_connections 1024;
}

http {
    server {
        listen 8080;

        location / {
            internal_redirect @test;
        }

        location @test {
            return 200 "OK\n";
        }
    }
}
```

Validate the configuration file:

```bash
nginx -t -c /path/to/nginx.conf
```

## Docker Image

Pre-built Docker images are available from GitHub Container Registry.

```bash
docker pull ghcr.io/kjdev/nginx-internal-redirect/nginx:latest
```

Usage example:

```bash
docker run -d -p 8080:80 \
  -v $(pwd)/app.conf:/etc/nginx/http.d/default.conf \
  ghcr.io/kjdev/nginx-internal-redirect/nginx:latest
```

### Local Build

```bash
docker build -t nginx-internal-redirect .
docker run -p 80:80 \
  -v $PWD/app.conf:/etc/nginx/http.d/default.conf \
  nginx-internal-redirect
```

Write your nginx configuration in `app.conf`.

```nginx
# app.conf example
server {
    listen 80;

    location / {
        internal_redirect @backend;
    }

    location @backend {
        return 200 "OK\n";
    }
}
```

## Related Documentation

- [README.md](../README.md): Module Overview
- [DIRECTIVES.md](DIRECTIVES.md): Directive Reference
- [EXAMPLES.md](EXAMPLES.md): Configuration Examples
- [SECURITY.md](SECURITY.md): Security Guidelines
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md): Troubleshooting Guide
- [COMMERCIAL_COMPATIBILITY.md](COMMERCIAL_COMPATIBILITY.md): Commercial Version Compatibility
