##
## REMEMBER: you can see available tasks with "cap -T"
##

##
## Items to configure
##

set :application, "crabgrass"
set :user, "crabgrass"

set :repository, "gitosis@labs.riseup.net:unicef.git"
set :branch, "cc-rewrite"

deploy_host = "yellowhammer.riseup.net"
staging_host = "209.234.253.11"

staging = true

set :app_db_host, 'localhost'
set :app_db_user, 'crabgrass'
set :app_db_pass, 'ho6aeYie'
set :secret, "f6671f7fc9c8ceea9f7a523a52210abce7048444eb61084bed4fb5d47ea"

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
set :keep_releases, 3

ssh_options[:paranoid] = false  
set :use_sudo, false   

role :web, (staging ? staging_host : deploy_host)
role :app, (staging ? staging_host : deploy_host)
role :db, (staging ? staging_host : deploy_host), :primary=>true

set :deploy_to, "/usr/apps/#{application}"

##
## SSH OPTIONS
##

# ssh_options[:keys] = %w(/path/to/my/key /path/to/another/key)
# ssh_options[:port] = 25

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
    
    run "mkdir -p #{deploy_to}/#{shared_dir}/config"   
    put database_configuration('app'), "#{deploy_to}/#{shared_dir}/config/database.yml" 
    put secret, "#{deploy_to}/#{shared_dir}/config/secret.txt"
  end

  desc "Link in the shared dirs" 
  task :link_to_shared do
    run "rm -rf #{release_path}/tmp"
    run "ln -nfs #{shared_path}/tmp #{release_path}/tmp"
    
    run "rm -rf #{release_path}/index"
    run "ln -nfs #{shared_path}/index #{release_path}/index"

    run "rm -rf #{release_path}/assets"
    run "ln -nfs #{shared_path}/assets #{release_path}/assets"

    run "rm -rf #{release_path}/public/assets"
    run "ln -nfs #{shared_path}/public_assets #{release_path}/public/assets"
      
    run "rm -rf #{release_path}/public/avatars"
    run "ln -nfs #{shared_path}/avatars #{release_path}/public/avatars"
    
    run "rm -rf #{release_path}/public/latex"
    run "ln -nfs #{shared_path}/latex #{release_path}/public/latex"

    run "ln -nfs #{deploy_to}/#{shared_dir}/config/database.yml #{release_path}/config/database.yml"
    run "ln -nfs #{deploy_to}/#{shared_dir}/config/secret.txt #{release_path}/config/secret.txt"

    #run "ln -nfs #{deploy_to}/#{shared_dir}/css/favicon.ico #{release_path}/public/favicon.ico"
    #run "ln -nfs #{deploy_to}/#{shared_dir}/css/favicon.png #{release_path}/public/favicon.png"
  end
end

namespace :debian do
  desc "Setup rails symlinks, for debian location"
  task :symlinks do
    run "ln -s /usr/share/rails/actionmailer #{release_path}/vendor/actionmailer"
    run "ln -s /usr/share/rails/actionpack #{release_path}/vendor/actionpack"
    run "ln -s /usr/share/rails/activemodel #{release_path}/vendor/actionmodel"
    run "ln -s /usr/share/rails/activerecord #{release_path}/vendor/activerecord"
    run "ln -s /usr/share/rails/activeresource #{release_path}/vendor/activeresource"
    run "ln -s /usr/share/rails/activesupport #{release_path}/vendor/activesupport"
    run "ln -s /usr/share/rails #{release_path}/vendor/rails"
    run "ln -s /usr/share/rails/railties #{release_path}/vendor/railties"
  end
end

after  "deploy:setup",   "crabgrass:create_shared"
after  "deploy:symlink", "crabgrass:link_to_shared"
before "deploy:restart", "debian:symlinks"
after  "deploy:migrate", "passenger:restart"
after  "deploy:restart", "passenger:restart"


