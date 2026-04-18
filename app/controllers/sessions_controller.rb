class SessionsController < ApplicationController
  skip_before_action :set_current_user, only: :destroy

  def destroy
    reset_session
    redirect_to root_path
  end
end
