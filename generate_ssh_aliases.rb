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

envs = gcp_envs.children.select { |c| c.directory? } +
  aws_envs.children.select { |c| c.directory? }

all_parsed_envs = parse_envs(envs)

add_envs_to_ssh_config(all_parsed_envs, ssh_config_path)

puts "Done."
