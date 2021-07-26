class OrganisationController < ApplicationController
  ORGANISATIONS = {
    'Government Digital Service' => {
      'programmes' => [
        'GOV.UK',
        'GOV.UK Verify',
        'Government as a Platform',
      ],
    },
    'Chief Digital and Information Office' => {
      'programmes' => [
        'Security',
        'GovWifi',
        'Digital Marketplace',
        'Digital Services',
      ]
    },
    'Central Digital and Data Office' => {
      'programmes' => [],
    }
  }

  def organisation
    @form = OrganisationForm.new(session.fetch('form', {}))
  end

  def post
    form_params = params.fetch('organisation_form', {}).permit(:organisation, :organisation_other).to_h
    @form = OrganisationForm.new(form_params)
    return render :organisation if @form.invalid?

    session_form = session.fetch('form', {})
    session_form.merge! form_params
    session_form[:organisation_or_other] = @form.organisation_or_other
    session['form'] = session_form

    redirect_to programme_path
  end

  def organisation_options
    ORGANISATIONS.keys
  end

  helper_method :organisation_options
end
