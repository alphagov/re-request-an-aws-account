class DevelopmentController < ApplicationController
  skip_before_action :authenticate

  def dev_login
    session['name'] = 'Example Developer'
    session['email'] = 'example-developer@digital.cabinet-office.gov.uk'
    redirect_to index_path
  end
end
