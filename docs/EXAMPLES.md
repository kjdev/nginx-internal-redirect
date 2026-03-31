# Configuration Examples

## Basic Internal Redirect

The simplest configuration for an internal redirect to a regular location.

```nginx
server {
    listen 80;

    location / {
        internal_redirect /test;
    }

    location = /test {
        internal;
        proxy_pass http://backend;
    }
}
```

Requests to `/` are internally redirected to `/test` and proxied to the backend. It is recommended to add the `internal` directive to the redirect target location to prevent direct external access.

## Redirect to Named Location

A configuration using a named location for internal redirect.

```nginx
server {
    listen 80;

    location / {
        internal_redirect @backend;
    }

    location @backend {
        proxy_pass http://backend;
    }
}
```

Named locations (locations starting with `@`) are not accessible from external requests, so the `internal` directive is not required.

## Variable-based Redirect

A configuration that dynamically determines the redirect target using nginx variables.

```nginx
server {
    listen 80;

    location / {
        set $redirect_uri @backend;
        internal_redirect $redirect_uri;
    }

    location @backend {
        proxy_pass http://backend;
    }
}
```

Variable values are evaluated at request processing time. Combined with the `map` directive, you can switch redirect targets based on conditions.

```nginx
map $request_method $redirect_target {
    GET     @read_backend;
    default @write_backend;
}

server {
    listen 80;

    location / {
        internal_redirect $redirect_target;
    }

    location @read_backend {
        proxy_pass http://read-servers;
    }

    location @write_backend {
        proxy_pass http://write-servers;
    }
}
```

## Conditional Redirect (Empty String)

When `internal_redirect` evaluates to an empty string, no redirect is performed and normal request processing continues.

```nginx
map $cookie_session $redirect_uri {
    ""      "";          # No session: no redirect
    default @authorized; # Session exists: redirect
}

server {
    listen 80;

    location / {
        internal_redirect $redirect_uri;

        # Executed when $redirect_uri is empty
        return 401 "Unauthorized\n";
    }

    location @authorized {
        proxy_pass http://backend;
    }
}
```

## Rate Limiting Integration (limit_req)

A configuration that uses `internal_redirect` to control the order of rate limit checks.

```nginx
limit_req_zone $binary_remote_addr zone=one:1m rate=2r/s;

server {
    listen 80;

    location / {
        internal_redirect @rate_limited;
    }

    location @rate_limited {
        internal;
        limit_req zone=one burst=1 nodelay;
        proxy_pass http://backend;
    }
}
```

## Per-user Rate Limiting

A configuration that combines authentication with per-user rate limiting.

```nginx
limit_req_zone $x_user zone=per_user:1m rate=1r/m;

server {
    listen 80;

    location / {
        auth_request /auth;
        auth_request_set $x_user $upstream_http_x_user;

        internal_redirect @rate_limited;
    }

    location = /auth {
        internal;
        proxy_pass http://auth-server;
        proxy_pass_request_body off;
        proxy_set_header X-User $http_x_user;
    }

    location @rate_limited {
        internal;
        limit_req zone=per_user burst=1 nodelay;
        proxy_pass http://backend;
    }
}
```

This configuration performs authentication via `auth_request`, then uses `internal_redirect` to redirect to a named location where rate limiting is applied based on the authenticated user ID.

## JWT Authentication Integration

A configuration that combines with the [nginx-auth-jwt](https://github.com/kjdev/nginx-auth-jwt) module to implement rate limiting based on the JWT `sub` claim.

```nginx
limit_req_zone $jwt_claim_sub zone=jwt_sub:10m rate=1r/s;

server {
    listen 80;

    location / {
        auth_jwt "realm";
        auth_jwt_key_file key.jwk;

        internal_redirect @rate_limited;
    }

    location @rate_limited {
        internal;
        limit_req zone=jwt_sub burst=10;
        proxy_pass http://backend;
    }
}
```

Normally, `limit_req` is processed in an [earlier phase](http://nginx.org/en/docs/dev/development_guide.html#http_phases) than `auth_jwt`. By using `internal_redirect`, rate limiting can be applied after JWT authentication. This prevents DoS attacks using unsigned JWTs.

## Running with Docker

You can easily run the module using container images.

```bash
# Build locally
docker build -t nginx-internal-redirect .
docker run -p 80:80 \
    -v $PWD/app.conf:/etc/nginx/http.d/default.conf \
    nginx-internal-redirect
```

```bash
# Use the GitHub Container Registry image
docker run -p 80:80 \
    -v $PWD/app.conf:/etc/nginx/http.d/default.conf \
    ghcr.io/kjdev/nginx-internal-redirect/nginx:latest
```

## Related Documentation

- [README.md](../README.md): Module Overview
- [DIRECTIVES.md](DIRECTIVES.md): Directive Reference
- [INSTALL.md](INSTALL.md): Installation Guide
- [SECURITY.md](SECURITY.md): Security Guidelines
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md): Troubleshooting Guide
- [COMMERCIAL_COMPATIBILITY.md](COMMERCIAL_COMPATIBILITY.md): Commercial Version Compatibility
