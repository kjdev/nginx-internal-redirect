
#include <ngx_config.h>
#include <ngx_core.h>
#include <ngx_http.h>

static ngx_int_t ngx_http_internal_redirect_post_conf(ngx_conf_t *cf);
static void *ngx_http_internal_redirect_create_conf(ngx_conf_t *cf);
static char *ngx_http_internal_redirect_merge_conf(ngx_conf_t *cf, void *parent, void *child);

typedef struct {
  ngx_http_complex_value_t *location;
} ngx_http_internal_redirect_conf_t;

static ngx_command_t ngx_http_internal_redirect_commands[] = {
  { ngx_string("internal_redirect"),
    NGX_HTTP_SRV_CONF | NGX_HTTP_LOC_CONF | NGX_CONF_TAKE1,
    ngx_http_set_complex_value_slot,
    NGX_HTTP_LOC_CONF_OFFSET,
    offsetof(ngx_http_internal_redirect_conf_t, location),
    NULL },
  ngx_null_command
};

static ngx_http_module_t ngx_http_internal_redirect_module_ctx = {
  NULL,                                   /* preconfiguration */
  ngx_http_internal_redirect_post_conf,   /* postconfiguration */
  NULL,                                   /* create main configuration */
  NULL,                                   /* init main configuration */
  NULL,                                   /* create server configuration */
  NULL,                                   /* merge server configuration */
  ngx_http_internal_redirect_create_conf, /* create location configuration */
  ngx_http_internal_redirect_merge_conf   /* merge location configuration */
};

ngx_module_t ngx_http_internal_redirect_module = {
  NGX_MODULE_V1,
  &ngx_http_internal_redirect_module_ctx, /* module context */
  ngx_http_internal_redirect_commands,    /* module directives */
  NGX_HTTP_MODULE,                        /* module type */
  NULL,                                   /* init master */
  NULL,                                   /* init module */
  NULL,                                   /* init process */
  NULL,                                   /* init thread */
  NULL,                                   /* exit thread */
  NULL,                                   /* exit process */
  NULL,                                   /* exit master */
  NGX_MODULE_V1_PADDING
};

static void *
ngx_http_internal_redirect_create_conf(ngx_conf_t *cf)
{
  ngx_http_internal_redirect_conf_t *conf;

  conf = ngx_pcalloc(cf->pool, sizeof(ngx_http_internal_redirect_conf_t));
  if (conf == NULL) {
    return NGX_CONF_ERROR;
  }

  conf->location = NGX_CONF_UNSET_PTR;

  return conf;
}

static char *
ngx_http_internal_redirect_merge_conf(ngx_conf_t *cf, void *parent, void *child)
{
  ngx_http_internal_redirect_conf_t *prev = parent;
  ngx_http_internal_redirect_conf_t *conf = child;

  ngx_conf_merge_ptr_value(conf->location, prev->location, NULL);

  return NGX_CONF_OK;
}

static ngx_int_t
ngx_http_internal_redirect_location_request(ngx_http_request_t *r,
                                            ngx_str_t *location)
{
  if (!location->data) {
    return NGX_DECLINED;
  }

  if (location->data[0] == '@') {
    (void) ngx_http_named_location(r, location);
  }
  else {
    ngx_str_t args = ngx_null_string;

    ngx_http_split_args(r, location, &args);
    (void) ngx_http_internal_redirect(r, location, &args);
  }

  ngx_http_finalize_request(r, NGX_DONE);

  return NGX_DONE;
}

static ngx_int_t
ngx_http_internal_redirect_precontent_handler(ngx_http_request_t *r)
{
  ngx_http_internal_redirect_conf_t *cf;
  ngx_str_t location = ngx_null_string;

  cf = ngx_http_get_module_loc_conf(r, ngx_http_internal_redirect_module);

  if (cf->location == NULL) {
    return NGX_DECLINED;
  }

  if (ngx_http_complex_value(r, cf->location, &location) != NGX_OK) {
    return NGX_DECLINED;
  }

  if (location.len == 0) {
    return NGX_DECLINED;
  }

  return ngx_http_internal_redirect_location_request(r, &location);
}

static ngx_int_t
ngx_http_internal_redirect_post_conf(ngx_conf_t *cf)
{
  ngx_http_handler_pt *handler;
  ngx_http_core_main_conf_t *conf;

  conf = ngx_http_conf_get_module_main_conf(cf, ngx_http_core_module);

  handler = ngx_array_push(&conf->phases[NGX_HTTP_PRECONTENT_PHASE].handlers);
  if (handler == NULL) {
    return NGX_ERROR;
  }
  *handler = ngx_http_internal_redirect_precontent_handler;

  return NGX_OK;
}
