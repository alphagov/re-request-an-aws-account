class IndexController < ApplicationController
  def index()
    @email = session['email']
  end
end