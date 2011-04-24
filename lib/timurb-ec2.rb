#!/usr/bin/env ruby

require 'rubygems'
require 'timurb-aws_creds'
require 'right_aws'
require 'logger'

class EC2Conn
  class << self
    @@ec2 = nil
    @@instances = nil
    @@groups = nil
    
    def ec2( opts = {} )
      @@ec2=RightAws::Ec2.new(ENV['AWS_ACCESS_KEY_ID'], ENV['AWS_SECRET_ACCESS_KEY'], :logger => opts[:logger] || Logger.new( nil )) \
        unless @@ec2
      @@ec2
    end
    
    def instances
      @@instances=ec2.describe_instances  unless @@instances
      @@instances
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
    
    def each_group(grps)
      [grps].flatten.each do |group|
        instances.each do |instance|
          instance[:aws_groups].include?(group) && yield(instance)
        end
      end
    end

    def instances_group(grps)
      instances=[]
      each_group(grps) do |instance|
        instances.push instance
      end
      instances
    end

    def find_instance(instance)
      instance.is_a?( Hash ) && instance = instance[:aws_instance_id]
      instances.find{ |inst| inst[:aws_instance_id] == instance }
    end

    def find_instance_by_ip(ip)
      instances.each do |instance|
        return instance if instance[:ip_address] == ip || instance[:private_ip_address] == ip
      end
      nil
    end

    def instance_vol_by_name(instance, vol_name)
      instance = find_instance(instance)

      instance[:block_device_mappings].each do |ebs|
        if ebs[:device_name] == vol_name
          return ebs[:ebs_volume_id]
        end
      end
    end

    def wait_snapshot(snapshots)
      snapshots = [snapshots].flatten.compact
      loop do
        break unless
          catch(:pending) do
            sleep 1	# to avoid Request Limit Exceeded exception
            ec2.describe_snapshots(snapshots).each do |snap|
              throw(:pending, snap) if snap[:aws_status] == 'pending'
              snap[:aws_status]!='completed' &&  p(snap)
            end
            nil
          end
      end
    end

    def method_missing(method, *args)
      ec2.send(method,*args)
    end
  end
end



