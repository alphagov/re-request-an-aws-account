class OrganisationController < ApplicationController
  ORGANISATIONS = [
    'Government Property Agency',
    'Crown Commercial Services'
  ]

  GDS_ORG_ACCOUNT_VENDING_README = 'https://github.com/alphagov/gds-aws-organisation-accounts#requesting-a-new-aws-account-in-gds'

  def organisation
    @form = OrganisationForm.new(session.fetch('form', {}), cost_centres)
  end

  def post
    form_params = params.fetch('organisation_form', {}).permit(:organisation, :cost_centre_code).to_h
    @form = OrganisationForm.new(form_params, cost_centres)
      return render :organisation if @form.invalid?
      session_form = session.fetch('form', {})
      
      session_form[:organisation] = @form.organisation

      if @form.organisation == 'Cabinet Office'
        session_form[:cost_centre_code] = @form.cost_centre_code
        session_form[:cost_centre_description] = @form.cost_centre_description
        session_form[:business_unit] = @form.business_unit
        session_form[:subsection] = @form.subsection

        session['form'] = session_form
        redirect_to organisation_summary_path
      elsif @form.organisation == 'GDS or CDDO or I.AI'
        redirect_to GDS_ORG_ACCOUNT_VENDING_README, allow_other_host: true
      else
        session_form[:cost_centre_code] = nil
        session_form[:cost_centre_description] = nil
        session_form[:business_unit] = nil
        session_form[:subsection] = nil
        
        session['form'] = session_form
        redirect_to team_path
      end
  end

  def organisation_options
    ORGANISATIONS
  end

  helper_method :organisation_options
end
