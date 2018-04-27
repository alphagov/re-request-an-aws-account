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

    session['card_id'] = 'TODO'
    redirect_to confirmation_path
  end
end