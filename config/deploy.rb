# config valid for current version and patch releases of Capistrano
lock "~> 3.17.2"

set :application, ENV["APPLICATION_NAME"]
set :repo_url, ENV["REPO_URL"]
set :default_env, { 'PATH' => '/sbin:$PATH' }

set :nvm_type, :user # or :system, depending on your preference
set :nvm_node, ENV["NODE_VERSION"]

set :php, ENV["PHP"]

set :jobs, ENV["JOBS"]

set :hyva, (ENV["USE_HYVA"] == 'true')

if fetch(:hyva,false)

  set :nvm_type, :user # or :system, depending on your preference
  set :nvm_node, ENV["NODE_VERSION"]

  set :use_npm, ENV["USE_NPM"]

  set :hyva_tailwind_paths, JSON.parse(ENV["HYVA_TAILWIND_PATHS"])

end


SSHKit::Backend::Netssh.configure do |ssh|
  ssh.ssh_options = {
      verify_host_key: :never,
  }
end


##link the files
append :linked_files, 'app/etc/env.php'


## link the shared directories
append :linked_dirs, 'pub/media'
append :linked_dirs, 'var/import'
append :linked_dirs, 'var/export'
append :linked_dirs, 'var/importexport'
append :linked_dirs, 'var/import_history'
append :linked_dirs, 'var/log'





 before  'deploy:symlink:linked_files', 'deploy:composer_install'
 after 'deploy:symlink:linked_dirs', 'deploy:set_magento_permission'
 after 'deploy:set_magento_permission', 'deploy:magento_maintenance_enable'
 after 'deploy:magento_maintenance_enable', 'deploy:set_deploy_mode'
 after 'deploy:set_deploy_mode', 'deploy:magento_setup_upgrade'
 after 'deploy:magento_setup_upgrade', 'deploy:magento_compile'
 after 'deploy:magento_compile', 'deploy:magento_static_deploy'
 after 'deploy:magento_static_deploy', 'deploy:magento_flush'
 after 'deploy:magento_flush', 'deploy:magento_maintenance_disable'


 # Remove the Failed Deployment Folders
 after  'deploy:failed', 'deploy:delete_failed_release'

# Default branch is :master
# ask :branch, `git rev-parse --abbrev-ref HEAD`.chomp

# Default deploy_to directory is /var/www/my_app_name
# set :deploy_to, "/var/www/my_app_name"

# Default value for :format is :airbrussh.
# set :format, :airbrussh

# You can configure the Airbrussh format using :format_options.
# These are the defaults.
# set :format_options, command_output: true, log_file: "log/capistrano.log", color: :auto, truncate: :auto

# Default value for :pty is false
# set :pty, true

# Default value for :linked_files is []
# append :linked_files, "config/database.yml", 'config/master.key'

# Default value for linked_dirs is []
# append :linked_dirs, "log", "tmp/pids", "tmp/cache", "tmp/sockets", "tmp/webpacker", "public/system", "vendor", "storage"

# Default value for default_env is {}
# set :default_env, { path: "/opt/ruby/bin:$PATH" }

# Default value for local_user is ENV['USER']
# set :local_user, -> { `git config user.name`.chomp }

# Default value for keep_releases is 5
# set :keep_releases, 5

# Uncomment the following to require manually verifying the host key before first deploy.
# set :ssh_options, verify_host_key: :secure
