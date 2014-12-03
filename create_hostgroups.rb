require 'foreman_api'
require 'logger'
require 'highline/import'
require 'pp'
require 'pry'

# Set up logger:
log = Logger.new(STDOUT)
log.level = Logger::INFO

# Get creds:
username = ask("Username: ")
password = ask("Password: ") { |q| q.echo = false }

hg = ForemanApi::Resources::Hostgroup.new(
  {
    :logger => log,
    :base_url => 'http://foreman.***REMOVED***',
    :username => username,
    :password => password,
    :per_page => 407
  })

hostgroups = hg.index({:per_page => 500})[0]['results']


hostgroups.each do |hostgroup|
  if hostgroup['ancestry'].nil?
    parent = hostgroup['id']
    envid  = hostgroup['environment_id']

    log.info "Creating #{hostgroup['title']}/dummy hostgroup..."
    cmd = "hammer hostgroup create --parent-id #{parent} --environment-id #{envid} --name dummy"
    log.debug "Running Hammer with: #{cmd}"
    system cmd
  end
end
