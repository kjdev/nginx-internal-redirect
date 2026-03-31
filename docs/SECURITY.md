# Security Guidelines

## Using the internal Directive

It is recommended to set the `internal` directive on redirect target locations to prevent direct external access.

```nginx
location @backend {
    # Named locations are not externally accessible, so internal is not needed
    proxy_pass http://backend;
}

location = /internal/path {
    internal;  # Reject direct external access
    proxy_pass http://backend;
}
```

**Recommendations:**

- When using named locations (`@name`), the `internal` directive is unnecessary (named locations are not accessible from external requests)
- When redirecting to regular locations, specify the `internal` directive

## Preventing Redirect Loops

When internal redirects form a cycle, nginx terminates the request with a 500 error after a maximum of 10 redirects (nginx default behavior).

**Patterns to avoid:**

```nginx
# Infinite loop: location A -> location B -> location A
location /a {
    internal_redirect /b;
}

location /b {
    internal_redirect /a;
}
```

**Recommendations:**

- Do not set `internal_redirect` in the redirect target location
- Use named locations as redirect targets

## Controlling Redirect Targets via Variables

Avoid using user input (query parameters, headers, etc.) directly as redirect targets.

**Patterns to avoid:**

```nginx
# Using user input directly as redirect target
location / {
    internal_redirect $arg_redirect;
}
```

**Recommended pattern:**

```nginx
# Use map to allow only permitted redirect targets
map $arg_type $redirect_target {
    api     @api_backend;
    web     @web_backend;
    default "";
}

location / {
    internal_redirect $redirect_target;
}
```

## Leveraging Phase Ordering

By utilizing the fact that `internal_redirect` operates in the precontent phase, redirects can be performed after authentication and access control, enhancing security.

### DoS Mitigation

In a typical configuration, `limit_req` is processed in an earlier phase than `auth_jwt`, so unsigned JWTs still consume rate limit counts. By using `internal_redirect`, rate limiting can be applied after JWT authentication, mitigating the impact of DoS attacks.

```nginx
limit_req_zone $jwt_claim_sub zone=jwt_sub:10m rate=1r/s;

server {
    location / {
        # JWT authentication first (access phase)
        auth_jwt "realm";
        auth_jwt_key_file key.jwk;

        # Redirect after authentication (precontent phase)
        internal_redirect @rate_limited;
    }

    location @rate_limited {
        # Rate limiting at the redirect target
        limit_req zone=jwt_sub burst=10;
        proxy_pass http://backend;
    }
}
```

## Related Documentation

- [README.md](../README.md): Module Overview
- [DIRECTIVES.md](DIRECTIVES.md): Directive Reference
- [EXAMPLES.md](EXAMPLES.md): Configuration Examples
- [INSTALL.md](INSTALL.md): Installation Guide
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md): Troubleshooting Guide
- [COMMERCIAL_COMPATIBILITY.md](COMMERCIAL_COMPATIBILITY.md): Commercial Version Compatibility
