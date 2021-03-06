class Users::RegistrationsController < Devise::RegistrationsController
  
  def new
    resource = build_resource({})
    respond_with resource
  end 

	#create new user
	def create
      super
      session[:omniauth] = nil unless @user.new_record?
      # respond_to do |format|
      # if @user.save
      #   UserMailer.welcome(@user).deliver
      #   sign_in@user
      #   redirect_to @user, :flash => {:success => "User was successfully created."}
      #   #format.html { redirect_to(@user, :notice => 'User was successfully created.') }
      # else
      #   return "new"
      #   #format.html { render :action => "new" }
      # end
    end

	def update
    if params[resource_name][:password].blank?
      params[resource_name].delete(:password)
      params[resource_name].delete(:password_confirmation) if params[resource_name][:password_confirmation].blank?
    end
    # Override Devise to use update_attributes instead of update_with_password.
    # This is the only change we make.
    if resource.update_attributes(params[resource_name])
      set_flash_message :notice, :updated
      # Line below required if using Devise >= 1.2.0
      sign_in resource_name, resource, :bypass => true
      redirect_to after_update_path_for(resource)
    else
      clean_up_passwords(resource)
      render_with_scope :edit
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
