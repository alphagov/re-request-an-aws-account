class GoogleAuthController < ApplicationController
  def callback
    redirect_to account_details_path
  end
end