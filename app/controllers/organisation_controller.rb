class OrganisationController < ApplicationController
  ORGANISATIONS = [
    'Government Property Agency',
    'Crown Commercial Services'
  ]

  def organisation
    @form = OrganisationForm.new(session.fetch('form', {}), cost_centres)
  end

  def post
    form_params = params.fetch('organisation_form', {}).permit(:organisation, :cost_centre_code).to_h
    @form = OrganisationForm.new(form_params, cost_centres)
      return render :organisation if @form.invalid?

    session_form = session.fetch('form', {})
    session_form.merge! form_params
    session_form[:organisation] = @form.organisation
    session['form'] = session_form

    redirect_to team_path
  end

  def organisation_options
    ORGANISATIONS
  end

  helper_method :organisation_options
end
