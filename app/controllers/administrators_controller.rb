require 'trello'

Trello.configure do |config|
  config.developer_public_key = ENV['TRELLO_DEVELOPER_PUBLIC_KEY']
  config.member_token = ENV['TRELLO_MEMBER_TOKEN']
end

class AdministratorsController < ApplicationController
  def administrators
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

    # This is the last controller, so we should do the side effects now.
    # Initially let's just stick a card in trello
    Trello::Card.create(
      list_id: '5ade08f50b5895b033065f71',
      name: "#{@form.account_name} (#{@form.programme})",
      desc: "New AWS account requested\n\n```\n#{JSON.pretty_generate(all_params)}\n```\n\n"
    )

    redirect_to confirmation_path
  end
end