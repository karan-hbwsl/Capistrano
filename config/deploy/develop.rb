role :app, %w{localhost}
role :web, %w{localhost}
role :db,  %w{localhost}

#server '35.164.77.158', user: 'runcloud', roles: %w{app db web}

set :deploy_to, ENV["DEPLOY_PATH"]
set :branch, ENV["BRANCH"]

set :user, ENV["USER"]

set :deploy_mode, ENV["DEPLOY_MODE"]

set :keep_releases, ENV["KEEP_RELEASES"].to_i
