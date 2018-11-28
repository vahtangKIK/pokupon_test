#encoding: utf-8

Dir.chdir(File.dirname(__FILE__))
Dir.chdir('..')

require 'json'
require 'logger'
require './src/host.rb'
require './src/mailer.rb'
puts Dir.pwd
config = JSON.parse(File.read './config.json')
puts config.inspect
$log = Logger.new('./' + config['logging']['file'],'weekly')
$log.level = eval('Logger::' + config['logging']['level'])
Mailer.setup(config['smtp'], config['mail_to'], config['mail_from'])
hosts = []
$log.info("Pokupon checker is started up")
config['hosts'].each do |host|  
  hosts << Host.new(host, config['interval']).run
  $log.info("Host #{host} is watchdogged")
end

loop do
  sleep(5)
end

