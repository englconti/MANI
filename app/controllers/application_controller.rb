class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  # added by Mani team (obs: this is probably why in ManiGames signup was not working!)
  before_action :configure_permitted_parameters, if: :devise_controller?

  def configure_permitted_parameters
    # Never lives or score: they would let a person give themselves points through the form
    devise_parameter_sanitizer.permit(:sign_up, keys: %i[username email birthday])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[email birthday])
    # devise_parameter_sanitizer.for(:sign_up) { |u| u.permit(:username, :birthday, :score, :lives) }
    # devise_parameter_sanitizer.for(:account_update) { |u| u.permit(:username, :birthday, :score, :lives) }
  end

  # After signing in (or up) go straight to the user's trail, unless they were
  # sent to the login by a protected page: then send them back there.
  def after_sign_in_path_for(resource)
    stored_location_for(resource) || user_path(resource)
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
