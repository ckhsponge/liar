#!/usr/bin/ruby
$:.unshift File.dirname(__FILE__)
require "rubygems"
require "bundler/setup"
require 'clooneys'
require 'clooneys_runner'

user = ClooneysRunner.user
intelligence_player = Clooneys::IntelligencePlayer.new( Clooneys::Intelligence, user )
intelligence_player.start