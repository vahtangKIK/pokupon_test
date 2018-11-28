#! /usr/bin/env ruby

require 'rubygems'
require 'daemons'

Daemons.run('./src/daemon.rb')

