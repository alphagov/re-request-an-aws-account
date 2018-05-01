class ConfirmationController < ApplicationController
  def user
    @pull_request_url = session.fetch('pull_request_url', 'ERROR') # TODO handle github failures more nicely
    session['form'] = nil
  end

  def account
    @pull_request_url = session.fetch('pull_request_url', 'ERROR') # TODO handle github failures more nicely
    session['form'] = nil
  end
end