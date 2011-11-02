#!/usr/bin/ruby
require "rubygems"
require "bundler/setup"
require 'clooneys'
require 'clooneys_runner'

Clooneys::Console.new( ClooneysRunner.user ).start
