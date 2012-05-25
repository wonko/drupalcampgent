# apc

package "php5-xcache"

execute "apache restart" do
  command "/etc/init.d/apache2 restart"
  action :run
end
