class Users::OmniauthCallbacksController < Devise::OmniauthCallbacksController
  require 'uuidtools'
 
  layout "application"
  
 
   def facebook
    # to check if the facebook logi exists
    
    data = request.env["omniauth.auth"].extra.raw_info

    @user = User.find_for_oauth(request.env["omniauth.auth"], current_user, "facebook")

    if @user.persisted?
    logger.debug "User #{data} is persisted"   
      #if new user then create Authorization
      authentication = Authorization.find_by_provider_and_uid('facebook', data.id)
      if authentication
       else 
         @user.authorizations.create!(:provider => 'facebook', :uid => @user.id, :link => data.link) 
      end        
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Facebook"
      sign_in_and_redirect @user, :event => :authentication
    else
      logger.error "User #{@user.email} is not persisted"
      session["devise.facebook_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

  def twitter
     @user = User.find_for_oauth(request.env["omniauth.auth"], current_user, "twitter")
     data = request.env["omniauth.auth"].extra.raw_info
    if @user.persisted?
      logger.debug "User #{data} is persisted"
      #if new user then create Authorization
      authentication = Authorization.find_by_provider_and_uid('twitter', "#{data.id}")
      if authentication
       else 
         @user.authorizations.create!(:provider => 'twitter', :uid => data.id) 
      end  
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Twitter"
      sign_in_and_redirect @user, :event => :authentication
    else
      logger.error "User #{@user.id} is not persisted"
      session["devise.twitter_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end 
 
  def google_oauth2
    @user = User.find_for_google_oauth2(request.env["omniauth.auth"], current_user, "google_oauth2")
    data = request.env["omniauth.auth"].extra.raw_info
    
    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Google"
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.google_data"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

  def linkedin
    @user = User.find_for_linkedin_oauth(request.env["omniauth.auth"], "linkedin")
    data = request.env["omniauth.auth"].extra.raw_info

    if @user.persisted?
      flash[:notice] = I18n.t "devise.omniauth_callbacks.success", :kind => "Linkedin"
      sign_in_and_redirect @user, :event => :authentication
    else
      session["devise.linkedin"] = request.env["omniauth.auth"]
      redirect_to new_user_registration_url
    end
  end

end
