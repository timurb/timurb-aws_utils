#!/usr/bin/env ruby

require 'aws_creds'

class EC2Conn
  class << self
    @@ec2 = nil
    @@instances = nil
    @@groups = nil
    
    def ec2
      @@ec2 || @@ec2=RightAws::Ec2.new
    end
    
    def instances
      @@instances || @@instances=ec2.describe_instances
    end
    
    def groups
      return @@groups if @@groups
      @@groups=[]

      instances.each do |instance|
        group = instance[:aws_groups][0]
        @@groups.include?(group) || @@groups.push(group)
      end
      @@groups
    end
    
    def each_group(gr)
      [gr].flatten.each do |group|
        instances.each do |instance|
          instance[:aws_groups].include?(group) && yield(instance)
        end
      end
    end

    def method_missing(method, *args)
      ec2.send(method,*args)
    end
  end
end



