class Users::RegistrationsController < Devise::RegistrationsController
 #users/registration/new.html.erb
  def new
    resource = build_resource({})
    respond_with resource
  end

#create new user
  def create

     build_resource
     generated_password = Devise.friendly_token.first(8)
     resource.password = generated_password

    if resource.save
      if resource.active_for_authentication?
        set_flash_message :success, :signed_up if is_navigational_format?
        Usermailer.welcome(resource).deliver

        begin
          Usermailer.new_signup_details(resource).deliver
        rescue Exception => e
          logger.info e.message
          logger.info e.backtrace
        end

        sign_in(resource_name, resource)

        # On successful signup create Company and Survey object
        @company = Company.create(user_id: current_user.id)
        @survey = Survey.create(company_id: @company.id, is_active: true, start_date: Time.now)
        # respond_with resource, :location => after_sign_up_path_for(resource)

        # New flow - redirects to the first question
        redirect_to questions_path(@survey, 1)

        #format.html { redirect_to(@user, :notice => 'User was successfully created.') }
      else
         set_flash_message :success, :"signed_up_but_#{resource.inactive_message}" if is_navigational_format?
         expire_session_data_after_sign_in!
         respond_with resource, :location => after_inactive_sign_up_path_for(resource)
      end
      else
       clean_up_passwords resource
       respond_with resource
    end
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
