require 'hiera'
puts 'says something'
hiera = Hiera.new(:config => './hiera.yaml')
