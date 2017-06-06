#!/usr/bin/env ruby

OpsmanEnv = Struct.new(:name, :username, :password, :url, :ssh_host, :ssh_user, :ssh_key)

def parse_envs(paths)
  envs = []

  paths.each do |path|
    config_path = Dir["#{Dir.home}/workspace/london-services-locks/**/#{path.basename.to_s}"].first

    if config_path.nil?
      puts "-- skipping #{path.basename.to_s}, missing config"; next
    end

    config = JSON.parse(File.read(config_path))

    begin
      if config["iaas_type"] == "gcp"
        envs << create_gcp_env(path, config)
      else
        envs << create_aws_env(path, config)
      end

    rescue Exception => err
      puts "-- error parsing config for #{path.basename.to_s} [#{err}]"
      next
    end
  end

  return envs
end

def add_envs_to_ssh_config(opsman_envs, ssh_config_path)
  raise unless File.exist? ssh_config_path

  ssh_config = File.read(ssh_config_path)

  opsman_envs.each do |e|
    next if ssh_config.include?(e.name)

    puts "Adding alias for #{e.name}"
    ssh_alias = create_formatted_ssh_alias(e)
    File.open(ssh_config_path, 'a') { |f| f.write(ssh_alias) }
  end
end

def create_formatted_ssh_alias(env)
"Host #{env.name}
  HostName #{env.ssh_host}
  User #{env.ssh_user}
  IdentityFile #{env.ssh_key}
  StrictHostKeyChecking no

"
end

def create_aws_env(path, config_json)
  OpsmanEnv.new(
    path.basename.to_s,
    config_json.fetch("ops_manager").fetch("username"),
    config_json.fetch("ops_manager").fetch("password"),
    config_json.fetch("ops_manager").fetch("url"),
    config_json.fetch("proxy").fetch("host"),
    config_json.fetch("proxy").fetch("username"),
    path.to_s + "/" + path.basename.to_s + "-pcf.pem"
  )
end

def create_gcp_env(path, config_json)
  OpsmanEnv.new(
    path.basename.to_s,
    config_json.fetch("ops_manager").fetch("username"),
    config_json.fetch("ops_manager").fetch("password"),
    config_json.fetch("ops_manager").fetch("url"),
    config_json.fetch("ops_manager_dns"),
    config_json.fetch("ops_manager_public_key").split(":").first,
    path.to_s + "/" + path.basename.to_s + "-pcf.pem"
  )
end
