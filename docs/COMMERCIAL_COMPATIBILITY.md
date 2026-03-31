# Commercial Version Compatibility

A reference on compatibility between the nginx internal_redirect module and the [nginx commercial subscription version](http://nginx.org/en/docs/http/ngx_http_internal_redirect_module.html).

## Overview

**Commercial compatible**: The basic functionality of the `internal_redirect` directive is compatible with the commercial version.

**License**: MIT License

## Directive Compatibility Table

| Commercial | OSS (this module) | Compatibility |
|------------|-------------------|---------------|
| `internal_redirect uri` | `internal_redirect uri` | Fully compatible |
| &emsp; Regular location | &emsp; Regular location | Fully compatible |
| &emsp; Named location | &emsp; Named location | Fully compatible |
| &emsp; Variable support | &emsp; Variable support | Fully compatible |

## Behavioral Differences

### Processing Phase

Operates in the precontent phase, same as the commercial version.

### Complex Value Evaluation

Uses `ngx_http_complex_value` to evaluate the URI, same as the commercial version. URIs containing variables are dynamically expanded at request processing time.

### Redirect Method

Determines the redirect method based on the leading character of the URI, same as the commercial version.

| URI Pattern | Redirect Method | nginx Internal Function |
|-------------|----------------|------------------------|
| `@name` | Named location | `ngx_http_named_location()` |
| Other | Regular redirect | `ngx_http_internal_redirect()` |

## Context Differences

| Context | Commercial | OSS |
|---------|-----------|-----|
| `server` | Supported | Supported |
| `location` | Supported | Supported |
| `if` | Unverified | Unverified |

## Related Documentation

- [README.md](../README.md): Module Overview
- [DIRECTIVES.md](DIRECTIVES.md): Directive Reference
- [EXAMPLES.md](EXAMPLES.md): Configuration Examples
- [INSTALL.md](INSTALL.md): Installation Guide
- [SECURITY.md](SECURITY.md): Security Guidelines
- [TROUBLESHOOTING.md](TROUBLESHOOTING.md): Troubleshooting Guide
