#!/usr/bin/env ruby

ENV['BUNDLE_GEMFILE']=File.join(File.dirname(__FILE__),'Gemfile')

require 'rubygems'
require 'bundler/setup'
require 'right_aws'

File.open(ENV['AWS_CREDENTIAL_FILE']).readlines.each do |s|
 s.chomp!
 m = s.match /AWSAccessKeyId=(.*)/
 m and m[1] and ENV['AWS_ACCESS_KEY_ID']=m[1]
 m = s.match /AWSSecretKey=(.*)/
 m and m[1] and ENV['AWS_SECRET_ACCESS_KEY']=m[1]
end
