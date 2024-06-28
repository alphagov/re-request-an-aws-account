class TeamController < ApplicationController
  def team
    session_data = session.fetch('form', {}).with_indifferent_access
    @form = TeamForm.new(session_data)
    @back_url = session_data['organisation'] == "Cabinet Office" ? organisation_summary_path : organisation_path
  end

  def post
    form_params = params.fetch(
      'team_form', {}
    ).permit(
      :team_name,
      :team_email_address,
      :team_lead_name,
      :team_lead_email_address,
      :team_lead_phone_number,
      :team_lead_role
    ).to_h

    @form = TeamForm.new(form_params)
    return render :team if @form.invalid?

    session['form'] = session.fetch('form', {}).merge form_params

    redirect_to service_path
  end
end
