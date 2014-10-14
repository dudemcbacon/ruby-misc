require 'rye'
require 'pry'

# Set up the logger...
logger = Logger.new(STDOUT)

#hosts = `serverl | grep "^con" | grep -v .prd.`.split

hosts = `serverl | grep "^con" | grep int03`.split

# Add the commands we use:
Rye::Cmd.add_command :rpm, '/bin/rpm -qa | grep controller | echo butt'

rset = Rye::Set.new "CON", :safe => false

hosts.each do |host|
   logger.debug "Adding #{host} to rset..."
   rset.add_boxes host
end

versions = rset.execute 'rpm -qa | grep controller'

hosts.each_with_index do |host, index|
  versions[index] = versions[index][0].split(/-/)[2]
  logger.info "Host #{host} is at #{versions[index]}"
end

files = rset.execute 'ls -lht /opt/controller-server/work | grep -v "^total"'.split

hosts.each_with_index do |host, index|
  logger.debug "Host #{host} has #{files[index].count} files in it's work directory."
  
  count = 0
  files[index].each do |file|
    count+=1 if file.include?(versions[index])
  end

  logger.debug "Host #{host} has #{count} files that are at version #{versions[0]}"

  if count == 1
    files[index].each do |file|
      unless file.include?(versions[index])
        filename = file.split[8] 
        logger.info "Removing #{filename} from #{host}."
      end
    end
  else
    logger.warn "There are two war files that share the same major version on #{host}."
    files[index].each do |file|
      if file.include?(versions[index])
        filename = file.split[8]
        logger.warn "=> #{filename}"
      end
    end
    latest_file = files[index][0].split[8]
    logger.warn "The last modified version is #{latest_file}. Keep that and delete the rest?"
    a = gets.chomp
    if a
  end

end
