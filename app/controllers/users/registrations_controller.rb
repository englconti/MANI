class Users::RegistrationsController < Devise::RegistrationsController
  # Deleting the account wipes progress, XP and friendships, so it asks for the password
  def destroy
    unless resource.valid_password?(params[:current_password])
      return redirect_to edit_user_registration_path, alert: "Senha incorreta. Sua conta não foi excluída."
    end

    super
  end

  protected

  # Devise always lets the login key (the username) through; it is not editable here
  def account_update_params
    super.except(:username)
  end

  # After saving the data, back to the trail
  def after_update_path_for(resource)
    user_path(resource)
  end
end
