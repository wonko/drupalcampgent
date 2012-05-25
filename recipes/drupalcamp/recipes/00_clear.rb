# execute "swapoff" do
#   command "swapoff -a"
#   action :run
# end

%w(memcached php5-memcache php5-xcache mysql-server-5.1 apache2 libapache2-mod-php5 varnish).each do |pkg|
  package pkg do
    action :remove
  end
end