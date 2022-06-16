class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  # added by Mani team (obs: this is probably why in ManiGames signup was not working!)
  before_action :configure_permitted_parameters, if: :devise_controller?

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[username email birthday score lives])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[username email birthday score lives])
    # devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :birthday, :score, :lives) }
    # devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:username, :birthday, :score, :lives) }
  end

  # REMOVE Navbar --------------------------------------
  def disable_nav
    @disable_nav = true
  end
  # ----------------------------------------------------

  # REMOVE "Meu dashboard" button from Navbar ----------
  def disable_dashboard_button
    @disable_dashboard_button = true
  end
  # ----------------------------------------------------

  # SHOW ser info on Navbar ---------------------
  def show_user_info
    @show_user_info = true
  end
  # ----------------------------------------------------
  #----------------------------------------------------------------------------------------
end
