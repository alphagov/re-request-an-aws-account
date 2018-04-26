class ProgrammeController < ApplicationController
  def programme
    @form = ProgrammeForm.new({})
  end

  def post
    form_params = params.fetch('programme_form', {}).permit(:programme).to_h
    all_params = session.fetch('form', {}).merge form_params
    @form = ProgrammeForm.new(all_params.with_indifferent_access)
    session['form'] = all_params

    redirect_to administrators_path
  end
end