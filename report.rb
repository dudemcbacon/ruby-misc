require 'foreman_api'
require 'net/ssh'
require 'pry'

hosts = ForemanApi::Resources::Host.new({
  :base_url => 'http://foreman.***REMOVED***',
  :username => '***REMOVED***',
  :password => '***REMOVED***'
}).index({"search" => "os ~ redhat", "per_page" => 600})
hosts[0]["results"].each do |host|
  output = ''
  is_virtual = ''
  begin
    Net::SSH.start(host['name'], 'brandon.burnett') do |ssh|
      output = ssh.exec!("nproc").strip
      is_virtual = ssh.exec!("sudo /opt/puppet/bin/facter -p is_virtual")
    end
  rescue
    output = "exception"
    is_virtual = "exception"
  end
  puts "#{host['name']},#{host['environment_name']},#{host['operatingsystem_name']},#{output},#{is_virtual}"
end
