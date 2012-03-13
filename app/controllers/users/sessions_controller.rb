class Users::SessionsController < Devise::SessionsController

  #users/sessions/new.html.erb
  def new
    resource = build_resource
    clean_up_passwords(resource)
    respond_with(resource, serialize_options(resource))
  end


	def create
	  super
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
