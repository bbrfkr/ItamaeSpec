require 'spec_helper'

describe ("check packages are installed") do
  packages = ["httpd", "mod_ssl"]
  packages.each do |pkg|
    describe package(pkg) do
      it { should be_installed }
    end
  end
end

describe ("check private key is generated") do
  describe file("/etc/httpd/conf/server.key") do
    it { should exist }
  end
end

describe ("check certificate is generated") do
  describe file("/etc/httpd/conf/server.crt") do
    it { should exist }
  end
end

describe ("check SSLCertificateFile parameter is set") do
  describe file("/etc/httpd/conf.d/ssl.conf") do
    its(:content) { should match /^SSLCertificateFile \/etc\/httpd\/conf\/server.crt$/ }
  end
end

describe ("check SSLCertificateKeyFile parameter is set") do
  describe file("/etc/httpd/conf.d/ssl.conf") do
    its(:content) { should match /^SSLCertificateKeyFile \/etc\/httpd\/conf\/server.key$/ }
  end
end

describe ("check content of index.html is appropriate") do
  describe file("/var/www/html/index.html") do
    its(:content) { should match /^Hello, #{ property['greeting'] }!!$/}
  end
end

describe ("check httpd service is started") do
  describe service("httpd") do
    it { should be_running }
    it { should be_enabled }
  end
end
