include_recipe "varnish"

cookbook_file "/etc/default/varnish" do
  source "varnish/default_varnish"
  owner "root"
  group "root"
  mode "0644"
end

cookbook_file "/etc/varnish/default.vcl" do
  source "varnish/default.vcl"
  owner "root"
  group "root"
  mode "0644"
end

cookbook_file "/etc/apache2/ports.conf" do
  source "varnish/apache_ports.conf"
  owner "root"
  group "root"
  mode "0644"
end

# port shuffling
service "apache2" do
  supports :restart => true
  action [ :restart ]
end

service "varnish" do
  supports :restart => true
  action [ :restart ]
end