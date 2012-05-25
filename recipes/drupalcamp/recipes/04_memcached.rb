package "memcached"
package "php5-memcache"

execute "downtune memcache" do
  command "sed -i 's/-m 64/-m 16/' /etc/memcached.conf" 
  action :run
end

service "apache2" do
  supports :restart => true
  action [ :restart ]
end
service "memcached" do
  supports :restart => true
  action [ :restart ]
end
