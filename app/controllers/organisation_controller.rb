class OrganisationController < ApplicationController
  ORGANISATIONS = [
    'Government Property Agency',
    'Crown Commercial Services'
  ]

  def organisation
    @form = OrganisationForm.new(session.fetch('form', {}), nil, logger)
  end

  def post
    form_params = params.fetch('organisation_form', {}).permit(:organisation, :cost_centre_code).to_h
    
    @form = OrganisationForm.new(form_params, cost_centres, logger)
      return render :organisation if @form.invalid?
      session_form = session.fetch('form', {})
      
      session_form[:organisation] = @form.organisation
      session_form[:cost_centre_code] = @form.cost_centre_code
      session_form[:cost_centre_description] = @form.cost_centre_description
      session_form[:business_unit] = @form.business_unit
      session_form[:subsection] = @form.subsection
      
      session['form'] = session_form
      puts session.fetch("form", {})

    redirect_to team_path
  end

  def organisation_options
    ORGANISATIONS
  end

  helper_method :organisation_options
end
