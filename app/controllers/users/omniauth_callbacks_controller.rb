class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  require 'uuidtools'
 
  layout "application"

 
   def facebook
    # to check if the facebook logi exists
    @user = User.find_for_facebook_oauth(request.env["omniauth.auth"], current_user)
    data = request.env["omniauth.auth"].extra.raw_info
    if @user.persisted?
      logger.debug "User #{data.id} is persisted"
      #if new user then create Authorization
      authentication = Authorization.find_by_provider_and_uid('facebook', data.id)
      if authentication
       else 
         @user.authorizations.create!(:provider => 'facebook', :uid => @user.username) 
      end  
      logger.debug "#{data} test "
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Facebook"
      sign_in_and_redirect @user, :event => :authentication
    else
      logger.error "User #{@user.email} is not persisted"
      session["devise.facebook_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end



  
 
end
