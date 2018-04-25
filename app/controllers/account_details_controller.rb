class AccountDetailsController < ApplicationController
  def account_details
    @form = RequestAnAwsAccountForm.new({})
  end

  def post
    form_params = params.fetch('request_an_aws_account_form', {})
    all_params = session.fetch('form', {}).merge form_params.permit(
      :account_name,
      :programme,
      :is_production,
      :admin_users
    )
    @form = RequestAnAwsAccountForm.new(all_params.with_indifferent_access)
    session['form'] = all_params
    redirect_to programme_path
  end
end