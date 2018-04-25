class AdministratorsController < ApplicationController
  def administrators
    @form = RequestAnAwsAccountForm.new({})
  end

  def post
    form_params = params.fetch('request_an_aws_account_form', {})
    @form = RequestAnAwsAccountForm.new(form_params)

    # This is the last controller, so we should do the side effects now.
    # Initially let's just stick a card in trello

    redirect_to confirmation_path
  end
end