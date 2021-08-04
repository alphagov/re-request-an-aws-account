class ProgrammeController < ApplicationController
  def programme
    @form = ProgrammeForm.new(session.fetch('form', {}))
  end

  def post
    form_params = params.fetch('programme_form', {}).permit(:programme, :programme_other).to_h
    @form = ProgrammeForm.new(form_params)
    return render :programme if @form.invalid?

    session_form = session.fetch('form', {})
    session_form.merge! form_params
    session_form[:programme_or_other] = @form.programme_or_other
    session['form'] = session_form

    redirect_to team_path
  end

  def programme_options
    organisation = session.fetch('form', {})['organisation']

    OrganisationController::ORGANISATIONS.dig(organisation, 'programmes') || []
  end

  helper_method :programme_options
end
