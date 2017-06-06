#!/usr/bin/env ruby

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
    raise "No such file - #{ssh_config_path}" unless File.exist? ssh_config_path
    ssh_config = File.read(ssh_config_path)

    if ssh_config.include?(self.name)
      puts "-- skipping #{self.name}, already present in config"
      return
    end

    puts "Adding alias for #{self.name}"
    ssh_alias = create_formatted_ssh_alias(self)
    File.open(ssh_config_path, 'a') { |f| f.write(ssh_alias) }
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
