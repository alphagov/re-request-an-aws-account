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

    trello_url = TrelloService.create_new_user_card(@form.email, session.fetch('email'), 'https://todo.pr.url')
    card_id = trello_url.split('/').last # Hack - ruby-trello doesn't expose shortLink
    session['card_id'] = card_id

    redirect_to confirmation_path
  end
end