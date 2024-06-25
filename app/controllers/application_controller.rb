class ApplicationController < ActionController::Base
  protect_from_forgery with: :exception
  before_action :authenticate

  def authenticate
    redirect_to index_path unless session.has_key? 'email'
  end

  def cost_centres
    @cost_centres ||= CostCentreReader.new(File.join(Rails.root, 'config', 'cost_centres.csv'))
  end
end
