#!/usr/bin/env ruby

require 'pathname'
require 'json'
require 'yaml'

require_relative './helpers.rb'

london_meta_path = Pathname.new("#{Dir.home}/workspace/london-meta/")
london_services_locks_path = Pathname.new("#{Dir.home}/workspace/london-services-locks/")
ssh_config_path = Pathname.new("#{Dir.home}/.ssh/config")

gcp_envs = london_meta_path + "gcp-environments"
aws_envs = london_meta_path + "aws-environments"

all_env_paths = gcp_envs.children.select { |c| c.directory? } +
  aws_envs.children.select { |c| c.directory? }

envs = all_env_paths.map do |path|
  OpsmanEnvFactory.create_env(path)
end

envs.compact.each do |env|
  env.add_to_ssh_config(ssh_config_path)
end

puts "Done."
