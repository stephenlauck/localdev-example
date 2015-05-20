#
# Cookbook Name:: localdev-example
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

httpd_service 'default' do
  action [:create, :start]
end

httpd_config 'hello' do
  source 'hello.erb'
  notifies :restart, 'httpd_service[default]'
end

file '/var/www/index.html' do
  content 'hello there\n'
  action :create
end