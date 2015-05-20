# localdev-example

```
chef generate cookbook localdev-example
cd localdev-example
git add .
git commit -am 'initial commit'
```

### edit localdev-example/.kitchen.yml
```
---
driver:
  name: vagrant

provisioner:
  name: chef_zero

platforms:
  - name: ubuntu-14.04
  - name: centos-6.6

suites:
  - name: default
    run_list:
      - recipe[localdev-example::default]
    attributes:
```

### edit localdev-example/recipes/default.rb
```
#
# Cookbook Name:: localdev-example
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

package 'apache'
```

### build node using test-kitchen
```
kitchen list
kitchen converge default-centos-66
```

### check package name on node
```
kitchen login default-centos-66
sudo yum search apache
exit
```

### edit localdev-example/recipes/default.rb
```
#
# Cookbook Name:: localdev-example
# Recipe:: default
#
# Copyright (c) 2015 The Authors, All Rights Reserved.

package 'httpd'
```

### converge node
```
kitchen converge default-centos-66
```

### write bats test to confirm httpd is installed
```
mkdir -p test/integration/default/bats
```

### edit test/integration/default/bats/apache_installed.bats
```
@test "httpd binary is found in PATH" {
  run which httpd
  [ "$status" -eq 0 ]
}
```

### verify tests with test-kitchen
```
kitchen verify default-centos-66
```

## Use cookbook for httpd

### edit localdev-example/metadata.rb
```
name             'localdev-example'
maintainer       'The Authors'
maintainer_email 'you@example.com'
license          'all_rights'
description      'Installs/Configures localdev-example'
long_description 'Installs/Configures localdev-example'
version          '0.1.0'

depends 'httpd'
```

### edit localdev-example/recipes/default.rb
```
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
```

### edit localdev-example/templates/default/hello.erb
```
<VirtualHost *:80>
  ServerAdmin webmaster@localhost

  DocumentRoot /var/www

  <Directory />
    Options FollowSymLinks
    AllowOverride None
  </Directory>

  <Directory /var/www/>
    Options Indexes FollowSymLinks MultiViews
    AllowOverride None
    Order allow,deny
    allow from all
  </Directory>

  ScriptAlias /cgi-bin/ /usr/lib/cgi-bin/
  <Directory "/usr/lib/cgi-bin">
    AllowOverride None
    Options +ExecCGI -MultiViews +SymLinksIfOwnerMatch
    Order allow,deny
    Allow from all
  </Directory>

  LogLevel warn
</VirtualHost>
```

### converge and verify
```
kitchen converge default-centos-66
kitchen verify default-centos-66
```

### write serverspec test to confirm port 80 is listening
```
mkdir -p test/integration/server/serverspec
```

### edit test/integration/server/serverspec/httpd_port_listen_spec.rb
```
require 'serverspec'

# Required by serverspec
set :backend, :exec

describe "httpd port" do
  it "is listening on port 80" do
    expect(port(80)).to be_listening
  end
end
```

### converge and verify
```
kitchen converge default-centos-66
kitchen verify default-centos-66
```

## add port-forwarding

### edit localdev-example/.kitchen.yml
```
---
driver:
  name: vagrant

provisioner:
  name: chef_zero

platforms:
  - name: ubuntu-14.04
  - name: centos-6.6

suites:
  - name: default
    run_list:
      - recipe[localdev-example::default]
    driver:
      network:
        - ['private_network', {ip: '33.33.33.10'}]
    attributes:
```

### destroy node and test again
```
kitchen destroy
kitchen converge default-centos-66
```

## test for hello site

### edit test/integration/server/serverspec/hello_spec.rb
```
require 'serverspec'

set :backend, :exec

describe command("curl -L localhost | grep 'hello there'") do
  its(:exit_status) { should eq 0 }
end
```

### verify
```
kitchen verify default-centos-66
```
