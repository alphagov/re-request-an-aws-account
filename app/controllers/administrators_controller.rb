class AdministratorsController < ApplicationController
  def administrators
    @form = RequestAnAwsAccountForm.new({})
  end

  def post
    form_params = params.fetch('request_an_aws_account_form', {})
    @form = RequestAnAwsAccountForm.new(form_params)
    session['form'] = form_params.to_json
    redirect_to confirmation_path
  end
end