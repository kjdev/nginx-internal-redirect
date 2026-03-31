# nginx internal_redirect Module

## Overview

nginx-internal-redirect is an internal redirect dynamic module for nginx. Unlike [rewriting URIs](http://nginx.org/en/docs/http/ngx_http_rewrite_module.html), the redirection is made after checking [request](http://nginx.org/en/docs/http/ngx_http_limit_req_module.html) and [connection](http://nginx.org/en/docs/http/ngx_http_limit_conn_module.html) processing limits, and [access](http://nginx.org/en/docs/http/ngx_http_access_module.html) limits.

> This module is heavily inspired by the nginx official [ngx_http_internal_redirect_module](http://nginx.org/en/docs/http/ngx_http_internal_redirect_module.html).

**License**: MIT License

### Key Features

- **Internal Redirect**: Performs internal redirect to a regular or named location in the precontent phase
- **Variable Support**: Supports nginx variables in the redirect URI
- **Phase Ordering**: Redirects after limit_req / limit_conn / access checks, enabling flexible control such as post-authentication rate limiting
- **Dynamic Module**: Can be built and loaded as an nginx dynamic module

## Quick Start

See [docs/INSTALL.md](docs/INSTALL.md) for installation instructions.

### Minimal Configuration

```nginx
server {
    listen 80;

    location / {
        internal_redirect @backend;
    }

    location @backend {
        internal;
        proxy_pass http://upstream;
    }
}
```

This configuration internally redirects requests to `/` to the named location `@backend`, which proxies to the upstream server.

## Directives

| Directive | Description | Context |
|---|---|---|
| `internal_redirect` | Set the URI for internal redirection | server, location |

See [docs/DIRECTIVES.md](docs/DIRECTIVES.md) for detailed directive reference.

## Related Documentation

**Configuration & Operations**:

- [docs/DIRECTIVES.md](docs/DIRECTIVES.md): Directive Reference
- [docs/EXAMPLES.md](docs/EXAMPLES.md): Configuration Examples
- [docs/INSTALL.md](docs/INSTALL.md): Installation Guide
- [docs/SECURITY.md](docs/SECURITY.md): Security Guidelines
- [docs/TROUBLESHOOTING.md](docs/TROUBLESHOOTING.md): Troubleshooting Guide

**Reference**:

- [docs/COMMERCIAL_COMPATIBILITY.md](docs/COMMERCIAL_COMPATIBILITY.md): Commercial Version Compatibility
