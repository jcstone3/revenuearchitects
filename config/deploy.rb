# config valid only for Capistrano 3.1
# lock '3.1.0'
#
# set :application, 'revenuegrader'
# set :repo_url, 'git@example.com:me/my_repo.git'
#
# set :pty, true
#
# set :stages, %w(production staging)
# Default branch is :master
# ask :branch, proc { `git rev-parse --abbrev-ref HEAD`.chomp }
# If just cap deply is run, it will by-default deploy to staging server
# set :default_stage, "staging"
require 'bundler/capistrano'
require 'capistrano/ext/multistage'
require "rvm/capistrano"
set :application, "revenuegrader"
# set :rvm_type, :system
# set :rvm_path, '/usr/local/rvm'
set :rvm_ruby_string, 'ruby-1.9.3-p125'
# set :default_shell, '/bin/bash -l'
# set :rvm_ruby_string, ENV['GEM_HOME'].gsub(/.*\//,"")
# set :rvm_type, :user
# Load RVM's capistrano plugin
load "deploy/assets"

# set :deploy_to, "/home/icicle/sites/revenuegrader"
# set :scm, :git
# set :branch, "ss_capistrano"
# set :user, "icicle"
# set :copy_dir, "/home/#{user}/tmp"
# set :remote_copy_dir, "/tmp"
# set :group, "deployers"
# set :use_sudo, false
# set :rails_env, "staging"
# set :deploy_via, :copy
# set :ssh_options, { :forward_agent => true}
ssh_options[:forward_agent] = true
set :keep_releases, 5
default_run_options[:pty] = true
namespace :deploy do
task :start do
end
task :stop do
end
desc "Symlink shared config files"
task :symlink_config_files do
# # run "#{ sudo } ln -s #{ deploy_to }/shared/config/database.yml #{ current_path }/config/database.yml"
# # run "#{ sudo } ln -s #{ deploy_to }/shared/config/application.yml #{ current_path }/config/application.yml"
# #
run "ln -nfs #{shared_path}/config/application.yml #{release_path}/config/application.yml"
 end
# NOTE: I don't use this anymore, but this is how I used to do it.
desc "Precompile assets after deploy"
task :precompile_assets do
run <<-CMD
cd #{ current_path } &&
#{ sudo } bundle exec rake assets:precompile RAILS_ENV=#{ rails_env }
CMD
end
desc "Restart applicaiton"
task :restart do
run "#{ try_sudo } touch #{ File.join(current_path, 'tmp', 'restart.txt') }"
end
 end
namespace :db do
desc <<-DESC
Creates the database.yml configuration file in shared path.
By default, this task uses a template unless a template
called database.yml.erb is found either is :template_dir
or /config/deploy folders. The default template matches
the template for config/database.yml file shipped with Rails.
When this recipe is loaded, db:setup is automatically configured
to be invoked after deploy:setup. You can skip this task setting
the variable :skip_db_setup to true. This is especially useful
if you are using this recipe in combination with
capistrano-ext/multistaging to avoid multiple db:setup calls
when running deploy:setup for all stages one by one.
DESC
task :setup, :except => { :no_release => true } do
default_template = <<-EOF
base: &base
adapter: postgresql
timeout: 5000
username: postgres
password: macro129
development:
database: revenue_development
<<: *base
staging:
database: revenue_staging
<<: *base
production:
database: revenue_production
<<: *base
EOF
location = fetch(:template_dir, "config/deploy") + '/database.yml.erb'
template = File.file?(location) ? File.read(location) : default_template
config = ERB.new(template)
run "mkdir -p #{shared_path}/db"
run "mkdir -p #{shared_path}/config"
put config.result(binding), "#{shared_path}/config/database.yml"
end

desc <<-DESC
[internal] Updates the symlink for database.yml file to the just deployed release.
DESC
task :symlink, :except => { :no_release => true } do
run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
#run "ln -nfs #{shared_path}/log #{release_path}/log/#{rails_env}.log"
end
end

desc "Loads seed data in the application"
task :seed_data, :except => { :no_release => true } do
run "cd #{current_path} && rake db:seed RAILS_ENV=#{rails_env} "
end
# Creating backup folder and storing database dump in that folder

namespace :backup do
desc "Backup the database"
task :db, :roles => :db do
run "mkdir -p #{shared_path}/backups"
run "cd #{shared_path}; pg_dump -U postgres #{application}_#{rails_env} -f backups/#{Time.now.utc.strftime('%Y%m%d%H%M%S')}.sql"
end

# Downloading the latest database backup
desc "Backup the database and download the script"
task :download, :roles => :app do
db
timestamp = Time.now.utc.strftime('%Y%m%d%H%M%S')
run "mkdir -p backups"
run "cd #{shared_path}; tar -cvzpf #{timestamp}_backup.tar.gz backups"
get "#{shared_path}/#{timestamp}_backup.tar.gz", "#{timestamp}_backup.tar.gz"
end
end

namespace :folder do
  desc "creating folders for application"
  task :setup, :except => { :no_release => true } do
    run "mkdir -p #{shared_path}/sockets"
  end
  desc "creating symlinks for the folders"
  task :symlink, :except => { :no_release => true } do
    run "ln -nfs #{shared_path}/sockets #{release_path}/tmp/sockets"
  end
end

# # This will restart the nginx and unicorn
namespace :restart do
desc "Restarting Nginx"
task :nginx_restart, :roles => :app do
sudo "service nginx restart"
end

desc "Restarting Unicorn"
task :unicorn_restart, :roles => :app do
sudo "service unicorn restart"
end
end

after "deploy:setup", "db:setup" unless fetch(:skip_db_setup, false)
after "symlink_config_files", "deploy:precompile_assets"
after "deploy:finalize_update", "db:symlink"
after "db:symlink", "deploy:symlink_config_files"
after "deploy", "folder:setup"
after "folder:setup", "folder:symlink"
after "folder:symlink", "restart:nginx_restart"
# after "deploy", "deploy:restart"
# after "deploy", "deploy:cleanup"
# after "deploy", "restart:nginx_restart"
after "restart:nginx_restart", "restart:unicorn_restart"
after "restart:unicorn_restart","deploy:cleanup"
