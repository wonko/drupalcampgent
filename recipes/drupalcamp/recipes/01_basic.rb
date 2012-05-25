# basic drupal LAMP setup: apache, mod_php, mysql

# install apache, php and mysql
%w(libapache2-mod-php5 mysql-server-5.1 apache2 php5-gd php5-mysql).each do |pkg|
  package pkg
end

execute "rewriting" do
  command "a2enmod rewrite"
  action :run
  not_if "test -l /etc/apache2/mods-enabled/rewrite.load"
end

# mysql config
cookbook_file "/etc/mysql/my.cnf" do
  source "basic/my.cnf"
  owner "root"
  group "root"
  mode "0644"
end

service "mysql" do
  supports :restart => true
  action [ :enable, :restart ]
end

service "apache2" do
  supports :restart => true
  action [ :enable, :restart ]
end

cookbook_file "/var/www/.htaccess" do
  source "basic/htaccess"
  owner "www-data"
  group "www-data"
  mode "0644"
end

file "/var/www/phpinfo.php" do
  owner "www-data"
  group "www-data"
  mode "0755"
  action :create
  content "<?php phpinfo(); ?>"
end