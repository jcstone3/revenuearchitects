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
    sign_in(resource_name, resource)
    respond_with resource, :location => after_sign_in_path_for(resource)
	end 
	
	def destroy
      #super
    redirect_path = new_user_session_url
    signed_out = (Devise.sign_out_all_scopes ? sign_out : sign_out(resource_name))
    set_flash_message :success, :signed_out if signed_out

    # We actually need to hardcode this as Rails default responder doesn't
    # support returning empty response on GET request
    respond_to do |format|
      format.any(*navigational_formats) { redirect_to redirect_path }
      format.all do
        method = "to_#{request_format}"
        text = {}.respond_to?(method) ? {}.send(method) : ""
        render :text => text, :status => :ok
      end
    end

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
