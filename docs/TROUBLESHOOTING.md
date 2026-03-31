# Troubleshooting

## Redirect Not Executing

When `internal_redirect` is configured but the redirect does not occur.

**Possible causes:**

- The `internal_redirect` URI evaluates to an empty string
- The module is not loaded correctly
- The directive arguments are incorrect

**How to check:**

1. Verify that the module is loaded

   ```bash
   nginx -V 2>&1 | grep internal_redirect
   ```

   For dynamic modules, verify that the `load_module` directive exists in the configuration file.

   ```nginx
   load_module modules/ngx_http_internal_redirect_module.so;
   ```

2. When using variables, verify that the variable value is not empty

   ```nginx
   # Debug: output the variable value as a header
   add_header X-Debug-Redirect $redirect_uri;
   ```

3. Check the error.log at `info` level

   ```nginx
   error_log /var/log/nginx/error.log info;
   ```

## 500 Internal Server Error

When the redirect results in a 500 error.

**Possible causes:**

- A redirect loop is occurring
- The redirect target location does not exist

**How to check:**

Check the error.log for the following message:

```
rewrite or internal redirection cycle while internally redirecting to "..."
```

This message indicates that internal redirects are cycling (nginx terminates after a maximum of 10 redirects).

**Resolution:**

1. Verify that the redirect target location does not have `internal_redirect` configured
2. Verify that the redirect target location is correctly defined

## 404 Not Found

When the redirect target returns a 404 error.

**Possible causes:**

- When redirecting to a regular location, the matching location is not defined
- The named location name is incorrect

**Resolution:**

1. Verify that the redirect target location is correctly defined

   ```nginx
   # Regular location
   location = /internal/path {
       internal;
       ...
   }

   # Named location
   location @backend {
       ...
   }
   ```

2. Verify that the named location name (after `@`) matches the `internal_redirect` argument

## Configuration Errors

Errors that occur during nginx startup or configuration reload.

### invalid number of arguments

```
invalid number of arguments in "internal_redirect" directive
```

`internal_redirect` accepts only one argument.

```nginx
# Wrong: too many arguments
internal_redirect /path extra_arg;

# Correct
internal_redirect /path;
```

### unknown directive

```
unknown directive "internal_redirect"
```

The module is not loaded. Check the `load_module` directive.

```nginx
load_module modules/ngx_http_internal_redirect_module.so;
```

## Performance Considerations

- Internal redirects are completed entirely within the nginx process, so no network overhead is incurred
- The redirect target location executes phase processing anew, so be aware of duplicate phase processing in complex configurations
- Complex value evaluation is a lightweight operation with minimal performance impact

## Related Documentation

- [README.md](../README.md): Module Overview
- [DIRECTIVES.md](DIRECTIVES.md): Directive Reference
- [EXAMPLES.md](EXAMPLES.md): Configuration Examples
- [INSTALL.md](INSTALL.md): Installation Guide
- [SECURITY.md](SECURITY.md): Security Guidelines
- [COMMERCIAL_COMPATIBILITY.md](COMMERCIAL_COMPATIBILITY.md): Commercial Version Compatibility
