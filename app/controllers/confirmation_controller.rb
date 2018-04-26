class ConfirmationController < ApplicationController
  def confirmation
    @card_id = session.fetch('card_id')
    session['form'] = nil
  end
end