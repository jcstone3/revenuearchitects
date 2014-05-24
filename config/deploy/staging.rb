# Simple Role Syntax
# ==================
# Supports bulk-adding hosts to roles, the primary
# server in each group is considered to be the first
# unless any hosts have the primary property set.
# Don't declare `role :all`, it's a meta role
# role :app, %w{deploy@example.com}
# role :web, %w{deploy@example.com}
# role :db,  %w{deploy@example.com}

# Extended Server Syntax
# ======================
# This can be used to drop a more detailed server
# definition into the server list. The second argument
# something that quacks like a hash can be used to set
# extended properties on the server.
# server 'example.com', user: 'deploy', roles: %w{web app}, my_property: :my_value

# you can set custom ssh options
# it's possible to pass any option but you need to keep in mind that net/ssh understand limited list of options
# you can see them in [net/ssh documentation](http://net-ssh.github.io/net-ssh/classes/Net/SSH.html#method-c-start)
# set it globally
#  set :ssh_options, {
#    keys: %w(/home/rlisowski/.ssh/id_rsa),
#    forward_agent: false,
#    auth_methods: %w(password)
#  }
# and/or per server
# server 'example.com',
#   user: 'user_name',
#   roles: %w{web app},
#   ssh_options: {
#     user: 'user_name', # overrides user setting above
#     keys: %w(/home/user_name/.ssh/id_rsa),
#     forward_agent: false,
#     auth_methods: %w(publickey password)
#     # password: 'please use keys'
#   }
# setting per server overrides global ssh_options

################################################################

# Repository repository path
set :repository,  "git@code.icicletech.com:rails/revenuegrader.git"

# Numbers of  releases for save
#set :keep_releases, 1

# Path for application deployment
set :path, "/home/icicle/sites/revenue"

# Location  for deployment i.e server name
set :location, "192.168.1.2"

role :web, "192.168.1.2"      # Your HTTP server, Apache/etc
role :app, "192.168.1.2"      # This may be the same as your `Web` server
role :db, "192.168.1.2"       # This is where Rails migrations will run

server location, :app , :web, :db, :primary => true

# server "localhost", :app, :web, :primary => true
set :deploy_to, path
set :rails_env, "staging"

set :user_sudo, true
set :user, "icicle"
set :admin_runner, "icicle"
