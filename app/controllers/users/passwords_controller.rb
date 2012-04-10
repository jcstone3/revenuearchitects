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
end	