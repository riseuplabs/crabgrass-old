##
## REMEMBER: you can see available tasks with "cap -T"
##

##
## Items to configure
##

set :application, "crabgrass"
set :user, "crabgrass"

set :repository, "labs.riseup.net/crabgrass.git"
set :branch, "master"

deploy_host = "xxxxxx"
staging_host = "xxxxxx"

staging = ENV['TARGET'] != 'production'

set :app_db_host, 'localhost'
set :app_db_user, 'crabgrass'
set :app_db_pass, 'xxxxxxxxx'
set :secret,  "xxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxxx"

##
## Items you should probably leave alone
##

set :scm, "git"
set :local_repository, "#{File.dirname(__FILE__)}/../"

set :deploy_via, :remote_cache

# as an alternative, if you server does NOT have direct git access to the,
# you can deploy_via :copy, which will build a tarball locally and upload
# it to the deploy server.
#set :deploy_via, :copy
set :copy_strategy, :checkout
set :copy_exclude, [".git"]

set :git_shallow_clone, 1  # only copy the most recent, not the entire repository (default:1)
set :git_enable_submodules, 0
set :keep_releases, 3

ssh_options[:paranoid] = false
set :use_sudo, false

role :web, (staging ? staging_host : deploy_host)
role :app, (staging ? staging_host : deploy_host)
role :db, (staging ? staging_host : deploy_host), :primary=>true

set :deploy_to, "/usr/apps/#{application}"


##
## CUSTOM TASKS
##

namespace :passenger do
  desc "Restart rails application"
  task :restart do
    run "touch #{current_path}/tmp/restart.txt"
  end

  # requires root
  desc "Check memory stats"
  task :memory do
    sudo "passenger-memory-stats"
  end

  # requires root
  desc "Check status of rails processes"
  task :status do
    sudo "passenger-status"
  end
end

# CREATING DATABASE.YML
# inspired by http://www.jvoorhis.com/articles/2006/07/07/managing-database-yml-with-capistrano

def database_configuration(db_role)
%Q[
login: &login
  adapter: mysql
  encoding: utf8
  host: #{eval(db_role+"_db_host")}
  username: #{eval(db_role+"_db_user")}
  password: #{eval(db_role+"_db_pass")}

development:
  database: #{application}_development
  <<: *login

test:
  database: #{application}_test
  <<: *login

production:
  database: #{application}
  <<: *login
]
end

namespace :crabgrass do

  # rerun after_setup if you change the db configuration
  desc "Create shared directories, update database.yml"
  task :create_shared, :roles => :app do
    run "mkdir -p #{deploy_to}/#{shared_dir}/tmp/sessions"
    run "mkdir -p #{deploy_to}/#{shared_dir}/tmp/cache"
    run "mkdir -p #{deploy_to}/#{shared_dir}/tmp/sockets"
    run "mkdir -p #{deploy_to}/#{shared_dir}/avatars"
    run "mkdir -p #{deploy_to}/#{shared_dir}/assets"
    run "mkdir -p #{deploy_to}/#{shared_dir}/index"
    run "mkdir -p #{deploy_to}/#{shared_dir}/public_assets"
    run "mkdir -p #{deploy_to}/#{shared_dir}/latex"
    run "mkdir -p #{deploy_to}/#{shared_dir}/sphinx"

    run "mkdir -p #{deploy_to}/#{shared_dir}/config"
    put database_configuration('app'), "#{deploy_to}/#{shared_dir}/config/database.yml"
    put secret, "#{deploy_to}/#{shared_dir}/config/secret.txt"
  end

  desc "Link in the shared dirs"
  task :link_to_shared do
    run "rm -rf #{current_release}/tmp"
    run "ln -nfs #{shared_path}/tmp #{current_release}/tmp"

    run "rm -rf #{current_release}/index"
    run "ln -nfs #{shared_path}/index #{current_release}/index"

    run "rm -rf #{current_release}/assets"
    run "ln -nfs #{shared_path}/assets #{current_release}/assets"

    run "rm -rf #{current_release}/public/assets"
    run "ln -nfs #{shared_path}/public_assets #{current_release}/public/assets"

    run "rm -rf #{current_release}/public/avatars"
    run "ln -nfs #{shared_path}/avatars #{current_release}/public/avatars"

    run "rm -rf #{current_release}/public/latex"
    run "ln -nfs #{shared_path}/latex #{current_release}/public/latex"

    run "ln -nfs #{deploy_to}/#{shared_dir}/config/database.yml #{current_release}/config/database.yml"
    run "ln -nfs #{deploy_to}/#{shared_dir}/config/secret.txt #{current_release}/config/secret.txt"

    run "rm -rf #{current_release}/db/sphinx"
    run "ln -nfs #{shared_path}/sphinx #{current_release}/db/sphinx"
  end

  desc "Write the VERSION file to the server"
  task :create_version_files do
    version = `git describe --abbrev=0`.chomp
    run "echo #{version} > #{current_release}/VERSION"

    timestamp = current_release.scan(/\d{10,}/).first
    if timestamp
      run "echo #{timestamp} > #{current_release}/RELEASE"
    end
  end

  desc "refresh the staging database"
  task :refresh do
    run "touch #{deploy_to}/shared/tmp/refresh.txt"
  end

  desc "starts the crabgrass daemons"
  task :restart do
    run "#{deploy_to}/current/script/start_stop_crabgrass_daemons.rb restart"
  end

  desc "get the status of the crabgrass daemons"
  task :status do
    run "#{deploy_to}/current/script/start_stop_crabgrass_daemons.rb status"
  end

  desc "reindex sphinx"
  task :index do
    run "cd #{deploy_to}/current; rake ts:index RAILS_ENV=production"
  end
end

namespace :debian do
  desc "Setup rails symlinks, for debian location"
  task :symlinks do
    ["actionmailer", "actionpack", "activemodel",
    "activerecord", "activeresource", "activesupport", "railties"].each do |package|
      run "rm -f #{current_release}/vendor/#{package}"
      run "ln -s /usr/share/rails/#{package} #{current_release}/vendor/#{package}"
    end

    run "rm -f #{current_release}/vendor/rails"
    run "ln -s /usr/share/rails #{current_release}/vendor/rails"
  end
end

after  "deploy:setup",   "crabgrass:create_shared"
after  "deploy:symlink", "crabgrass:link_to_shared"
after  "deploy:symlink", "crabgrass:create_version_files"
before "deploy:restart", "debian:symlinks"
after  "deploy:restart", "passenger:restart"


