class AdministratorsController < ApplicationController
  def administrators
    @form = AdministratorsForm.new(session.fetch('form', {}))
  end

  def post
    form_params = params.fetch('administrators_form', {}).permit(:admin_users).to_h
    @form = AdministratorsForm.new(form_params)
    return render :administrators if @form.invalid?

    session['form'] = session.fetch('form', {}).merge form_params
    redirect_to check_your_answers_path
  end
end