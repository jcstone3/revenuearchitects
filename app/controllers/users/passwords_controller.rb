class Users::PasswordsController < Devise::PasswordsController
  skip_before_filter :authenticate_user!
def new
    build_resource({})
  end

  # POST /resource/password
  def create
    self.resource = resource_class.send_reset_password_instructions(params[resource_name])

    if successfully_sent?(resource)
      respond_with({}, :location => after_sending_reset_password_instructions_path_for(resource_name))
    else
      respond_with(resource)
    end
  end

  def edit
    self.resource = resource_class.new
    resource.reset_password_token = params[:reset_password_token]
    #@reset_token = params[:reset_password_token]
  end

  # PUT /resource/password

  def update
    logger.debug "In update method"
    self.resource = resource_class.reset_password_by_token(params[resource_name])

    if resource.errors.empty?
      logger.debug "############"
      flash_message = resource.active_for_authentication? ? :updated : :updated_not_active
      set_flash_message(:success, flash_message) if is_navigational_format?
      sign_in(resource_name, resource)
      respond_with resource, :location => after_sign_in_path_for(resource)
    else
      logger.debug "In else"
      respond_with resource
    end
    logger.debug "After else method"
  end

end 