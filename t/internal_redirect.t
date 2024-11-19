use Test::Nginx::Socket 'no_plan';

no_root_location();
no_shuffle();

run_tests();

__DATA__

=== location
--- http_config
include $TEST_NGINX_CONF_DIR/app.conf;
--- config
location / {
  internal_redirect /test;
}
location = /test {
  internal;
  proxy_pass http://app;
}
--- request
GET /
--- response_body
OK
--- error_code: 200


=== named location
--- http_config
include $TEST_NGINX_CONF_DIR/app.conf;
--- config
location / {
  internal_redirect @test;
}
location @test {
  internal;
  proxy_pass http://app;
}
--- request
GET /
--- response_body
OK
--- error_code: 200


=== variable
--- http_config
include $TEST_NGINX_CONF_DIR/app.conf;
--- config
location / {
  set $redirect_uri @test;
  internal_redirect $redirect_uri;
}
location @test {
  internal;
  proxy_pass http://app;
}
--- request
GET /
--- response_body
OK
--- error_code: 200


=== empty
--- http_config
include $TEST_NGINX_CONF_DIR/app.conf;
--- config
location / {
  internal_redirect "";
}
location @test {
  internal;
  proxy_pass http://app;
}
--- request
GET /
--- response_body_unlike
^OK.*$
--- error_code: 200
