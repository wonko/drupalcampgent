cookbook_file "/var/www/.htaccess" do
  source "boost/htaccess"
  owner "www-data"
  group "www-data"
  mode "0644"
end