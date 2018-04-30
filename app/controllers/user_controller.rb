class UserController < ApplicationController
  def user
    @form = UserForm.new({})
  end

  def post
    form_params = params
                    .fetch('user_form', {})
                    .permit(:email).to_h
    @form = UserForm.new(form_params)
    return render :user if @form.invalid?

    requester_email = session.fetch('email')
    email = @form.email

    pull_request_url = GithubService.new.create_new_user_pull_request(email, requester_email)

    trello_url = TrelloService.create_new_user_card(email, requester_email, pull_request_url)
    card_id = trello_url ? trello_url.split('/').last : nil # Hack - ruby-trello doesn't expose shortLink
    session['card_id'] = card_id

    notify_service = NotifyService.new
    notify_service.new_user_email_support(email, requester_email, pull_request_url, trello_url)
    notify_service.new_user_email_user(email, requester_email, card_id)

    redirect_to confirmation_path
  end
end