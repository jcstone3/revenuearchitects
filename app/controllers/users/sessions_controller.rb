class Users::SessionsController < Devise::SessionsController

  #users/sessions/new.html.erb
  def new
    resource = build_resource
    clean_up_passwords(resource)
    respond_with(resource, serialize_options(resource))
  end


	def create
	  #super
    resource = warden.authenticate!(auth_options)
    set_flash_message(:success, :signed_in) if is_navigational_format?
    #flash[:success] ='Welcome! You have signed in successfully.'
    sign_in(resource_name, resource)
    respond_with resource, :location => after_sign_in_path_for(resource)
	end 
	
	def destroy
      super
	end	

	private
  
    def build_resource(*args)    
      super
      if session[:omniauth]
        @user.apply_omniauth(session[:omniauth])
        @user.valid?
      end
    end
end
