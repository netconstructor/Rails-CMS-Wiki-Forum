# Filters added to this controller apply to all controllers in the application.
# Likewise, all the methods added will be available for all controllers.

class ApplicationController < ActionController::Base
  helper :all
  helper_method :current_user_session, :current_user
  filter_parameter_logging :password, :password_confirmation
  
  before_filter :get_site_settings

  private
    def get_site_settings
      @site_title = "Title of the site"
      @side_menu = ContentPage.get_side_menu
      @top_menu = ContentPage.get_top_menu
    end

    def current_user_session
      return @current_user_session if defined?(@current_user_session)
      @current_user_session = UserSession.find
    end
    
    def current_user
      return @current_user if defined?(@current_user)
      @current_user = current_user_session && current_user_session.record
    end
    
    def require_user
      unless current_user
        store_location
        flash[:warning] = "You must be logged in to access this page."
        redirect_to login_path
        return false
      end
    end

    def require_admin_user
      unless current_user and current_user.is_admin?
        flash[:error] = "You do not have permission to access that page."
        redirect_to login_path
        return false
      end
    end

    def require_moderator_user
      get_forum
      unless current_user and current_user.is_moderator_for_forum?(@forum)
        flash[:error] = "You do not have permission to access that page."
        redirect_to '/'
        return false
      end
    end

    def require_no_user
      if current_user
        store_location
        flash[:warning] = "You must be logged out to access this page."
        redirect_to account_url
        return false
      end
    end
    
    def store_location
      session[:return_to] = request.request_uri
    end
    
    def redirect_back_or_default(default)
      redirect_to(session[:return_to] || default)
      session[:return_to] = nil
    end
end
