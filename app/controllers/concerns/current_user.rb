module CurrentUser
  extend ActiveSupport::Concern

  included do
    helper_method :current_user
    before_action :set_current_user
  end

  private

  def current_user
    @current_user
  end

  def set_current_user
    @current_user = User.find_by(id: session[:user_id]) if session[:user_id]

    unless @current_user
      @current_user = User.create!
      session[:user_id] = @current_user.id
    end
  end
end
