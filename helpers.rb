#!/usr/bin/env ruby

london_meta_path = Pathname.new("#{Dir.home}/workspace/london-meta/")
london_services_locks_path = Pathname.new("#{Dir.home}/workspace/london-services-locks/")
gcp_envs = london_meta_path + "gcp-environments"
aws_envs = london_meta_path + "aws-environments"

ALL_ENV_PATHS = gcp_envs.children.select { |c| c.directory? } +
  aws_envs.children.select { |c| c.directory? }

SSH_CONFIG_PATH = Pathname.new("#{Dir.home}/.ssh/config")

class OpsmanEnvFactory
  def self.create_env(path)
    config_path = Dir["#{Dir.home}/workspace/london-services-locks/**/#{path.basename.to_s}"].first

    if config_path.nil?
      puts "-- skipping #{path.basename.to_s}, missing config"
      return nil
    end

    config = JSON.parse(File.read(config_path))

    begin
      if config["iaas_type"] == "gcp"
        return OpsmanEnv.new(
          name: path.basename.to_s,
          username: config.fetch("ops_manager").fetch("username"),
          password: config.fetch("ops_manager").fetch("password"),
          url: config.fetch("ops_manager").fetch("url"),
          ssh_host: config.fetch("ops_manager_dns"),
          ssh_user: config.fetch("ops_manager_public_key").split(":").first,
          ssh_key: path.to_s + "/" + path.basename.to_s + "-pcf.pem"
        )
      else
        return OpsmanEnv.new(
          name: path.basename.to_s,
          username: config.fetch("ops_manager").fetch("username"),
          password: config.fetch("ops_manager").fetch("password"),
          url: config.fetch("ops_manager").fetch("url"),
          ssh_host: config.fetch("proxy").fetch("host"),
          ssh_user: config.fetch("proxy").fetch("username"),
          ssh_key: path.to_s + "/" + path.basename.to_s + "-pcf.pem"
        )
      end

    rescue Exception => err
      puts "-- error parsing config for #{path.basename.to_s} [#{err}]"
      return nil
    end
  end
end

class OpsmanEnv
  require 'json'

  attr_accessor :name, :username, :password, :url, :ssh_host, :ssh_user, :ssh_key

  def initialize(args)
    @name = args.fetch(:name)
    @username = args.fetch(:username)
    @password = args.fetch(:password)
    @url = args.fetch(:url)
    @ssh_host = args.fetch(:ssh_host)
    @ssh_user = args.fetch(:ssh_user)
    @ssh_key = args.fetch(:ssh_key)
  end

  def add_to_ssh_config(ssh_config_path)
    raise "No such file - #{SSH_CONFIG_PATH}" unless File.exist? SSH_CONFIG_PATH
    ssh_config = File.read(SSH_CONFIG_PATH)

    if ssh_config.include?(self.name)
      puts "-- skipping #{self.name}, already present in config"
      return
    end

    puts_blue "Adding alias for #{self.name}"
    ssh_alias = create_formatted_ssh_alias
    File.open(SSH_CONFIG_PATH, 'a') { |f| f.write(ssh_alias) }
  end

  def get_director_ip
    JSON.parse(`om -k -t #{self.url} -u #{self.username} -p #{self.password} \
      curl -p /api/installation_settings 2> /dev/null`)
      .fetch("ip_assignments")
      .fetch("assignments")
      .select { |name,_| name.start_with?("p-bosh-") }
      .values[0]
      .select { |name,_| name.start_with?("director-") }
      .values[0].values[0].first
  end

  private

  def create_formatted_ssh_alias
    "Host #{self.name}
HostName #{self.ssh_host}
User #{self.ssh_user}
IdentityFile #{self.ssh_key}
StrictHostKeyChecking no

"
  end
end

def fail(message)
  puts message
  exit 1
end

def puts_blue(message)
  puts "\u001b[034m" + message + "\u001b[0m"
end
