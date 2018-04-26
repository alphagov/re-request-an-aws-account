class IndexController < ApplicationController
  skip_before_action :authenticate

  def index()
    @email = session['email']
  end
end