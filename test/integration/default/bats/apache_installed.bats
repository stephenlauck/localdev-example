#!/usr/bin/env bats

@test "httpd binary is found in PATH" {
  run which httpd
  [ "$status" -eq 0 ]
}