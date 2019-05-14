class ConfirmationController < ApplicationController
  def user
    @pull_request_url = session.fetch('pull_request_url', 'error')
    session['form'] = nil
  end

  def remove_user
    @pull_request_url = session.fetch('pull_request_url', 'error')
    session['form'] = nil
  end

  def reset_password
    @pull_request_url = session.fetch('pull_request_url', 'error')
    session['form'] = nil
  end

  def account
    @pull_request_url = session.fetch('pull_request_url', 'ERROR')
    session['form'] = nil
  end
end
