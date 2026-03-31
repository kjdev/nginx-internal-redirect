# Directive Reference

## Directives

| Directive | Description | Context |
|---|---|---|
| [internal_redirect](#internal_redirect) | Set the URI for internal redirection | server, location |

### internal_redirect

```
Syntax:  internal_redirect uri;
Default: --
Context: server, location
```

Sets the URI for internal redirection of the request. Evaluated in the precontent phase, it runs after request/connection limit checks and access control checks.

#### URI Specification

The `uri` parameter accepts the following forms:

| Form | Example | Description |
|------|---------|-------------|
| Regular location | `/path` | Internal redirect to the specified path |
| Named location | `@name` | Internal redirect to a named location |
| Variable | `$variable` | Dynamic redirect based on the variable value |

#### Redirect to Regular Location

When `uri` does not start with `@`, it is processed as a regular internal redirect. Query strings are automatically separated if present.

```nginx
location / {
    internal_redirect /internal/path;
}

location = /internal/path {
    internal;
    proxy_pass http://backend;
}
```

#### Redirect to Named Location

When `uri` starts with `@`, it is processed as a redirect to a named location.

```nginx
location / {
    internal_redirect @backend;
}

location @backend {
    proxy_pass http://backend;
}
```

#### Using Variables

The `uri` parameter can contain nginx variables. Variables are dynamically evaluated at request processing time as a [complex value](http://nginx.org/en/docs/dev/development_guide.html#http_complex_values).

```nginx
location / {
    set $redirect_uri @backend;
    internal_redirect $redirect_uri;
}
```

#### Empty String Behavior

When the `uri` evaluates to an empty string, no redirect is performed and normal request processing continues. This can be used to implement conditional redirects.

```nginx
location / {
    # No redirect when $redirect_uri is empty
    internal_redirect $redirect_uri;
}
```

#### Processing Phase

`internal_redirect` operates in the [precontent phase](http://nginx.org/en/docs/dev/development_guide.html#http_phases). Its position in the nginx HTTP request processing phases is as follows:

| Phase | Typical Modules | Order |
|-------|----------------|-------|
| post-read | realip | |
| server-rewrite | rewrite | |
| find-config | -- | |
| rewrite | rewrite | |
| post-rewrite | -- | |
| preaccess | limit_req, limit_conn | |
| access | access, auth_basic, auth_jwt | |
| post-access | -- | |
| **precontent** | **internal_redirect**, try_files | &larr; here |
| content | proxy, fastcgi | |
| log | log | |

Since the precontent phase runs after the access phase, redirects can be made based on authentication and access control results.

## Related Documentation

- [README.md](../README.md): Module Overview
- [EXAMPLES.md](EXAMPLES.md): Configuration Examples
- [INSTALL.md](INSTALL.md): Installation Guide
- [SECURITY.md](SECURITY.md): Security Guidelines
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md): Troubleshooting Guide
- [COMMERCIAL_COMPATIBILITY.md](COMMERCIAL_COMPATIBILITY.md): Commercial Version Compatibility
