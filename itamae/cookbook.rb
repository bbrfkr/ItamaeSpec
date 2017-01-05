# assumpt SELinux is disabled

packages = ["httpd","mod_ssl"]
packages.each do |pkg|
  package pkg do
    action :install
  end
end

execute <<-EOS do
  cd /etc/httpd/conf && \
  openssl genrsa -out server.key 2048 && \
  openssl req -new -key server.key -out server.csr \
    -subj '/C=JP/ST=Tokyo/L=Tokyo/O=Example Ltd./OU=Web/CN=example.com' && \
  openssl x509 -in server.csr -days 3650 -req -signkey server.key > server.crt
EOS
  not_if "test -e /etc/httpd/conf/server.crt"
end

file "/etc/httpd/conf.d/ssl.conf" do
  action :edit
  block do |content|
    content.gsub!(/^SSLCertificateFile.*$/, "SSLCertificateFile /etc/httpd/conf/server.crt")
    content.gsub!(/^SSLCertificateKeyFile.*$/, "SSLCertificateKeyFile /etc/httpd/conf/server.key")
  end
end

template "/var/www/html/index.html" do
  action :create
  mode "644"
  source "index.html.erb"
  variables(greeting: node['greeting'])
end

service "httpd" do
  action [:enable, :start]
end

