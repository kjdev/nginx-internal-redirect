use Test::Nginx::Socket 'no_plan';

no_root_location();
no_shuffle();

run_tests();

__DATA__

=== limit request
--- http_config
include $TEST_NGINX_CONF_DIR/app.conf;
limit_req_zone $binary_remote_addr zone=one:1m rate=2r/s;
--- config
location / {
  internal_redirect @test;
}
location @test {
  internal;
  limit_req zone=one burst=1 nodelay;
  proxy_pass http://app;
}
--- request eval
[
  "GET /",
  "GET /",
  "GET /",
]
--- error_code eval
[
  200,
  200,
  503,
]


=== user limit
--- http_config
include $TEST_NGINX_CONF_DIR/app.conf;
limit_req_zone $x_user zone=one:1m rate=1r/m;
--- config
location / {
  auth_request /auth;
  auth_request_set $x_user $upstream_http_x_user;

  internal_redirect @test;
}
location = /auth {
  internal;
  proxy_pass http://app;
  proxy_pass_request_body off;
  proxy_set_header X-User $http_x_user;
}
location @test {
  internal;
  limit_req zone=one burst=1 nodelay;
  proxy_pass http://app;
}
--- request eval
[
  "GET /",
  "GET /",
  "GET /",
  "GET /",
  "GET /",
  "GET /",
  "GET /",
  "GET /",
  "GET /",
]
--- more_headers eval
[
  "X-User: a",
  "X-User: a",
  "X-User: a",
  "X-User: b",
  "X-User: b",
  "X-User: b",
  "X-User: c",
  "X-User: c",
  "X-User: c",
]
--- error_code eval
[
  200,
  200,
  503,
  200,
  200,
  503,
  200,
  200,
  503,
]
