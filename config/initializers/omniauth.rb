#OmniAuth.config.full_host = "dev.reneue-grader.com"
Rails.application.config.middleware.use OmniAuth::Builder do
#require 'openid/store/filesystem' 	
  #google apps
 # provider :google_apps, 'dev.revenue-grader.com', '687896268286.apps.googleusercontent.com', 'qJ3gKLSbbeAT3-ZShMsArias'

 #facebook
  #provider :facebook, '389187014443203', '3f0e1b1d0965ad0a8d4a0694677ddf2f'#,
  #         {:scope => 'email, read_stream, read_friendlists, friends_likes, friends_status, offline_access',
  #         :client_options => {:ssl => {:ca_path => "/etc/ssl/certs"}}}
  #twitter
  # provider :twitter, '0MCcStPgM8eAvlIpDZEU5g', 'NTxxbMxIXqsj2m3DWBAiosJPQp7IcDtLBd4l9nKOY'
end