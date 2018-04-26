class ProgrammeController < ApplicationController
  def programme
    @form = ProgrammeForm.new({})
  end

  def post
    form_params = params.fetch('programme_form', {}).permit(:programme).to_h
    @form = ProgrammeForm.new(form_params.with_indifferent_access)
    return render :programme if @form.invalid?

    session['form'] = session.fetch('form', {}).merge form_params

    redirect_to administrators_path
  end
end