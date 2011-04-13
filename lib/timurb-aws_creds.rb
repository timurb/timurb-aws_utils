#!/usr/bin/env ruby

File.open(ENV['AWS_CREDENTIAL_FILE']).readlines.each do |s|
 s.chomp!
 m = s.match /AWSAccessKeyId=(.*)/
 m and m[1] and ENV['AWS_ACCESS_KEY_ID']=m[1]
 m = s.match /AWSSecretKey=(.*)/
 m and m[1] and ENV['AWS_SECRET_ACCESS_KEY']=m[1]
end unless ENV['AWS_CREDENTIAL_FILE'].nil?
