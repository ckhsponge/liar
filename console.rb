#!/usr/bin/ruby
$:.unshift File.dirname(__FILE__)
require "rubygems"
require "bundler/setup"
require 'clooneys'
require 'clooneys_runner'

Clooneys::Console.new( ClooneysRunner.user ).start
