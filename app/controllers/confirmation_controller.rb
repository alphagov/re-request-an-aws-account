class ConfirmationController < ApplicationController
  def confirmation
    @pull_request_url = session.fetch('pull_request_url')
    session['form'] = nil
  end
end